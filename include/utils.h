#pragma once
#include <ctype.h>
#include <errno.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>

#define ANSI_COLOR_RED "\x1b[31m"
#define ANSI_COLOR_GREEN "\x1b[32m"
#define ANSI_COLOR_YELLOW "\x1b[33m"
#define ANSI_COLOR_BLUE "\x1b[34m"
#define ANSI_COLOR_MAGENTA "\x1b[35m"
#define ANSI_COLOR_CYAN "\x1b[36m"
#define ANSI_COLOR_WHITE "\x1b[97m"

#define ANSI_BOLD "\x1b[1m"
#define ANSI_UNDERLINE "\x1b[4m"
#define ANSI_RESET "\x1b[0m"

#define CHK(op)                                                                                              \
    do                                                                                                       \
    {                                                                                                        \
        if ((op) == -1)                                                                                      \
            raler(1, ANSI_BOLD ANSI_COLOR_RED "Error on line %d in file %s with %s" ANSI_RESET, __LINE__,    \
                  __FILE__, __FUNCTION__);                                                                   \
    } while (0)

#define CHK_NULL(op)                                                                                         \
    do                                                                                                       \
    {                                                                                                        \
        if ((op) == NULL)                                                                                    \
            raler(1, ANSI_BOLD ANSI_COLOR_RED "Error on line %d in file %s with %s" ANSI_RESET, __LINE__,    \
                  __FILE__, __FUNCTION__);                                                                   \
    } while (0)

noreturn static inline void raler(int syserr, const char *format, ...)
{
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    if (syserr == 1)
        perror("");
    exit(EXIT_FAILURE);
}

static inline _Bool is_str_integer(const char *str)
{
    char *endptr;
    errno = 0;
    strtol(str, &endptr, 10);
    if (errno == ERANGE)
        return false;
    if (endptr == str)
        return false;
    for (; *endptr != '\0'; endptr++)
        if (!isspace(*endptr))
            return false;
    return true;
}

static inline _Bool is_str_float(const char *str)
{
    char *endptr;
    errno = 0;
    strtof(str, &endptr);
    if (str == endptr)
        return false;
    while (isspace((unsigned char)*endptr))
        endptr++;
    if (*endptr || errno)
        return false;

    // at this state we know that the string is a float
    // but we need to check if contains . because
    // apparently decimal numbers are considered as floats
    if (strchr(str, '.') == NULL)
        return false;
    return true;
}