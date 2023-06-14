#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
	if (s == NULL || s[0] == '\0')
		return 0;

	/*  'size_t' can store the maximum size of a theoretically possible object of any type (including array). */
	size_t len = 1;
	while (s[len] != '\0')
		len++;

	return len;
}

char *strcpy(char *dst, const char *src) {
	/* dst != NULL && src != NULL */
	size_t j = 0;
	/* copying take place between objects that overlap => override */
	while (src[j] != '\0')
	{
		dst[j] = src[j];
		j++;
	}
	/* include the terminating null character */
	dst[j] = '\0';

	return dst;
}

char *strncpy(char *dst, const char *src, size_t n) {
	/* dst != NULL && src != NULL */
	size_t j = 0;
	while (j < n && src[j] != '\0')
	{
		dst[j] = src[j];
		j++;
	}
	/* the array pointed to by 'src' is a string, and its length is m(m < n) => append (n - m) '\0' */
	while (j < n)
	{
		dst[j] = '\0';
		j++;
	}
	return dst;
}

char *strcat(char *dst, const char *src) {
	/* dst[j] == '\0' */
	size_t j = strlen(dst);
	size_t k = 0;
	/* the initial character of 'src' overwrite the null character at the end of 'dst' */
	while (src[k] != '\0')
	{
		dst[j + k] = src[k];
		k++;
	}
	/* include the terminating null character */
	dst[j + k] = '\0';
	return dst;
}

int strcmp(const char *s1, const char *s2) {
	size_t j = 0;
	/* ascii code */
	while (s1[j] != '\0' && s2[j] != '\0')
	{
		if (s1[j] == s2[j])
			j++;
		else
			return s1[j] - s2[j];	
	}
	return s1[j] - s2[j];
}

int strncmp(const char *s1, const char *s2, size_t n) {
	size_t j = 0;
	while (j < n && s1[j] != '\0' && s2[j] != '\0')
	{
		if (s1[j] == s2[j])
			j++;
		else
			return s1[j] - s2[j];
	}
	return (j == n) ? 0 : s1[j] - s2[j];
}

void *memset(void *s, int c, size_t n) {
	/* c is converted into an unsigned char */
	unsigned char ch = c;
	unsigned char *p = s;
	/* fill one byte at a time */
	for (size_t j = 0; j < n; ++j)
		p[j] = ch;
	return s;
}

void *memmove(void *dst, const void *src, size_t n) {
	char tmp[n];
	char *_dst = (char *)dst;
	char *_src = (char *)src;
	/* first coped into a temporary array of n characters */
	for (size_t j = 0; j < n; ++j)
		tmp[j] = _src[j];
	for (size_t j = 0; j < n; ++j)
		_dst[j] = tmp[j];
	return dst;
}

void *memcpy(void *out, const void *in, size_t n) {
	char *_out = (char *)out;
	char *_in  = (char *)in;
	for (size_t j = 0; j < n; ++j)
		_out[j] = _in[j];
	return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
	unsigned char *_l = (unsigned char *)s1;
	unsigned char *_r = (unsigned char *)s2;

	size_t j = 0;
	while (j < n)
	{
		if (_l[j] == _r[j])
			j++;
		else
			return (int)(_l[j] - _r[j]);
	}
	return 0;
}

#endif
