#ifndef __CPU_FTRACE_H__
#define __CPU_FTRACE_H__

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <elf.h>

/* vaddr_t ... */
#include <common.h>
/* Decode */
#include <cpu/decode.h>

void fcall(vaddr_t pc, Decode *s);

#endif
