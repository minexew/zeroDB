zeroDB = zeroDB or {}
zeroDB.settings = {}

zeroDB.ui = {
    frame_cache = {}
}

function zeroDB.OnLoad()
    this:RegisterEvent("VARIABLES_LOADED");
end

function zeroDB.OnEvent()
    if (event == "VARIABLES_LOADED") then
        zeroDB_settings = zeroDB_settings or {}
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

function zeroDB.ui.get_frame_from_cache_or_create(type, frame_name, index)
    local name = frame_name..index
    local frame = zeroDB.ui.frame_cache[name]

    if not frame then
        frame = CreateFrame(type, name, nil, frame_name)
        zeroDB.ui.frame_cache[name] = frame
    end

    return frame, name
end
