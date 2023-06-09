# Prerequisites
* MOS/VDP 1.0.3
* ZDS II 5.3.5 C compiler

# Game Details
* Runs in MODE 3
* Player controls the snake movement with cursor keys
* 10 levels in total
* To complete a level, the snake should eat all the apples on the level
* Each level has 20 apples by default; this can be changed via **-apl** command-line parameter, e.g. ***run . -apl 10***
* The game starts from level 1; this can be changed via **-level** command-line parameter, e.g. ***run . -level 3***
* Movement speed can be controlled via **-delay** command-line parameter, e.g. ***run . -delay 100*** (smaller delay value results in faster movement)
* Every apple eaten by the snake adds 10 points to the score and increases snake lenght by 1. Collision with wall/snake costs -50 points. Skipping the level after a colision costs another 100 points

# Author
Ilian Iliev (***eztrophy*** in Discord)
email: eztrophy@gmail.com
