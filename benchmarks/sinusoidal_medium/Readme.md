# Sinusoidal Large
Sinusoidal test case parameters to occupy a significant amount of memory while
being relatively square in X-Y.
Attempts to fill 50% of the recommended maximum memory allocation of 168 GiB on
the UArizona Ocelote HPC system.

* Sinusoidal Parameters:
  + Number Cells X: 3500
  + Number Cells Y: 3741
  + Number Cells Z: 5
* Observed metrics (On Ocelote with 2 timesteps and (1,1,1) process topology):
  + Memory Occupation: 84.02 GiB (88096660 KiB) (50.01% of Ocelote recommended
    maximum memory allocation)
  + Runtime: 00:14:12.66 (852.66 seconds)

The sinusoidal domain was adapted from the pfp4 test case from Stefan Kollet,
and was described as a weak scaling with periodic boundary condition.

To the best of my knowledge these are the publications that used the original
implementation of this domain:
1. Burstedde, C., Fonseca, J.A. & Kollet, S. Enhancing speed and scalability of
   the ParFlow simulation code. Comput Geosci 22, 347–361 (2018).
   https://doi.org/10.1007/s10596-017-9696-2

2. Sharples, Wendy, et al. "Best practice regarding the three P’s: profiling,
   portability and provenance when running HPC geoscientific applications."
   Geoscientific model development discussions 242.FZJ-2018-00203 (2017): 1-39.
