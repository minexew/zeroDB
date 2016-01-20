zeroDB = zeroDB or {}
zeroDB.settings = {}

function zeroDB.OnLoad()
    this:RegisterEvent("VARIABLES_LOADED");
end

function zeroDB.OnEvent()
    if (event == "VARIABLES_LOADED") then
        if not zeroDB_settings then
            zeroDB_settings = {}
        end

        zeroDB.settings = zeroDB_settings

        if zeroDB.settings["IconPosition"] == nil then
            zeroDB.settings["IconPosition"] = 270
        end

        if zeroDB.settings["IconRadius"] == nil then
            zeroDB.settings["IconRadius"] = 78
        end

        zeroDB.IconFrame.UpdatePosition();
    end
end
