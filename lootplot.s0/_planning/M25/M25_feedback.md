

# MID-2025 FEEDBACK DOC:
(BETA v3.0.2 FEEDBACK)

#### KEY:
(C) = Has been converted into a task in `M25_sprint` file
(?) = Too nebulous / havent decided what to do about this yet
(X) = Wont-fix

------------------------------------------------------------



- Tutorial-cat should be forced onto the player
--> (C) Lock starter items



- Victory-shockwave juice should be better!
--> (C) nemene suggestion: Make victory-shockwave a flat-color: fade looks weird


- (C) Zomebody: Muting SFX doesnt actually work! (if SFX is 0, sound still plays)


- Zomebody: Why do i have to click an item to see its shape. why cant i just see its shape when i hover it?



- (?) Sheepollution: Some items are kinda confusing when beginning
--> (C) Lock items behind metaprogression system



- (C) Sheepollution/Michael/Zomebody: 
Confused as to why the Pulse-button subtracted 10.
--> (C) In the tutorial, maybe it should say: "Bonus is reset after the pulse is done"


- (?) Michael: Wasn't able to use BONUS with reroll-items.
--> (X) Maybe we should reset Bonus at the start of the PULSE, as opposed to before.



- (C) Michael: "Wildcard shards should cost WAY more"
--> Make them cost $8 instead?


- (C) Michael: He isnt checking every item in the shop.
(I think its just a bit too overwhelming?)
--> Lets make the shop smaller? 2 normal shop-slots, 1 weak shop-slot?


- (C) Michael: "Boomerangs are OP!"
--> Nerf boomerangs a bit. (4 x 1 points maybe?)


- (C) Michael: "Rotate feels hard to get into"
--> Add more early-game opportunities for REROLL?
--> Make `orange` item UNCOMMON? Or even COMMON?



- MICHAEL OVERVIEW: 
- Super obsessed with shards (?)
- Never purchased sacks
- Frustrated with getting too many keys
- Frustrated with not having enough slots <--- make slots easier to generate?
- VERY FRUSTRATED WITH NOT BEING ABLE TO USE KEYS!!!
^^^ need more key-items to use


- (C) Michael: BUG:
"YOU WIN" text is black when space-background is active


- Michael: annoyed with his doomed-LEGENDARY item getting destroyed instantly
--> SOLUTION: Set activations of spawned DOOMED items to 0.
(Hardcode in base lootplot?)


- (C) Michael: 
Confused as to what target-shape is.

- Michael: Floaty-description is confusing
--> Change to: "FLOATY: This item can sit outside of slots"


- (C) Michael: When lining up shards, confused as to why they didn't combine instantly.
--> IDEA: Have shards combine using `onUpdate`. That way, we can have a juicy animation when the player places them down. Also, it's instant.


- Sheepollution: Didn't understand treasure-sacks
--> Don't allow sacks to be placed on normal-slots; (must be placed floating)
--> IDEA: Add shapes to sack-items.
--> IDEA: To balance it, make cloud-slots destroy diagonally too. This makes it a lot more balanced for bishop/knight shapes

- Matt: Didn't understand treasure-sacks
--> Put something in the description, saying: "only works when floating"


- (C) Sheeppollution: Didn't understand what "items" and "slots" were.
--> Create tutorial-part explaining items/slots, and that you can move items.


- Sheeppollution: When moving mouse, item-descriptions get in the way
--> (Maybe add a delay?)


