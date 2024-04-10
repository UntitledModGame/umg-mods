


## SLOTS:
Do we need these functions...?
Hmm... maybe we should keep some of them..?

But I also think that some of them should be global helpers instead
```lua
function slots.canAdd()
function slots.tryAdd()
function slots.canRemove()
```

OK.
lets think: How would we implement a slot that can only take {trait} items?

Definitely should be emitting a question.
I guess the question is:
WHERE should we emit said question from?
This is what this file would be great for.

Do we want to allow blocking of removal..?
I feel like thats a bit weird... idk

Are there any valid use-cases for blocking item-removal?
(Not really, I feel like!)




## UI planning:
(A)  in lootplot.base, as a generic scene for lootplot.
If mods wanna add to the scene, tag into some api deployed by lootplot.base

(B)  in lootplot.main. We would then add the "core buttons" directly inside of this scene.
DOWNSIDE: The "core-buttons" would need to be duct-taped on kinda jankily.

(C)  in some base-mod; like uibasics mod.
Tag into some uibasics API to add elements to the scene.

---

I was considering option-C for this...
But Xander recommended option-B.
I think option-B is the most assumptionless, tbh...

