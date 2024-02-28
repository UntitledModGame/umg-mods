




```mermaid

flowchart TD
    effects
    items




```

<br/>
<br/>
<br/>
<br/>
<br/>

```mermaid


flowchart TD
    effects --> items


```

<br/>
<br/>
<br/>
<br/>
<br/>

```mermaid


flowchart TD
    ownership --> effects
    ownership --> items


```


<br/>
<br/>
<br/>
<br/>
<br/>

```mermaid


flowchart TD
    subgraph items
        ItemHandle
    end
    effects --> equips
    items --> equips



```

```lua

local slot = 1

local handle = ent.inventory:generateHandle(slot)

handle:isValid()
handle:getItem()



ent.inventory:set()


```


