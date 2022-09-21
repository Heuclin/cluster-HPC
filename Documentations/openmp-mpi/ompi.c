#define _GNU_SOURCE
#include <sched.h> //C API parameters and prototypes
#include <mpi.h>
#include <omp.h>
#include <stdio.h>
int
main(int argc, char **argv)
{
/* OpenMP ID */
int omp_id = 0;
int omp_nthreads = 0;
/* communicator info */
int myrank = -1;
int numranks = -1;
/* CPU ID */
int cpu_id = 0;
/* processor name info */
char name[MPI_MAX_PROCESSOR_NAME];
int len = 0;
/* MPI multithreading */
int required = MPI_THREAD_MULTIPLE;
int provided = 0;
/* init mpi and get info from communicator */
// MPI_Init_thread(&argc, &argv, required, &provided);
MPI_Init_thread(&argc, &argv, required, &provided);
MPI_Comm_size(MPI_COMM_WORLD, &numranks);
MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
if(provided < required)
{
if(myrank == 0)
{
printf("MPI does not support adequate multithreading level !\n");
}
#ifdef _OPENMP
omp_set_num_threads(1);
#endif // _OPENMP
}
/* get processor name */
MPI_Get_processor_name(name, &len);
#ifdef _OPENMP
#pragma omp parallel default(shared) private(omp_id, omp_nthreads, cpu_id)
#endif // _OPENMP
{
#ifdef _OPENMP
omp_id = omp_get_thread_num();
omp_nthreads = omp_get_num_threads();
#else
#warning NO OPENMP AVAILABLE
omp_id = myrank;
omp_nthreads = 0;
#endif // _OPENMP

cpu_id = sched_getcpu();
printf("thread %02d/%02d on cpu %02d MPI rank %02d numranks %02d name %s\n",
omp_id, omp_nthreads, cpu_id, myrank, numranks, name);
}
MPI_Finalize();
}
