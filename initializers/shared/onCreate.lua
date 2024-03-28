


local createGroup = umg.view("onCreate")

createGroup:onAdded(function(ent)
    ent:onCreate()
end)

