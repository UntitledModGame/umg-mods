

## =====================================
# SPIKE TASKS:
(Ordered from most important --> least important)
## =====================================





## DESTRUCTIVE ITEMS::: SPIKE
These need some planning.  
Brainstorm the systems at play, and the intended playstyles at play.   
(SEE: `_DESTRUCTIVE_PLANNING.md`)  
```
    - ITEM:
    On destroy, generate 5 points 20 times  (great w/ bonus)

    - ITEM:
    On destroy, give +2.5 mult

    - ITEM:
    On destroy, give +200 points. (lives=60, price=-$2)
    (^^^^ I'm imagining the player lining up multiple shovels to proc this item)

    - ITEM: (Golden rocks)
    On Destroy, Rotate: 
    Set mult to 0
    Earn $1

    - ITEM: Clone-rocks
    If target item has DESTROY trigger, transform into it
    (^^^ THIS SHOULD BE UNCOMMON!!! this item is an AMAZING idea.)
    (more items like these please)

    - ITEM: Green rock:
    On Reroll, Destroy:
    Gives +3 bonus
    Gives +0.4 mult
    Steals 10 points

    - ITEM: Crimson rocks
    On Reroll, Destroy:
    Add mult equal to the current balance

    - ITEM: Muddy rocks
    On Rotate, Destroy:
    Add +0.5 mult
    Add +10 bonus
    (GRUB-10)

    - ITEM: Orange rock:
    On Rotate, Destroy:
    Earn +40 points
    Adds +1 mult
    Steals -2 bonus

    - ITEM: Anchor rock
    On Destroy:
    Set bonus to 0
    Earn 90 points

    - ITEM: Rock printer
    Adds +0.5 mult. Spawn clone-rocks. (shape=ABOVE-2)
```



## (((DONE))) (SPIKE: PLANNING)
- Rework shards to do something else
(Ideally, we want them to *NOT* destroy themselves when used, lmao)




## SPIKE: Items that provide keys
Alteratively- items that provide UNLOCK trigger.

## SPIKE: Items that use `UNLOCK` trigger
(Merge with LEVEL-UP / BUY triggers...?)

## SPIKE: More items that have `BUY` trigger?
(Merge with LEVEL-UP / UNLOCK triggers...?)

## SPIKE: Items that spawn "curses"; ie items that you want to get rid of.
- Create new Rarities:  `CURSE (I), CURSE (II), CURSE(III)`, in order from most tame -> least tame.
- Curse items cannot be moved.
- Use kettlebell-sprites as negative-points/mult/money modifiers.
logo-color determines potency.
Light-Green = points
Red = mult
Blue = bonus
Gold = money
--->
- ITEM: If there are more than 4 curses on the plot, earn $2
- ITEM: Black-shield: If target item is a curse, destroy it. Earn +1 mult.
- ITEM: When a curse is spawned, transform it into a magic-turnip
- ITEM: Devil deal: Earn $8. Spawn a random `CURSE(I)` curse somewhere on the plot.

- CURSE: Increase round by 1. DOOMED-1
- CURSE: On Reroll, lose 0.5 mult. (<--- provides anti-reroll archetype!)
- CURSE: When an item is destroyed, lose 15 points. KING-2. (<--- provides anti-destroy archetype!)
- CURSE: When an item is destroyed, lose $1. KING-2.
- CURSE: Make items STUCK. ROOK-1
- CURSE: On Pulse, trigger Pulse on other curses. KING-2.
- CURSE: On Destroy, On Pulse: Steal 10 points.
- CURSE: Evil Copycat: On Pulse: Copy self into target slots. Steal $0.3
--->  
IMPORTANT NOTE!!!  
When curses spawn, they should spawn with 0 activations.   
This ensures that they don't activate immediately in an unfair-fashion to the player.  
--->  
We should also encourage *limiting* the number of curses in existance.  
A few curses should be OK, but many curses should be a *BIG PROBLEM.*  
We can achieve this via an elegant solution:
- CURSE: Lose $1. If there are more than 4 curses, lose $2 extra.
- CURSE: Lose 10 points. If there are more than 4 curses, lose 50 points.
- CURSE: If there are more than 4 curses, spawn another curse.
- CURSE: On Level-Up: If there are more than 4 curses, spawn another curse.




## SPIKE: Items that add variance.
(see `E25_risk.md` for full notes)
- On LEVEL-UP: Spawn a null-slot. Spawn a random RARE item on the board, and make it STUCK.
- On LEVEL-UP, DESTROY: Spawns a random CURSE on the plot. Spawns a random RARE item somewhere on the plot.
- On Destroy: Spawns a random slot somewhere on the plot. (has 1 life)
- On Destroy: Spawn a random RARE item on the board, and make it DOOMED-5.




## Slot-destruction-spike:
Destroying slots is a great way to add more strategy as well (synergizes with glass/doomed tiles)    
--   
Perhaps we should consider adding items that listen to this?



## SPIKE:
Pineapple-ring is VERY VERY VERY fun to use.
Let's create more items like that, please!!!
Because It is honestly SO FUN.
Don't worry as much about balance. Just aim for fun. :)




## SPIKE: TROPHY ITEMS:
- Create "trophy" infrastructure.
Players kinda need a goal; the main "goal" should be to win with all starting-items.
However, we should also allow players to add their own goals, and run-modifiers.  
Thus, I propose a "Trophy system".  
Kinda like Isaac- Each starting-item will have a trophies to earn; they will start blacked-out,
but will be filled when the player completes a certain challenge.   
In the base-game ie `lootplot.s0`, there will only be 1 trophy: "Bronze-trophy: Beat level-10"
But we should support an arbitrary number of trophies for modding-purposes.  
NOTE: we DO NOT need explanations for what the trophies do!!! We just need the visuals.
- Create trophy API (lootplot.singleplayer)
- Make doomclock be spawned by GAMEMODE_ITEM (lootplot.singleplayer)
- Create basic bronze trophy (Trophies handled in lootplot.singleplayer)
- Make lootplot.worldgen API worldgen items spawn ALL of the items






## AETHER ITEMS SPIKE:
It would be cool to do something with these.  
These items look very otherwordly, and can probably be used for something very rule-bendy



## Anti-reroll mechanism SPIKE:
We need more anti-reroll stuff. Or else, reroll-archetype is gonna be ALL-ENCOMPASSING.
---->
One idea is to have items that trigger On-Reroll, and have negative-effects.  
But.... this doesn't really work, since the player can just destroy/remove the items.  
HOWEVER!  
What if we had *SLOTS* that were On-Reroll?  (Paper slot?)
EG:
```
Paper Slot: activates on Reroll
----
examples / opportunities:
Paper Slot: DOOMED-10  (can only be rerolled 10 times before dead)
Paper Slot: bonusGenerated = -1
Paper Slot: multGenerated = -0.1
Paper Slot: pointsGenerated = -10
Paper Slot: moneyEarned = -0.5
```
^^^ This is an excellent idea!!! :)  
And what's coolest, is that players can even game the system to make it *work WITH* reroll-archetype  
(ie by using mushrooms to buff the slots)  
---->  
The "hard bit" is deciding how to actually spawn the paper-slots.  
Do some thinking.  Make sure not to overdo it... we dont want to kill reroll-archetype;
we just want to make it a bit less "all-encompassing".
-->> ITEM IDEAS:
```
ITEM: (floaty, doomed-1)
Spawns a paper-slot with a key inside it

ITEM:
Spawns paper-slots.
```

