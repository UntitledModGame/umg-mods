

## VALID WAYS TO SCALE:

- Increase money, use rings
- Level up items
- self-scaling items (moon-knife, helmet)

^^^ It's very 1-dimensional. we need better ways to scale!

----

## IDEAL SCALING:
Very dynamic / hands-on:  
- The player constantly has to keep doing stuff and adapting

NOT REPETITIVE!!!
(afk-scaling is not interesting!!!)

Multiple ways to approach it.
There should never be strictly 1 best strategy.

Early-game items are still useful (somehow)
- See SAP example; 
- "when buy tier-1 unit, gain +1/1"
- "If item price is less than 5, destroy item, and buff self"

-----



## PROBLEM OF SCALING SPEEDS:
There are 2 "simple" scaling speeds:
- linear scaling:  +2 buff.   (y=2t)
- exp scaling: buff by 10%.   (y=1.1^t)

The "issue", is that these scaling methods scale at DRAMATICALLY DIFFERENT SPEEDS.

FUNCTION GROWTH ORDERING:
```
linear     (y=t) <--- WE HAVE THIS
linear-log (y=t log(t))
quadratic  (y=t*t)
cubic      (y=t^3)
exp        (y=2^t) <--- WE ALSO HAVE THIS.
```
But we don't have any scaling in the middle!!!  
Part of the reason is because its hard to naturally implement quadratic/cubic scaling.  
To implement quadratic scaling, the operation would look like this:
```
"Take the square root of X, add 1, and then square it.
Thats the new value"
```
Such a complex operation is not really possible to explain simply.

**SOLUTIONS:**
- Limit exp scaling, and be implement it with caution
- Provide quadratic-scaling without explaining HOW
- Provide limits for how "big" scaling can get (<-- KINDA FEELS BAD THO, people like big points)








## SCALING IDEAS:

- More buffing within the shop:
    - IE: “When target-item bought, gain +2 points”
- More scavenge/fiscal dependent buffing:
    - Only buff when has less than $10
    - Buff 1 point for every $10, (maximum of 10)

We also want more “scaling of scaling”.  For example:
- Buff item points-generated for 10% of current balance
- Buff item points-generated for 20% of this item's price

More price-scaling opportunities.
Currently, price is just a get-rich-quick scheme with lives.
- More opportunities for items with LOW price.  
    - EG: “if item is cheaper than $3, buff it +3 points”
- More reasons to NOT sell an item with high-price, just for profit.
- IDEA:::: Make price builds synergize with low-money builds???



