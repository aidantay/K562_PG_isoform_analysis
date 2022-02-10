#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports
import sys
import os
import argparse
from argparse import ArgumentParser
from argparse import ArgumentTypeError

# External imports

# Internal imports

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

class ArgParser(ArgumentParser):

    def __init__(self):
        ArgumentParser.__init__(self)

    def parse(self):
        pass

    def printArgs(self):
        args = self.parse_args()
        print(args)

    def isGTZeroInt(self, value):
        try:
            intValue = int(value)
            if (intValue <= 0):
                errMsg = "Invalid value. Must be > 0"
                raise ArgumentTypeError(errMsg)

        except (ArgumentTypeError, ValueError) as err:
            sys.exit(err)

        return intValue

    def isNumeric(self, value):
        try:
            floatValue = float(value)

        except (ValueError) as error:
            sys.exit(error)

        return floatValue

    def isFile(self, value):
        try:
            if (not os.path.exists(value) or os.path.isdir(value)):
                errMsg = "Invalid file:\t" + value
                raise ArgumentTypeError(errMsg)

        except ArgumentTypeError as err:
            sys.exit(err)

        return value

    def isDir(self, value):
        try:
            if (not os.path.exists(value) or not os.path.isdir(value)):
                errMsg = "Invalid dir:\t" + value
                raise ArgumentTypeError(errMsg)

        except ArgumentTypeError as err:
            sys.exit(err)

        return value

#------------------- Private Classes & Functions ------------#

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------

