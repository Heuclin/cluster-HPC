#!/bin/bash

module load cv-standard
module load intel/compiler/64/2016.3.210
icc -qopenmp -o openmp.x openmp.c

