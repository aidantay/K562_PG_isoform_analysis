#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports

# External imports

# Internal imports
from .common import getExons
from .common import getTranscripts
from .common import getGeneTranscriptPairs

from .transcript import dropDuplicates
from .transcript import explodeDuplicates
from .transcript import getASTranscripts
from .transcript import removeSingleTranscriptGenes

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

#------------------- Private Classes & Functions ------------#


#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
