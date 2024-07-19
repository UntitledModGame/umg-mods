

components.project("text", "drawable")
--[[

TODO:
Should this be inside the text mod?
do some thinking....

]]


umg.on("rendering:drawEntity", function(ent, x,y, rot, sx,sy)
    if ent.text then
        local text = ent.text
        if text.RichText:isInstance(textString) then
            
        else
            
            
        end
    end
end)

