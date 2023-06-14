#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
	/* 1 => common character, 0 => previous character is % */
	int state = 1;
	int j = 0;	// index for 'fmt'
	int k = 0;	// index for 'out'

	va_list args;
	va_start(args, fmt);

	while (fmt[j] != '\0')
	{
		if (state == 1)
		{
			/* don't write '%' into 'out' */
			if (fmt[j] == '%')
				state = 0;
			else
				out[k++] = fmt[j];

			++j;
		}
		else
		{
			switch (fmt[j])
			{
				case 'd': {
					int num = va_arg(args, int);
					/* INT_MAX =>  0x7fffffff => 2,147,483,647 => 10 digits */
					char buf[10];
					int top = -1;

					while (num)
					{
						buf[++top] = (num % 10) + '0';
						num /= 10;
					}
					
					while (top >= 0)
						out[k++] = buf[top--];
					
					break;
				}
				case 's': {
					char *str = va_arg(args, char *);

					for (int i = 0; str[i] != '\0'; ++i)
						out[k++] = str[i];

					break;
				}
				/* TODO: add more format string */
				default:
					out[k++] = fmt[j];
			}

			state = 1;
			j++;
		}
	}

	va_end(args);

	out[k] = '\0';
	return k;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
