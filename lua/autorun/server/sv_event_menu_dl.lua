-- Add FastDL for event_menu_pers images
if SERVER then
    local function AddEventMenuImagesToFastDL()
        local files, _ = file.Find("materials/event_menu_pers/*.jpg", "GAME")
        if files then
            print("[EventMenu] FastDL: Adding " .. #files .. " images to download list.")
            for _, filename in ipairs(files) do
                resource.AddFile("materials/event_menu_pers/" .. filename)
            end
        else
            print("[EventMenu] FastDL: No images found in materials/event_menu_pers/")
        end
    end

    AddEventMenuImagesToFastDL()
end
