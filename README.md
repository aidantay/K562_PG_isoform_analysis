# README #

This repository contains various scripts for the proteogenomic analysis of protein isoforms for K562 cells.

## Requirements ##

**Third-party tools**: Guppy, FastQC, BBTools, NanoPack, minimap2, Samtools, StringTie, HISAT2.

**Python environment**: python >= 3.7.0, pyspark >= 3.0.0. Alternatively, create the conda environment: `conda create env -f environment.yml`.

## Usage ##

**Long direct RNA-seq proteogenomic analysis**

```
. ont.sh
```
See scripts for more info.

---

**Short paired-end RNA-seq proteogenomic analysis**

```
. illumina.sh
```
See scripts for more info.

---

**Comparisons between long direct reads and short paired-end reads**

```
. compare_ont_illumina.sh
```
See scripts for more info.

---

## Contribution guidelines ##

The source codes are licensed under GPL less public licence. Users can contribute by making comments on the issues tracker, the wiki or direct contact via e-mail (see below).

## Contact ##

* Aidan Tay: a.tay@unswalumni.com
