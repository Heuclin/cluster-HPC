#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
#include <sched.h>

/************************************************************
 *  * This is a simple hello world program. Each processor prints out
 *   * it's rank and the size of the current MPI run (Total number of
 *    * processors).
 *     * ************************************************************/
int main(int argc, char* argv[])
{
    /* communicator info */
    int myid = 0;
    int numprocs = 0;
    /* CPU info */
    int cpuid = 0;
    /* processor name info */
    char name[MPI_MAX_PROCESSOR_NAME];
    int len = 0;

    /* get cpu info */
    cpuid = sched_getcpu();

    /* init mpi and get info from communicator */
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &myid);

    /* get processor name */
    MPI_Get_processor_name(name, &len);

    /* print out my rank and this run's PE size*/
    if(myid == 0)
        printf("Format is :\n[RANK/NUMPROCS - CPUID/NAME]\n");
    printf("[%02d/%02d - [%02d/%s] - Hello !\n", myid, numprocs, cpuid, name);

    MPI_Finalize();

    return 0;
}

