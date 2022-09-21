#!/bin/bash

module load cv-standard
module load intel/compiler/64/2016.3.210
module load intel/mpi/64/2016.3.210

mpiicc -qopenmp -o ompi.x ompi.c

