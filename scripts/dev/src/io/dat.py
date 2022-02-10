#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports

# External imports

# Internal imports

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

def write(filepath, qIds):
    with open(filepath, "w") as fileHandle:
        fileHandle.write("Content-Type: application/x-Mascot; name=\"peptides\"" + "\n")
        for qId in qIds:
            fileHandle.write(qId + "\n")
        fileHandle.write("--gc0p4Jq0M2Yt08jU534c0p" + "\n")

#------------------- Private Classes & Functions ------------#

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
