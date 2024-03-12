


umg.on("health:entityDeath", function(ent)
    if ent.deathSound then
        local eds = ent.deathSound
        local name, vol = eds.name, eds.vol
        sound.playSound(name, vol)
    end
end)


umg.on("health:entityDamaged", function(ent)
    if ent.slime then
        sound.playSound("splat2", 0.15)
    end
end)


umg.on("projectiles:useShooter", function(holderEnt, item, shooter)
    sound.playSound("pew_main3", 0.6)
end)


