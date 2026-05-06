/*
# =============================================================================
# Copyright (c) 2016 - 2021 Blue Brain Project/EPFL
#
# See top-level LICENSE file for details.
# =============================================================================.
*/

#pragma once

#include <stdio.h>
#include <musa_runtime_api.h>

// From Random123 lib
#define CHECKLAST(MSG)                             \
    do {                                           \
        musaError_t e = musaGetLastError();        \
        if (e != musaSuccess) {                    \
            fprintf(stderr,                        \
                    "%s:%d: MUSA Error: %s: %s\n", \
                    __FILE__,                      \
                    __LINE__,                      \
                    (MSG),                         \
                    musaGetErrorString(e));        \
            exit(1);                               \
        }                                          \
    } while (0)
#define CHECKCALL(RET)                                                                             \
    do {                                                                                           \
        musaError_t e = (RET);                                                                     \
        if (e != musaSuccess) {                                                                    \
            fprintf(stderr, "%s:%d: MUSA Error: %s\n", __FILE__, __LINE__, musaGetErrorString(e)); \
            exit(1);                                                                               \
        }                                                                                          \
    } while (0)
