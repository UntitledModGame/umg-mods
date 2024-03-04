


if client then

-- checks if something is a control or not
typecheck.addType("control", function(x)
    return input.isControl(x), "expected control, eg: `key:a`"
end)

end


