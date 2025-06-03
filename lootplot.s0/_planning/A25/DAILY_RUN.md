

# daily run planning:

Ok. Lets aim to be HYPER pragmatic. 
There's real opportunity to make some super interesting stuff.

## HIGH LEVEL STEPS:

- Determine the layout
- Fill in the layout with slots+items
- Add extra modifiers 
    - (surrounded-stone, doomed/dirt?)
    - scatter auto-stone-slots in places
    - randomly give lives to slots
    - randomly give doomed to slots
    - randomly give buffs (points,mult,bonus) to slots
    (^^^^ DONT OVERDO IT!!! It shouldnt look cluttered)
- Spawn stone-hand curses, spawn injunction curse


## ==========================


## LAYOUT:
- shop-slots, food-shop-slots, reroll-button location
- main-island (we just need 1 center ppos, with a 5x5 leighway area)
- sell-slot(s) (we want between 1 and 3 sell-slots)
- special-slots location (null-slots, tax-button, etc etc)
- pulse/level button location

^^^ the question is, how do we actually organize this without overlap?
IDEA: Consider each letter as a region:
```
 ---B---
 M  M  M  
 ---S---     
```
- `B` is pulse/level buttons. (The whole `----` area is reserved for them)
- `M M M` are the "main" regions. (shop, main, special)
- `S` Sell slots. (The whole `----` area is reserved for them)

The idea is that the `M`s can be shuffled around in any order.
And even moved upwards/downwards.

What's even better, is that after ALL of this, we can normalize the coordinates w.r.t the center of the plot, and have a 50% chance to *transpose* the coords; and then a 50% chance to flip the coords.

This would give a wacky setup like:
```
  M     
S M B   
  M     
```
which is super unqiue and cool!!!





## FILLING-IN:
Shop-slots:
- Chance to spawn exotic-shop slots. Chance for doomed-shop-slots
- Chance for reroll-button to be cheaper. (Or doomed)
- Small chance to start with a random balloon

Main-island:
- Chance for dirt/gravel slots
- Chance diamond/golden/ruby/sapphire slot
- Chance for ONE rulebender/invincibility slot to spawn in the center

Special island:
- Cat slot
- Null-slots containing random foods/sacks
- Doomed income-slots



## Post-processing:
- Scatter dirt-slots/gravel slots? (randomly)
- Randomly spawn auto-stone-slots
- Scatter doomed-slots / glass-slots that earn money/points/bonus/mult?
- Scatter doomed-items in null-slots
- LESS IS MORE: Sometimes we shouldnt do anything!!!



