#!/bin/bash

module load cv-standard
module load gcc/4.9.3
module load intel/compiler/64/2016.3.210
module load intel/mpi/64/2016.3.210

mpiicc -o mpi.x mpi.c

