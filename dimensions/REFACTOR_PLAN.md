

# dimensions refactor plan:


## refactor position passing:

IDEA: Instead of passing `x,y,z,dimension` into every function manually,
how about we create a `dimensionVector` object of the following shape:
```lua
{
    x: number,
    y: number,
    dimension: string?
    z: number? 
}
```
that way, we can pass positions/dim values around more easily.
AND WHATS BETTER:
Is that if we don't want to allocate an object, we can simply pass in
the entity instead!!! (Amazing.)



