#include <cpu/ftrace.h>
// #define INFO

/* ELF parser and function calling recorder */
struct Binary {
	uint8_t *bin;
	int size;
};

static struct Binary *elf = NULL;
static Elf64_Ehdr ehdr;

static Elf64_Shdr *SHT = NULL;
static uint16_t SHT_num;

static Elf64_Shdr SH_strtab;
static Elf64_Shdr SH_symtab;

static Elf64_Sym *S_symtab = NULL;
static int S_symtab_num;

struct Func {
	vaddr_t addr;
	uint64_t size;
	char *name;
};

#define MAX_FUNC_RECORD 100
static struct Func fr[MAX_FUNC_RECORD];
static int fndx = -1;

/* communicate with nemu's monitor through 'init_ftrace()' */

static void load_elf(char *filepath)
{
	assert(filepath != NULL);
	
	FILE *fp = fopen(filepath, "rb");
	if (fp == NULL)
	{
		printf("Can't open the '%s'\n", filepath);
		exit(EXIT_FAILURE);
	}

	/* ELF format : 7f 45 4c 46 */
	char magic[4];
	fread(magic, 1, 4, fp);

	if (magic[0] != (char)0x7f || magic[1] != 'E' || magic[2] != 'L' || magic[3] != 'F')
	{
		printf("It is not the ELF format file\n");
		exit(EXIT_FAILURE);
	}

	/* INITIALIZATION */
	elf = (struct Binary *)malloc(sizeof(struct Binary));

	fseek(fp, 0, SEEK_END);
	elf->size = ftell(fp);
	
	elf->bin = (uint8_t *)malloc(sizeof(uint8_t) * elf->size);
	fseek(fp, 0, SEEK_SET);
	fread(elf->bin, 1, elf->size, fp);

	fclose(fp);

	Log("The ELF file is %s, size = %d", filepath, elf->size);
}

static void parse_ehdr(void)
{
	int ehsize = 1*16 + 2 + 2 + 4 + 8 + 8 + 8 + 4 + 2 + 2 + 2 + 2 + 2 + 2;
	memcpy(&ehdr, elf->bin, ehsize);

	/* no memory alignment */
	assert(ehsize == ehdr.e_ehsize);
}

static void parse_SHT(void)
{
	/* SHT(Section Header Table) */
	SHT_num = ehdr.e_shnum;
	SHT = (Elf64_Shdr *)malloc(sizeof(Elf64_Shdr) * SHT_num);

	int SHT_size = ehdr.e_shnum * ehdr.e_shentsize;
	int SHT_offset = ehdr.e_shoff;
	memcpy(SHT, &(elf->bin[SHT_offset]), SHT_size);

	assert(sizeof(SHT[0]) == ehdr.e_shentsize);

	/* SH_shstrtab => (Section Header) shstrtab */
	Elf64_Shdr SH_shstrtab  = SHT[ehdr.e_shstrndx];
	uint64_t S_shstrtab_offset  = SH_shstrtab.sh_offset;

	assert(elf->bin[S_shstrtab_offset] == '\0');
	
	/* find '.strtab' and '.symtab' Section Header  */
	for (int j = 0; j < ehdr.e_shnum; j++)
	{
		int index = SHT[j].sh_name;
		char *s = &(elf->bin[S_shstrtab_offset]) + index;

		if (strcmp(".strtab", s) == 0)
			SH_strtab = SHT[j];
		else if (strcmp(".symtab", s) == 0)
			SH_symtab = SHT[j];
	}
}

static void parse_symtab(void)
{
	/*  self-explanatory; compiler optimization */

	/* ==== Elf64_Sym ==> also no memory alignment === */
	assert(SH_symtab.sh_entsize == sizeof(S_symtab[0]));

	int S_symtab_size = SH_symtab.sh_size;
	S_symtab_num = S_symtab_size / sizeof(S_symtab[0]);
	S_symtab = (Elf64_Sym *)malloc(sizeof(Elf64_Sym) * S_symtab_num);

	int S_symtab_offset = SH_symtab.sh_offset;
	memcpy(S_symtab, &(elf->bin[S_symtab_offset]), S_symtab_size);

	/*
	int E_symtab_size = SH_symtab.sh_entsize;
	int S_symtab_size = SH_symtab.sh_size;

	S_symtab_num = S_symtab_size / E_symtab_size;
	S_symtab = (Elf64_Sym *)malloc(sizeof(Elf64_Sym) * S_symtab_size);

	int S_symtab_offset = SH_symtab.sh_offset;
	uint8_t *p = &(elf->bin[S_symtab_offset]);
	for (int j = 0; j < S_symtab_num; ++j)
	{
		S_symtab[j].st_name  = *(uint32_t *)p;
		p += 4;

		S_symtab[j].st_info  = *(unsigned char *)p;
		p += 1;

		S_symtab[j].st_other = *(unsigned char *)p;
		p += 1;

		S_symtab[j].st_shndx = *(uint16_t  *)p;
		p += 2;

		S_symtab[j].st_value = *(uint64_t *)p;
		p += 8;

		S_symtab[j].st_size  = *(uint64_t *)p;
		p += 8;
	}
	*/
}

void fcall(vaddr_t pc, Decode *s)
{
	vaddr_t dnpc = s->dnpc;
	uint32_t inst = s->isa.inst.val;

	for (int j = 0; j < S_symtab_num; j++)
	{
		/* match one symbol */
		if (dnpc == S_symtab[j].st_value && ELF64_ST_TYPE(S_symtab[j].st_info) == STT_FUNC)
		{
			int S_strtab_offset = SH_strtab.sh_offset;
			int index = S_symtab[j].st_name;

			char *s = &(elf->bin[S_strtab_offset]) + index;

			if (fndx == MAX_FUNC_RECORD - 1)
			{
				printf("only record %d level function calling\n", MAX_FUNC_RECORD);
				break;
			}
			else
			{
				fndx += 1;
				fr[fndx].addr = dnpc;
				fr[fndx].size = S_symtab[j].st_size;
				fr[fndx].name = s;

				printf(FMT_WORD ":"
					   ANSI_FMT("call  ", ANSI_FG_YELLOW)
					   " %s["
					   ANSI_FMT(FMT_WORD, ANSI_FG_YELLOW)
					   "]"
					   "(LEVEL %2d)" 
					   "\n",
					   pc, s, dnpc, fndx);
			}
		}
		else
		{
			int cond = (inst == 0x00008067);
			for (int j = fndx; j >= 0; --j)
			{
				/* if (pc == fr[j].addr + fr[j].size) ... (x) */
				/* WRONG => 'ret' is not the last instruction of the function */
				/* for example, 'void check(bool cond)' in cpu-tests/include/trap.h  */

				if ((pc > fr[j].addr && pc <= fr[j].addr + fr[j].size) && cond)
				{
					/* function return */
					printf(FMT_WORD ":"
						   ANSI_FMT("return", ANSI_FG_YELLOW)
						   " %s["
						   ANSI_FMT(FMT_WORD, ANSI_FG_YELLOW)
						   "]"
						   "(LEVEL %2d)" 
						   "\n", 
						   pc, fr[j].name, dnpc, fndx);
					
					fndx = j - 1;
					break;
				}
			}

		}
	}
}


/* ======================= DEBUG ======================== */

void info_ehdr(void)
{
	uint8_t *p = (uint8_t *)&ehdr;
	printf("------------------ ELF Header -----------------");
	for (int j = 0; j < sizeof(Elf64_Ehdr); ++j)
	{
		(j % 16 == 0) ? printf("\n") : printf(" ");
		printf("%02x", p[j]);
	}
	printf("\n-----------------------------------------------\n");
}

void info_SHT(void)
{
	printf("--------------------- Section Header Table ---------------------\n");
	printf("[Nr]%*cName%*cSize%*cOffset\n", 4, ' ', 16, ' ', 16, ' ');

	uint64_t S_shstrtab_offset  = SHT[ehdr.e_shstrndx].sh_offset;
	char *base = &(elf->bin[S_shstrtab_offset]);

	for (int j = 0; j < SHT_num; ++j)
	{
		printf("[%2d]    %-20s%016lx    %016lx\n",
				j, base + SHT[j].sh_name, SHT[j].sh_size, SHT[j].sh_offset);
	}
	printf("----------------------------------------------------------------\n");
}

void info_symtab(void)
{
	printf("--------------------- Symbol Table ---------------------\n");
	printf("Num: Value%*cSize%*cType%*cName\n", 15, ' ', 6, ' ', 4, ' ');
	
	int S_strtab_offset = SH_strtab.sh_offset;
	char *base =  &(elf->bin[S_strtab_offset]);

	for (int j = 0; j < S_symtab_num; ++j)
	{
		/* S_symtab[j].st_info == STT_FUNC (x) */
		/* must use the macro to decode : ELF64_ST_TYPE(info) */
		char *type = (ELF64_ST_TYPE(S_symtab[j].st_info) == STT_FUNC ? "FUNC": "    ");
		printf("%3d: %016lx    %-10ld%-8s%-s\n",
				j, S_symtab[j].st_value, S_symtab[j].st_size, type, base + S_symtab[j].st_name);
	}
	printf("--------------------------------------------------------\n");

	/* dummy.c */
	/* printf("_trm_init entry offset : %x\n", SH_symtab.sh_offset + sizeof(Elf64_Sym) * 12);
	printf("TYPE(_trm_init) = %d\n", ELF64_ST_TYPE(S_symtab[12].st_info)); */
}

/* ====================================================== */

void init_ftrace(char *filepath)
{
	Log("Ftrace : " ANSI_FMT("ON", ANSI_FG_GREEN));

	load_elf(filepath);
	parse_ehdr();
	parse_SHT();
	parse_symtab();
#ifdef INFO
	info_ehdr();
	info_SHT();
	info_symtab();
#endif
}
