

## ===
# LUI REFACTOR
## ===



# LUI Scenes:

Should we keep LUI Scenes, 
or remove them?


## AMAZING IDEA:
Remove scenes, but add a "default scene" that is just a regular LUI Element.

So I guess we have a couple of main questions now.

- How do we determine the `view` of a top-level element?
- What the FUCK do we do about "focus" behaviour?







### View of top-level elements:
How should the size/position be determined for top-level elements?
- Should be left up to the implementor.







### Focusing:
"Focusing" is an amazingly helpful mechanism.
Text-boxes, inventory-slots; etc:
There are many elements that would need this kind of mechanism.

Maybe "Focusing" is a too specific manifestation of a more general phenomena.
Is there something simpler/better that we can use?

I think focusing is fine...
It adheres to KISS.
We can always change it in the future.

---
Implementation:
To implement focusing, we should allow `Element`s to have ONE (1)
child that is "focused".


