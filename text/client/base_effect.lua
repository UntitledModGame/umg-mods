return function()
    text.addEffect("color", function(args, characters)
        local color = objects.Color(args.r or 1, args.g or 1, args.b or 1, args.a or 1)

        for _, char in ipairs(characters) do
            char:setColor(color)
        end
    end)

    text.addEffect("i", function(args, characters)
        local skewness = args.skew or 1

        for _, char in ipairs(characters) do
            char:setShear(-skewness / 4, 0)
        end
    end)
end
