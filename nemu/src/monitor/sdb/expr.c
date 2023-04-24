/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
	TK_NOTYPE = 256, 
	/* TODO: Add more token types */
	TK_DEC,
	TK_HEX,
	TK_REG,
	TK_EQ,
	TK_NE,
	// '+', '-', '*', '/', '(', ')'
	TK_AND,
	TK_OR,
	TK_DEREF,
};

static struct rule {
	const char *regex;
	int type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

	{" +", TK_NOTYPE},			// spaces
	{"0[xX][0-9]+", TK_HEX},	// hexadecimal
	{"[0-9]+", TK_DEC},			// decimal
	{"\\$(\\$0|ra|[sgt]p|t[0-6]|a[0-7]|s[0-9]|s1[01])", TK_REG},
	{"==", TK_EQ},				// equal
	{"!=", TK_NE},				// not equal
	{"\\+", '+'},         		// addition
	{"-", '-'},					// subtraction
	{"\\*", '*'},				// multiplication
	{"/", '/'},					// division
	{"\\(", '('},				// l-parenthese
	{")", ')'},					// r-parenthese
	{"&&", TK_AND},				// and
	{"\\|\\|", TK_OR},			// or
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[32] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */

        switch (rules[i].type) {
			case TK_NOTYPE:
				/* discard (see below) */
				break;
			case '+':
			case '-':
			case '*':
			case '/':
			case '(':
			case ')':
			case TK_EQ:
			case TK_NE:
			case TK_AND:
			case TK_OR:
				/* for operator, we don't use tokens[j].str */
				break;
			case TK_DEC:
			case TK_HEX:
				if (substr_len > 31)
				{
					/* TODO: buffer overflow */
					assert(0);
				}
				else
				{
					strncpy(tokens[nr_token].str, substr_start,
							substr_len);
					tokens[nr_token].str[substr_len] = '\0';
				}
				break;
			case TK_REG:
				/* TODO: discard '$' */
				strncpy(tokens[nr_token].str, substr_start + 1,
						substr_len - 1);
				tokens[nr_token].str[substr_len - 1] = '\0';
				break;
			default:
				/* can't recognize the token's type */
				assert(0);
        }

		if (rules[i].type != TK_NOTYPE)
			tokens[nr_token++].type = rules[i].type;

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}

static bool check_parentheses(int p, int q)
{
	/* mismatch --- unknown --- "2 + 3) + 4"(x) or "2 + 3 + 4" */
	/* TODO */
	if (tokens[p].type != '(' || tokens[q].type != ')')
		return false;

	/* match    --- "(3 + 4 / 5)" or "((3 + 4) / 5)" */
	/* mismatch --- "2 + 3" or "(2) + 3" or "(3 + 4) - (2 - 1)" */
	/* mismatch --- "(3 + 4)) + ((4)" */
	/* TODO : add multiple nested () expr as tes */

	bool flag = true;
	int n = 0;

	while (p <= q && n >= 0)
	{
		/* if n < 0 >>> num of ')' > num of '(' >>> illegal */
		if (tokens[p].type == '(')
			++n;
		else if (tokens[p].type == ')')
			--n;
		
		// printf("n = %d\n", n);
		if (n == 0 && p != q)
		{
			/* the first '('doesn't match the last ')', but the ')' in previous location */
			flag = false;
		}

		++p;
	}

	return flag;
};

int op_pre(int type)
{
	/* C operator precedence: https://www.cs.uic.edu/~i109/Notes/COperatorPrecedenceTable.pdf */
	switch (type)
	{
		/* TK_DEC, TK_HEX, TK_REG have the highest priority */
		case TK_DEC:
		case TK_HEX:
		case TK_REG:
			return 0;
		case '(':
		case ')':
			return 1;
		case TK_DEREF:
			return 2;
		case '*':
		case '/':
			return 3;
		case '+':
		case '-':
			return 4;
		case TK_EQ:
		case TK_NE:
			return 7;
		case TK_AND:
			return 11;
		case TK_OR:
			return 12;
		default:
			assert(0);
	}
};

int main_op(int p, int q)
{
	int tmp = p;
	int loc = p;

	while (p <= q)
	{
		if (tokens[p].type == TK_DEC ||
			tokens[p].type == TK_HEX ||
			tokens[p].type == TK_REG)
			p++;
		else if (tokens[p].type == '(')
		{
			/* operator within () can't be main op */
			/* nested : (2 * 3 - (4) + ((10 / 3) - 2)) */
			int n = 1;
			p++;

			while (p <= q && n > 0)
			{
				/* n >= 0 (x) */
				if (tokens[p].type == '(')
					++n;
				else if (tokens[p].type == ')')
					--n;
				// printf("n = %d\n", n);
				++p;
			}
			/* always match --> n === 0 */
			assert(n == 0);
		}
		else
		{
			/* the first operator */
			if (loc == tmp)
				loc = p;
			else
			{
				/* TODO: the precedence is static, and we can store it */
				int src =  op_pre(tokens[loc].type);
				int dest = op_pre(tokens[p].type);

				/* dereference : unary operator */
				if (dest >= src)
					loc = p;
			}
			++p;
		}
	}

	return loc;
};

word_t eval(int p, int q)
{
	/* for example, "()" >>> check_parentheses() >>> eval(p, p - 1) */
	assert(p <= q);

	if (p == q)
	{
		switch (tokens[p].type)
		{
			case TK_DEC:
				/* <stdlib.h> atoi -- ascii to integer */
				return atoi(tokens[p].str);
			case TK_HEX:
				unsigned int tmp;
				sscanf(tokens[p].str, "%x", &tmp);
				return tmp;
			case TK_REG:
				bool success;
				return isa_reg_str2val(tokens[p].str, &success);
			default:
				assert(0);
		}
	}
	else if (check_parentheses(p, q) == true)
		return eval(p + 1, q - 1);
	else
	{
		int op = main_op(p, q);
		word_t lv = (tokens[op].type == TK_DEREF) ? 0 : eval(p, op - 1);
		word_t rv = eval(op + 1, q);
		/* e.g "(5 - 1)(2 * 3)" */

		switch (tokens[op].type)
		{
			case TK_DEREF:
				/* read from memory */
				/* vaddr_read(rv, 8) */
				return vaddr_read(rv, 4);
			case '+':
				return lv + rv;
			case '-':
				return lv - rv;
			case '*':
				return lv * rv;
			case '/':
				/* TODO: x / 0 ??? */
				return lv / rv;
			case TK_EQ:
				return lv == rv;
			case TK_NE:
				return lv != rv;
			case TK_AND:
				return lv && rv;
			case TK_OR:
				return lv || rv;
			default:
				/* illegal  */
				assert(0);
		}
		return 0;
	}
};

word_t expr(char *e, bool *success) {
	if (!make_token(e)) 
	{
		*success = false;
		return 0;
	}

	/* default 'true' */
	*success = true;
	/* unary operator: dereference / minus(-) */
	for (int j = 0; j < nr_token; ++j)
	{
		if (j == 0 && tokens[j].type == '*')
			tokens[j].type = TK_DEREF;
		else if (tokens[j].type == '*' && op_pre(tokens[j].type) >= 3)
			tokens[j].type = TK_DEREF;
	}

	return eval(0, nr_token - 1);
};
