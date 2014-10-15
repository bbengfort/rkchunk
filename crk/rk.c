
// http://en.wikipedia.org/wiki/Rabin%E2%80%93Karp_algorithm

#include <assert.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <time.h>
#include <unistd.h>



#define HASHLEN		32
#define	THE_PRIME	31
#define	MINCHUNK	2048
#define TARGETCHUNK	4096
#define	MAXCHUNK	8192



// init, returns size of next chunk, or 0
// caller continually calls, updating buf and len as new chunks are found
size_t rkchunk(uint8_t *buf, uint64_t len)
{
    int			i;
    uint64_t		hash = 0;
    uint64_t		off;
    uint64_t	 	b_n;
    static uint64_t 	b = 0;
    static uint64_t 	saved[256];



    if (!b) {
	b = THE_PRIME;

	b_n = 1;
	for (i = 0; i < (HASHLEN-1); i++) {
	    b_n *= b;
	}

	for (i = 0; i < 256; i++) {
	    saved[i] = i * b_n;
	}
    }

    for (off = 0; (off < HASHLEN) && (off < len); off++) {
        hash = hash * b + (uint64_t)buf[off];
    }

    while (off < len) {
	hash = (hash - saved[buf[off-HASHLEN]]) * b + buf[off];
	off++;

	if (((off >= MINCHUNK) && ((hash % TARGETCHUNK) == 1)) || (off >= MAXCHUNK))
	    return off;
    }
    return off;
}


