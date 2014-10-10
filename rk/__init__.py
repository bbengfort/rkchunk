
HASHLEN  = 32
THEPRIME = 31
MINCHUNK = 2048
TARGETCHUNK = 4096
MAXCHUNK = 8192

def to_int64(n):
    n = n & ((1 << 64) - 1)
    if n > (1 << 63) - 1:
        n -= 1 << 64
    return n & 0xffffffffffffffff

class RKChunker(object):
    """
    Maintains static variables for rkchunking.
    """

    def __init__(self, base=0, **kwargs):
        self.base   = base
        self.powers = []

        ## Configurations of the chunker
        self.hashlen  = kwargs.get('hashlen', HASHLEN)
        self.theprime = kwargs.get('theprime', THEPRIME)
        self.minchunk = kwargs.get('minchunk', MINCHUNK)
        self.maxchunk = kwargs.get('maxchunk', MAXCHUNK)
        self.chunktgt = kwargs.get('chunktgt', TARGETCHUNK)

    def __call__(self, data, length):
        if self.base == 0:
            self._compute_powers()

        offset, hashed = 0, 0
        while offset < self.hashlen and offset < length:
            hashed = to_int64(hashed * self.base) + data[offset]
            offset += 1

        while offset < length:
            hashed = to_int64((hashed - self.powers[data[offset-self.hashlen]]) * self.base + data[offset])
            offset += 1

            if (((offset >= self.minchunk) and ((hashed % self.chunktgt) ==1)) or offset >= self.maxchunk):
                return offset

        return offset

    def _compute_powers(self):
        """
        Precomputes the powers array for faster computation
        """
        self.base = self.theprime
        power = 1
        for idx in xrange(self.hashlen-1):
            power *= self.base
            power = to_int64(power)

        for idx in xrange(256):
            self.powers.append(to_int64(idx * power))

def new():
    return RKChunker()
