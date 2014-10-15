
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



static uint64_t 	chunks;
static uint64_t 	chunkLen;


size_t rkchunk(uint8_t *in, uint64_t len);




int main(int argc, char **argv)
{
    int		 	i;
    uint8_t 		*buf;

    for (i = 1; i < argc; i++) {
	int		fd;
	struct stat	statbuf;

	if (!(fd = open(argv[i], O_RDONLY)) || fstat(fd, &statbuf)) {
	    fprintf(stderr, "No read '%s\n", argv[i]);
	}
	buf = malloc(statbuf.st_size);
	//for (uint64_t i = 0; i < statbuf.st_size; i++)
	//{
	//	    buf[i] = rand() % 256;
	//	}
	int r = read(fd, buf, statbuf.st_size);
	printf("read '%s' %d bytes\n", argv[i], r);

	chunks = 0;
	chunkLen = 0;

	struct timeval start, end;
	gettimeofday(&start, 0);
	size_t off = 0; 
	while (off < statbuf.st_size) {
	    size_t ret = rkchunk(buf + off, statbuf.st_size - off);
	    chunks++;
	    chunkLen += ret;
	    printf("Chunk at offset %7lu, len %4lu\n", off, (unsigned long)ret);

	    off += ret;
	}
	gettimeofday(&end, 0);

	float tDiff = end.tv_sec - start.tv_sec;
	tDiff += (float)(end.tv_usec - start.tv_usec) / 10000000.0;

	printf("%s:\n\tChunks %llu, Avg Chunk %llu\n", argv[i], chunks, chunkLen / chunks);
	printf("\tTime %3.3f, Speed %3.2fMB/s\n\n", tDiff, 1024.0 / tDiff);
	free(buf);
    }
}

