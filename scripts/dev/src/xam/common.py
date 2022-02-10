#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports
import re
import itertools

# External imports

# Internal imports

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

def getSoftClipCount(cigarString):
    totalSoftClips = 0;
    for clipMatch in re.findall("[0-9]+S", cigarString):
        baseMatch = re.match("([0-9]+)", clipMatch)
        numBases  = baseMatch.group(1)
        totalSoftClips = totalSoftClips + int(numBases)

    return totalSoftClips

def getHardClipCount(cigarString):
    totalHardClips = 0;
    for clipMatch in re.findall("[0-9]+H", cigarString):
        baseMatch = re.match("([0-9]+)", clipMatch)
        numBases  = baseMatch.group(1)
        totalHardClips = totalHardClips + int(numBases)

    return totalHardClips

def getMatches(mdTag):
    ## Split by deletions and remove
    mdList = re.sub("(\^[A-Z]+)", " \\1 ", mdTag).split(" ")
    mdList = [x for x in mdList if not re.match("\^[A-Z]+", x)]

    ## Remove mismatches
    mdList  = [re.sub("([A-Z]+)", " ", x).split(" ") for x in mdList]
    matches = list(map(int, itertools.chain(*mdList)))
    return matches

def getMismatches(mdTag):
    ## Split by deletions and remove
    mdList = re.sub("(\^[A-Z]+)", " \\1 ", mdTag).split(" ")
    mdList = [x for x in mdList if not re.match("\^[A-Z]+", x)]

    ## Remove runs of bases that are identical (i.e., matches)
    ## We do this in steps to account for the special format of the string
    mdList = [x for x in mdList if not re.match("^[0-9]+$", x)]
    mdList = [re.sub("([A-Z]+)", " \\1 ", x).split(" ") for x in mdList]
    mdList = [x for sublist in mdList for x in sublist if x is not '0']
    mdList = "".join(mdList)
    mdList = re.sub("([0-9]+)", " ", mdList).split(" ")

    ## Find mismatches
    mismatches = [x for x in mdList if x is not ""]
    return mismatches

def getInsertions(cigarString):
    insertions = []
    for insertionMatch in re.findall("[0-9]+I", cigarString):
        baseMatch       = re.match("([0-9]+)", insertionMatch)
        numBases        = baseMatch.group(1)
        insertions.append(int(numBases))
    return insertions

def getDeletions(cigarString):
    deletions = []
    for deletionMatch in re.findall("[0-9]+D", cigarString):
        baseMatch       = re.match("([0-9]+)", deletionMatch)
        numBases        = baseMatch.group(1)
        deletions.append(int(numBases))
    return deletions

def cigartuplesToGenomicCoordinates(ref_pos, cigartuples):
    rexStrList = []
    rStart     = int(ref_pos)
    rEnd       = rStart - 1

    for cType, cLen in cigartuples:
        ## Skip (i.e, exon-exon junction)
        if (cType == 3):
            if (rEnd < rStart):
                ## These are usually special cases where theres
                ## an insertion/clip somewhere within the exon-exon junction
                ## To account for this, we expand the exon-exon junction
                rStart = rEnd + cLen + 1
                rEnd   = rStart - 1
                print('rEnd less than rStart. Expanding junction.')
                print(str(ref_pos) + "\t" + str(cigartuples))
                print(str(rStart) + "\t" + str(rEnd))

            else:
                rex = "({}-{})".format(rStart, rEnd)
                rexStrList.append(rex)

                rStart = rEnd + cLen + 1
                rEnd   = rStart - 1

        else:
            ## Match or Deletion
            if (cType == 0 or cType == 2):
                rEnd += cLen

            ## Insertion, Hard or Soft clips
            elif(cType == 1 or cType == 4 or cType == 5):
                pass

            else:
                print(cType)
                print(cLen)
                raise NotImplementedError("Unknown cType")

    rex = "({}-{})".format(rStart, rEnd)
    rexStrList.append(rex)
    return rexStrList

#------------------- Private Classes & Functions ------------#

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
