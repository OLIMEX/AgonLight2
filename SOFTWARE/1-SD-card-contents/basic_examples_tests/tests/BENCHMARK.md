# benchmarks

Tested using the [Rugg/Feldman (PCW) benchmarks](https://en.wikipedia.org/wiki/Rugg/Feldman_benchmarks#:~:text=This%20expanded%20set%20became%20known,many%20computer%20magazines%20and%20journals.)
 
|   | Agon Light | Spectrum Next|  Cerberus | BBC Micro |        Mega65 |       C64 |       Spectrum |
|---|-----------:|-------------:|----------:|----------:|--------------:|----------:|---------------:|
|   |  BBC BASIC |    BBC BASIC | BBC BASIC | BBC BASIC |      BASIC 65 | BASIC 2.0 | Sinclair BASIC |
|   |    eZ80F92 |   Z80 (FPGA) |       Z80 |      6502 | 45GS02 (FPGA) |      6510 |            Z80 |
|   |  18.432Mhz |        28Mhz |      8Mhz |      2Mhz |       40.5Mhz |  0.985Mhz |         3.5Mhz |
| 1 |     0.050s |        0.16s |     0.42s |      0.8s |        0.040s |     1.35s |           4.4s |
| 2 |     0.220s |        0.66s |     1.82s |      3.1s |        0.166s |     9.48s |           8.2s |
| 3 |     0.650s |        2.08s |     5.78s |      8.1s |        0.302s |    18.02s |          20.0s |
| 4 |     0.733s |        2.30s |     6.40s |      8.7s |        0.335s |    19.88s |          19.2s |
| 5 |     0.800s |        2.64s |     6.84s |      9.0s |        0.387s |    21.47s |          23.1s |
| 6 |     1.150s |        3.56s |     9.84s |     13.9s |        0.674s |    31.98s |          53.4s |
| 7 |     1.168s |        5.12s |    14.16s |     21.1s |        1.036s |    50.50s |          77.6s |
| 8 |     0.183s |        0.61s |     1.68s |      5.0s |        0.065s |    12.43s |          23.9s |

### NB:
- Test 8 is just the time to run test 8, not the combined time of test 7 and 8
- The Spectrum Next tests were tested on a MisterFPGA running the Spectrum Next core