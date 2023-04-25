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

#include "sdb.h"
#include <limits.h>

#define NR_WP 32

typedef struct watchpoint {
	int NO;
	struct watchpoint *next;
	/* TODO: Add more members if necessary */
	char expr[32];
	word_t last;
} WP;

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
	for (int i = 0; i < NR_WP; i ++) {
		wp_pool[i].NO = i;
		wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
	}
	head = NULL;
	free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */

void new_wp(char *expr)
{
	if (free_ == NULL)
	{
		printf("The watchpoint pool is full\n");
		return;
	}

	WP *cur = free_;
	free_ = free_->next;
	cur->next = NULL;

	if (head == NULL)
		head = cur;
	else
	{
		WP *tmp = head;
		while (tmp->next)
			tmp = tmp->next;
		tmp->next = cur;
	}
	
	strcpy(cur->expr, expr);
	cur->last = UINT_MAX;
	printf("Hardware watchpoint %d: %s\n", cur->NO, cur->expr);
};

void free_wp(int NO)
{
	if (head == NULL)
	{
		printf("Warning: the watchpoint pool is empty\n");
		return;
	}
	
	// dummy head node
	WP *dummy = (WP *)malloc(sizeof(WP));
	dummy->next = head;

	WP *tmp = dummy, *wp = NULL;
	while (tmp->next && tmp->next->NO != NO)
		tmp = tmp->next;
	
	if (tmp->next == NULL)
	{
		printf("Warning: the watchpoint is not set\n");
		return;
	}

	wp = tmp->next;
	tmp->next = wp->next;

	wp->next = NULL;
	wp->last = UINT_MAX;


	if (free_ == NULL)
		free_ = wp;
	else
	{
		tmp = free_;
		while (tmp->next)
			tmp = tmp->next;
		tmp->next = wp;
	}
	free(dummy);
};

bool check_wp(void)
{
	WP *tmp = head;
	while (tmp)
	{
		bool success;
		word_t ret = expr(tmp->expr, &success);
		if (tmp->last == UINT_MAX)
			tmp->last = ret;
		else if (tmp ->last != ret)
		{
			printf("Old value = %lu\n", tmp->last);
			printf("New value = %lu\n", ret);
			return true;
		}
		tmp = tmp->next;
	}
	return false;
};
