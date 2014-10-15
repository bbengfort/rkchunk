# rk.pyrk
# A Python implementation of the Rabin Karp chunking algorithm
#
# Author:   Benjamin Bengfort <benjamin@bengfort.com>
# Created:  Fri Oct 10 14:21:18 2014 -0400
#
# Copyright (C) 2014 Bengfort.com
# For license information, see LICENSE.txt
#
# ID: pyrk.py [] benjamin@bengfort.com $

"""
A Python implementation of the Rabin Karp chunking algorithm.
    http://en.wikipedia.org/wiki/Rabin%E2%80%93Karp_algorithm

Example usage:

    chunker = pyrk.new()
    offset  = 0
    while offset < size:
        ret  = rkchunk(data[offset:], size-offset)
        offset += ret
"""

##########################################################################
## Imports
##########################################################################

from libc.stdint cimport uint64_t

##########################################################################
## Module Constants
##########################################################################

cdef uint64_t HASHLEN  = 32
cdef uint64_t THEPRIME = 31
cdef uint64_t MINCHUNK = 2048
cdef uint64_t MAXCHUNK = 8192
cdef uint64_t TARGETCHUNK = 4096

##########################################################################
## Helper functions
##########################################################################

def new(**kwargs):
    """
    Similar interface to hashlib - create a new chunker with required
    settings like the prime to use or the target chunk, min/max size etc.
    """
    return RKChunker(**kwargs)

cdef unsigned int to_int64(unsigned int n) except -1:
    """
    Python integers or longs depend on the operating system that the app
    is running on; however ints and longs will expand forever. In order to
    properly do chunking we need to emulate unsigned 64 bit integers and
    this function performs the necessary conversion.
    """
    n = n & ((1 << 64) - 1)
    if n > (1 << 63) - 1:
        n -= 1 << 64
    return n & 0xffffffffffffffff

##########################################################################
## Rabin Karp Chunker
##########################################################################

cdef class RKChunker(object):
    """
    Maintains static variables for Rabin Karp chunking as well as hashlib-
    like windowing. Create a new instance for every file that you want to
    chunk and then continually call the function to get finger prints.
    """

    cdef uint64_t base
    cdef uint64_t powers[256]
    cdef uint64_t hashlen
    cdef uint64_t theprime
    cdef uint64_t minchunk
    cdef uint64_t maxchunk
    cdef uint64_t chunktgt

    def __init__(self, **kwargs):
        ## Individual configurations of the chunker
        self.hashlen  = kwargs.get('hashlen', HASHLEN)
        self.theprime = kwargs.get('theprime', THEPRIME)
        self.minchunk = kwargs.get('minchunk', MINCHUNK)
        self.maxchunk = kwargs.get('maxchunk', MAXCHUNK)
        self.chunktgt = kwargs.get('chunktgt', TARGETCHUNK)

    def __call__(self, char* data, unsigned int length):
        """
        Returns the size of the next chunk or 0. Continually call this
        function, updating the data and the length as new chunks are found.
        """
        if not self.base:
            self._compute_powers()

        offset, hashed = 0, 0
        while offset < self.hashlen and offset < length:
            # hashed = to_int64(hashed * self.base) + data[offset]
            hashed = hashed * self.base + data[offset]
            offset += 1

        while offset < length:
            # hashed = to_int64((hashed - self.powers[data[offset-self.hashlen]]) * self.base + data[offset])
            hashed = (hashed - self.powers[data[offset-self.hashlen]]) * self.base + data[offset]
            offset += 1

            if (((offset >= self.minchunk) and ((hashed % self.chunktgt) == 1)) or offset >= self.maxchunk):
                return offset

        return offset

    cdef _compute_powers(self):
        """
        Precomputes the powers array for faster computation
        """
        cdef uint64_t power = 1

        self.base = self.theprime
        for idx in range(self.hashlen-1):
            power *= self.base
            # power = to_int64(power)

        for idx in range(256):
            # self.powers[idx] = to_int64(idx * power)
            self.powers[idx] = idx * power

