
import os
import time
import argparse

from rk import rk

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("src", nargs=1, type=str)
    args = parser.parse_args()

    size = os.path.getsize(args.src[0])
    with open(args.src[0], 'r+b') as f:
        # data = bytearray(f.read())
        data = f.read()

    print "read '%s' %d bytes" % (args.src[0], size)

    chunks   = 0
    chunklen = 0
    start    = time.time()
    offset   = 0
    rkchunk  = rk.new()

    while offset < size:
        ret  = rkchunk(data[offset:], size-offset)
        chunks += 1
        chunklen += ret

        print "Chunk at offset %7d, len %4d" % (offset, ret)

        offset += ret

    finit    = time.time()
    delta    = finit - start

    print "%s:\n\tChunks %d, Avg Chunk %d" % (args.src[0], chunks, chunklen/float(chunks))
    print "\tTime %0.3f seconds, Speed %0.3fMB/s\n" % (delta, 1024.0/delta)
