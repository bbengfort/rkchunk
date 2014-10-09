# tests
# Test module for the rkchunk library
#
# Author:   Benjamin Bengfort <benjamin@bengfort.com>
# Created:  Thu Oct 09 10:51:45 2014 -0400
#
# Copyright (C) 2014 Bengfort.com
# For license information, see LICENSE.txt
#
# ID: __init__.py [] benjamin@bengfort.com $

"""
Test module for the rkchunk library
"""

##########################################################################
## Imports
##########################################################################

import unittest

##########################################################################
## Initialization Tests
##########################################################################

class InitializationTests(unittest.TestCase):

    def test_sanity(self):
        """
        Check a simple world fact 1+2+3 == 6
        """
        self.assertEqual(1+2+3, 6)

    def test_import(self):
        """
        Can import the rk library
        """
        try:
            import rk
        except ImportError:
            self.fail("Could not import rk library")
