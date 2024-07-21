

# OK. New sound planning:

Let's start with the features that we definitely want:

We definitely want some unified questions and events 

```lua
umg.ask("sound:getVolume", soundName, source, ent)
umg.ask("sound:getSemitoneOffset", soundName, source, ent)

umg.ask("sound:shouldPreventSoundFromPlaying", soundName, source, ent)
-- we prevent this sound from being played?
-- (EG. cram-optimization)

umg.call("sound:transformSound", soundName, source, ent)
```

---


## DILEMMA: Pooling:
One of the main dilemmas is pooling.

When we have two systems/objs that need to keep access to a source object,
it gets a bit fragile to reuse the object.

UNLESS!! full control of the source is granted to the system that claims it?
That way if the system forgets to `.reuse(src)` it, 
there is no issue, because no one else has reference to it.
(it's just a regular source!)

Maybe we dont even need pooling...?



## DILEMMA: Source-SoundType duality:
- we store volume/effect stuff on the source.
- but we cant store tagging on sources!!!

it would be AMAZING if we could do this:
```lua
local source = sounds.getTemplateSource("my_file")
source:tag("sfx")
```

In general I'm a bit worried about just bloating the API.
maybe I'm overthinking though.

We could do this:
```lua
soundObj {
    source = ...
    soundName = ...
}

sounds.tag("soundName" or soundObj, "myTag")
```

Another thing that I'm not happy about:
```lua
umg.call("sound:transformSound", soundName, source, ent)
```
We pass both soundName and source into the event.
It just feels very bad.  
This would be solved if we passed a unified sound object:
```lua
umg.call("sound:transformSound", soundObj, ent)
```

DOWNSIDE OF HAVING `soundObj`: extra layer of bloat.


## Cram Optimization:
Another thing we must consider is cram optimization.

Consider a large amount of particles being emitted at the same world position.  
Before making any new particles; it would make sense to check if new particles are at the same position as the other crammed particles.

If they are, then we can probably just ignore the operation, because the player isn't going to notice if there are lots of them.

(The same could be done for sounds!)
If we have a KD tree, (2 dim space, 1 dim time, 1 dim of soundType,)
then we could check for cramming and apply the optimization.



## Weak refs:
Don't forget that we have weak references to work with!!!
(It's not actually that hacky, we just gotta be careful)



## Tagging through folder names:
let's say we have an asset:
`assets/sounds/sfx/explosions/explode1.wav`
```lua
for _, asset in iterateAllAssets() do
  local folders = getFolderSet(umg.getAssetDirectory(asset)) 
  -- folders: Set{sounds, sfx, explosions}
  if folders:has("sfx") then
    asset:tag("sfx")
  end
end
```
I like the idea of putting all the sound effects in one folder, 
and not worrying about needing to tag them properly.











## FINAL DRAFT API:
```lua
sound.play("sound1", {
    entity = ent,

    source? = loveSource
    volume? = 1.0,
    pitch? = 1.0,
    effects? = {effectlist},
    filter? = filter
})


source = sound.obtain("sound1") -- Receive Source from the pool.
-- `source` should be the ONLY reference to the source in the entire program!!!

sound.release(source) -- Send Source back to the pool

source = sound.getTemplate("sound1") -- Template


--[[
TODO: what to do about tagging?
]]

```













## FULL RESTART:
Sometimes, instead of perfecting an idea,
the best course of action is to destroy it.

Let's go back to basics:
What do we truly need from this API?

- Unified tag support
- Single source for event and question emission (sound.play)
- source/soundName cohesion




