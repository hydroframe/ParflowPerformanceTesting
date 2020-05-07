# Sinusoidal Large
Sinusoidal test case parameters to mimic the Little Washita test domain grid.

* Sinusoidal Parameters:
  + Number Cells X: 41
  + Number Cells Y: 41
  + Number Cells Z: 50
* Observed metrics (On Ocelote with 2 timesteps and (1,1,1) process topology):
  + Memory Occupation: 95.0 MiB (97280 KiB) (0.06% of Ocelote recommended
    maximum memory allocation)
  + Runtime: 00:00:01.85

LW Reference (On Ocelote with 2 timesteps and (1,1,1) process topology):
+ Memory Occupation: 164.64 MiB (168588 KiB) (0.10% of Ocelote recommended
  maximum memory allocation)
+ Runtime: 00:00:21.19

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
