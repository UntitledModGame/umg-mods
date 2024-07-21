

# OK. New sound planning:

Let's start with the features that we definitely want:

We definitely want some unified questions and events 

```lua
umg.ask("sound:getVolume", soundName, source, ent)
umg.ask("sound:getSemitoneOffset", soundName, source, ent)

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















## API DRAFT: 
```lua
sound.defineTag("mod:tag1")

sound.tag("sound1", {"tag1", "tag2", ...}) -- "sound1" is the actual audio file
sound.untag("sound1", {"tag1", "tag2", ...})

sound.hasTag("sound1", "tag1")


sound.play("sound1", {
    entity = ent,

    source? = loveSource
    volume? = 1.0,
    pitch? = 1.0,
    effects? = {effectlist},
    filter? = filter
})


sound.stopAll(tag)
sound.stop("sound1")

source = sound.obtain("sound1") -- Receive Source from the pool
sound.release(source) -- Send Source back to the pool

source = sound.getTemplate("sound1") -- Template


```