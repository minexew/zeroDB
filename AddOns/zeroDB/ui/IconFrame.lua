
zeroDB = zeroDB or {}
zeroDB.IconFrame = {}

-- Thanks to Yatlas for this code
function zeroDB.IconFrame.BeingDragged()
    -- Thanks to Gello for this code
    local xpos,ypos = GetCursorPosition() 
    local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom() 

    xpos = xmin-xpos/UIParent:GetScale()+70 
    ypos = ypos/UIParent:GetScale()-ymin-70 

    zeroDB.IconFrame.SetPosition(math.deg(math.atan2(ypos,xpos)));
end

function zeroDB.IconFrame.OnClick()
    zeroDB.navigate.to{view = zeroDB.SpotlightFrame}
end

function zeroDB.IconFrame.OnEnter()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT");
    GameTooltip:SetText(zeroDB.strings['icon_tooltip_title']);
    GameTooltipTextLeft1:SetTextColor(1, 1, 1);
    GameTooltip:AddLine(zeroDB.strings['icon_tooltip_hint']);
    GameTooltip:Show();
end

function zeroDB.IconFrame.SetPosition(v)
    if(v < 0) then
        v = v + 360;
    end

    zeroDB.settings["IconPosition"] = v;
    zeroDB.IconFrame.UpdatePosition();
end

function zeroDB.IconFrame.UpdatePosition()
    local radius = zeroDB.settings["IconRadius"] or 78
    local position = zeroDB.settings["IconPosition"] or 25

    zeroDB_IconFrame:SetPoint(
        "TOPLEFT",
        "Minimap",
        "TOPLEFT",
        54 - (radius * cos(position)),
        (radius * sin(position)) - 55
    );
end
