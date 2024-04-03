

# Services:
We will have 1 "main" world context: 
`worldEnt`, which holds the world-plot, and holds all the context.

Also, every player will have 1 player-entity that they control

With this, we need services/APIs that interact 
with `worldEnt`s / `playerEnt`s.


### World-service:
```lua
lp.world.activateWorld(worldEnt)
lp.world.rerollWorld(worldEnt)

lp.world.isIdle(worldEnt)
-- returns true IFF there is nothing in the execution pipeline for the world.
```



### Points service:
NOTE:
The points-service DOESN'T STORE POINTS!!!!  
It just emits callbacks;  
`lootplot.main` (or other mods) will determine how the points are stored.  
(EG: in `lootplot.main`, points will be used to kill the loot-monster.)
```lua
lp.addPoints(ent, X)
lp.addPointMultiplier(ent, X)
```




### Money-service:
```lua
lp.addMoney(playerEnt, X)
lp.setMoney(playerEnt, X)
lp.getMoney(playerEnt)
```





<br/>
<br/>
<br/>

# Foreign service(s):

### Monster-service, By `lootplot.main` mod:
This provides the concept of "rounds":
```lua
monster.startRound()

-- callbacks:
umg.on("lootplot.main:endRound", f)
umg.on("lootplot.main:startRound", f)
```

