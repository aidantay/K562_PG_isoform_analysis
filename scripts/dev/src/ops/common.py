#!/bin/python

#------------------- Description & Notes --------------------#

#------------------- Dependencies ---------------------------#

# Standard library imports
import re
import itertools

# External imports
import pandas as pd

# Internal imports

#------------------- Constants ------------------------------#

#------------------- Public Classes & Functions -------------#

def sortExonStrList(exStrList):
    exStrList = [exonStrToTuple(e) for e in exStrList]
    exStrList = [(int(e[0]), int(e[1])) for e in exStrList]
    exStrList.sort(key=lambda x: x[0])
    exStrList = ["({}-{})".format(e[0], e[1]) for e in exStrList]
    return exStrList

def exonStrToTuple(e):
    return tuple(re.sub('[()]', '', e).split('-'))

def getStart(exStrList):
    s = sortExonStrList(exStrList)
    e = exonStrToTuple(s[0])
    return e[0]

def getEnd(exStrList):
    s = sortExonStrList(exStrList)
    e = exonStrToTuple(s[-1])
    return e[1]

def exonStrListToJunctionStrList(exStrList):
    exStrList = sortExonStrList(exStrList)
    exStrList = [exonStrToTuple(e) for e in exStrList]
    rJunStart = [ex[1] for ex in exStrList[:-1]]
    rJunEnd   = [ex[0] for ex in exStrList[1:]]
    rJunPos   = ["({}:{})".format(s, e) for s, e in zip(rJunStart, rJunEnd)]
    return rJunPos

def compareData(dataDict):
    ## Find combinations between each set
    ## * Combinations we want
    ## * Combinations we don't want
    numSets = len(dataDict.keys())
    tCombs  = [itertools.combinations(dataDict.keys(), i) for i in range(1, numSets + 1)]
    tCombs  = list(itertools.chain(*tCombs))
    fCombs  = [tuple(set(dataDict.keys()).difference(set(c))) for c in tCombs]

    ## Find the intersection and differences between each set
    r = [_getIntersection(dataDict, tc, fc) for tc, fc in zip(tCombs, fCombs)]

    ## Construct the table
    r = pd.DataFrame(r)
    r = r.fillna(False)
    r = r[[c for c in r.columns if c != 'Count'] + ['Count'] ]
    return r

def toSet(df, cols):
    l = df[cols].to_numpy().tolist()
    s = set(map(tuple, l))
    return s

#------------------- Private Classes & Functions ------------#

def _getIntersection(d, tc, fc):
    tSets = [d[f] for f in tc]
    fSets = [d[f] for f in fc]

    ## Find the intersection between the sets we want
    inSet = set.intersection(*tSets)

    ## Find the difference between the sets we don't want
    if (len(fSets) != 0):
        notIn = set.union(*fSets)
        inSet = inSet.difference(notIn)

    r = {f:True for f in tc}
    r['Count'] = len(inSet)
    return r

#------------------- Main -----------------------------------#

if (__name__ == "__main__"):
    main()

#------------------------------------------------------------------------------
