return function()
    text.addEffect("color", function(args, char)
        local color = objects.Color(args.r or 1, args.g or 1, args.b or 1, args.a or 1)
        char:setColor(color)
    end)

    text.addEffect("i", function(args, char)
        local skewness = args.skew or 1
        char:setShear(-skewness / 4, 0)
    end)
end
