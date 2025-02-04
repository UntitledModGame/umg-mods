

lp.defineAttribute("ROUND", 1)
-- current round number

local ROUNDS_PER_LEVEL = 6
lp.defineAttribute("NUMBER_OF_ROUNDS", ROUNDS_PER_LEVEL)
-- The number of rounds allowed per level
-- (should generally be kept constant.)
-- if ROUND > NUMBER_OF_ROUNDS, lose.

lp.defineAttribute("REQUIRED_POINTS", -1)
-- once we reach this number, we can progress to next level.
-- (Default of -1 to indicate that this value MUST be changed!!!)


