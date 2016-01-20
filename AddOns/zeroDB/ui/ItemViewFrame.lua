
zeroDB = zeroDB or {}
zeroDB.ItemViewFrame = {
    DroppedBy = {},
    dropped_by_frame = {},
}

function zeroDB.ItemViewFrame.hide()
    zeroDB_ItemViewFrame:Hide()
    zeroDB_Tooltip:Hide()
end

function zeroDB.ItemViewFrame.get_dropped_by_frame(drop, index)
    local name = 'zeroDB_DroppedBy_Entry'..index
    local frame = zeroDB.ItemViewFrame.dropped_by_frame[name]

    if not frame then
        frame = CreateFrame('Button', name, nil, 'zeroDB_DroppedBy_Entry')
        zeroDB.ItemViewFrame.dropped_by_frame[name] = frame
    end

    local ref = drop[1]
    local chance = drop[2]

    local creature = zeroDB.get_object(ref)

    --local color = {1.0, 0.3, 0.3}
    --getglobal(name.."_Title"):SetTextColor(color[1], color[2], color[3])
    getglobal(name.."_Title"):SetText(creature.name)
    getglobal(name.."_Subtitle"):SetText(zeroDB.get_creature_subtitle(creature))

    local chance_str

    if chance < 0 then
        chance_str = -chance .. '%'
    else
        chance_str = chance .. '%'
    end

    getglobal(name.."_Right"):SetText(chance_str)

    getglobal(name.."_Icon"):SetTexture('Interface\\Icons\\Spell_Shadow_BlackPlague')

    frame.linked_object = creature
    return frame
end

function zeroDB.ItemViewFrame.show(nav)
    this = zeroDB_ItemViewFrame

    if not zeroDB.ItemViewFrame.DroppedBy.list_view then
        zeroDB.ItemViewFrame.DroppedBy.list_view = zeroDB.ListView:new{
            container = zeroDB_ItemViewFrame_DroppedBy,
            present_result = zeroDB.ItemViewFrame.get_dropped_by_frame,
            x = 5, y = 0, result_height = 42, spacing = 0, max_results = 10,
            no_results_frame = zeroDB_ItemViewFrame_DroppedBy_NoResults
        }
    end

    local item = nav.item
    zeroDB.ItemViewFrame.item_link = "item:"..item.id..":0:0:0"

    local color = zeroDB.db.item_qualities[item.quality].color
    zeroDB_ItemViewFrame_Title:SetTextColor(color[1], color[2], color[3])
    zeroDB_ItemViewFrame_Title:SetText(item.name)
    zeroDB_ItemViewFrame_ItemIcon:SetNormalTexture('Interface\\Icons\\'..item.icon)

    zeroDB.ItemViewFrame.DroppedBy.show(item)

    zeroDB_ItemViewFrame:Show()

    zeroDB.ItemViewFrame.show_tooltip()
    zeroDB_Tooltip:SetHyperlink(zeroDB.ItemViewFrame.item_link)
    zeroDB_Tooltip:Hide()
end

function zeroDB.ItemViewFrame.show_tooltip()
    this = zeroDB_ItemViewFrame

    zeroDB_Tooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT", 0, 500)
    zeroDB_Tooltip:SetHyperlink(zeroDB.ItemViewFrame.item_link)
    zeroDB_Tooltip:SetBackdropBorderColor(0, 0, 0, 1)
end

-------------------

function zeroDB.ItemViewFrame.DroppedBy.show(item)
    local results = zeroDB.db.items_dropped_by[item.id] or {}
    local num_results = table.getn(results)

    zeroDB.ItemViewFrame.DroppedBy.list_view:build(results, num_results)
end
