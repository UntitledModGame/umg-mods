

# Clientside entities Juice refactor:

We have a couple of issues (or opportunities!) here:

- How do we determine whether an entity is rendered via pixel-perfect API
- How should we enforce usage of screen-space coords vs world coords...?


---

# Screen-space coords:
Idea: Use `screenX` and `screenY` variables
```lua
local screenDrawGroup = umg.group("screenX", "screenY", "drawable")
```



# Pixel-perfect API:
IDEATION: 

Perhaps we could have an extra layer object, `Renderer`, 
that is in charge of rendering ents. 

`Renderer` will contain a pixel-perfect canvas for pixel-rendering,
AND will also be able to render stuff to the main buffer (screen).

The idea is that ALL draw-functionality will work the same with
pixelated, AND non-pixelated entities.

IDEA: KISS- `pixelated` component
```lua
ent.pixelated = true
```



# Component-warping:
How do we deal with component-warping?

For example: In popups, we lerp upwards, based on the `timeElapsed`.
but... we can't really do that when it's a regular entity.

To solve this, we kinda gotta look at warping the values of components
manually.



# ParticleSystem burst emit:
How do we evoke "bursts" in ParticleSystems?
Obviously we could just call `:emit` on the particleSystem directly...
but that's kinda weird, because it's reaching INTO the component.

SOLUTION: KISS.
Change `.particles` component into a regular particleSystem.
From tehre, we can just call `ent.particles:emit(X)`





# Shockwaves:

So, we got the `circle` component being rendered well.
But, how should this work with the `shockwave` component...?

IDEA:
Maybe we don't even need a `shockwave` component!!!
Perhaps `juice.shockwave` could just create an entity with a growing circle,
and decreasing opacity.

OK; I think that ^^^ setup is quite beautiful.
But we need a few things:
- A way to track "lifetime" (DONE)
- A way to make the circle size scale with the lifetime 
    (function upon `circle` component?)
- Opacity needs to scale with lifetime 
    (fade component?)







# New Chat widget, to work with UI mod:
Message --> represents a singular message  
ChatBox --> represents the whole chat element.  

`ChatBox` contains multiple `ChatMessage`s.

Question:  
How should `ChatMessage`s be created?  
Perhaps we call `ChatBox:pushMessage(str)` or something....?
Internally, this would create a `ChatMessage` object.

For when we are "typing", how should we handle this?
We want to keep it as assumptionless/extensive as possible.  

IDEA: We implement the ChatBox to render the currentMessage.
This way, the `ChatBox` can render the currentmessage.
In the future, this would allow us to do stuff like spellcheck,
auto-complete, etc etc.

we push each character to the buffer manually,
and submit messages manually:
```lua
ChatBox:inputCharacter(char)

ChatBox:submitMessage() -- submits message (client presses `enter`)

ChatBox:openChat() -- opens chat (client presses `enter`)
ChatBox:closeChat() -- opens chat (client presses `enter`)

ChatBox:isChatOpen() -- checks whether box is open (or not)
```






<br/>
<br/>
<br/>
<br/>


# S0 REFACTOR:
- Remove Pulse-Button, DoomClock, and Levels/Rounds from `lootplot.singleplayer`
- Create `lootplot.s0` mod
- ^^^ put them in `lootplot.s0` instead

<br/>

```
s0.backgrounds

s0.bundle

{
    s0.content
    s0.starting_items
    s0.worldgen
    lootplot.singleplayer (Levels, rounds, tutorial-cat)
}
^^^ COMBINE INTO 1 MOD
```



<br/>
<br/>
<br/>
<br/>

## Destructive-archetype en-goodening:

- Remove golden-dagger; make normal-dagger earn money AND points

- Change skull:
ITEM: (UNCOMMON) Destroy items with Destroy trigger. Trigger Reroll on items with Reroll trigger. Cost $1 to activate



- ITEM: Paperclip:
Trigger BUY on items without buying them. Cost $5 to activate!


FUNNY IDEA:
Evil cat:  
On buy, pulse: subtract -5 mult
basePrice = -5


Steam achievements:
- need to somehow deploy an API from core umg
- Connect with umg base mods


## DELAY BUG:
The main question is:
If something happens, whose responsibility is it to add a delay?

I think it should be the responsibility of the action to space out delays ahead of itself,
And actions should NOT be responsible for placing delays behind itself.

EG: for Bonus-mechanism, bonus should put a delay in front of itself

#### THE PROBLEM:

AXE-BONUS:
(step-execution, delayBon, bonus, delay1)
^^^^ this is what axe-bonus wants (achieved via delay-last)
---->  
(step-execution, delay1, delayBon, bonus)
^^^ And *THIS* is what axe-bonus gets if we delay-first.

DOUBLE-UKULELE:
(step, delay, step, delay, step, delay)
^^^ this is what double-ukulele wants. (delay-first)
---->  
(step, (step, (step, delay), delay), delay)
^^^^ And *THIS* is what double-ukulele gets if we delay-last.

RUBY-BONUS:
(delay, step, delayBon, bonus) x repeated
^^^ this is what ruby wants
(step, delay, delayBon, bonus)
^^^ *THIS* can occur if we delay improperly.



### Whats happening currently??
UKE: (delay, step, delay, step, delay, step)
AXEBON: (delay, step, delayBon, bon) x repeat
RUBY: () x repeat



----

## TUTORIAL RUN:

Start with- 

iron spear
violin

2 shop-slots
1 food shop-slot

reroll-button

Slots that earn $1?



OK:
How do we do this?




