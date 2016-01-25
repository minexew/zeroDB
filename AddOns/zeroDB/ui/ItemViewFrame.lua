
zeroDB = zeroDB or {}
zeroDB.ItemViewFrame = {
    DroppedBy = {},
    RewardFrom = {},
}

function zeroDB.ItemViewFrame.hide()
    zeroDB_ItemViewFrame:Hide()
    zeroDB_Tooltip:Hide()
end

function zeroDB.ItemViewFrame.get_dropped_by_frame(drop, index)
    local frame, name = zeroDB.ui.get_frame_from_cache_or_create('Button', 'zeroDB_DroppedBy_Entry',
        'zeroDB.ItemViewFrame.DroppedBy'..index)

    local creature_id = drop[1]
    local chance = drop[2]

    local creature = zeroDB.db.creatures[creature_id]

    --local color = {1.0, 0.3, 0.3}
    --getglobal(name.."_Title"):SetTextColor(color[1], color[2], color[3])
    getglobal(name.."_Title"):SetText(creature.name)
    getglobal(name.."_Subtitle"):SetText(zeroDB.get_creature_subtitle(creature))

    local chance_str

    if chance < 0 then
        chance_str = ''
    else
        chance_str = chance .. '%'
    end

    getglobal(name.."_Right"):SetText(chance_str)

    getglobal(name.."_Icon"):SetTexture('Interface\\Icons\\Spell_Shadow_BlackPlague')

    frame.linked_object = creature
    return frame
end

function zeroDB.ItemViewFrame.get_reward_from_frame(quest_id, index)
    local frame, name = zeroDB.ui.get_frame_from_cache_or_create('Button', 'zeroDB_DroppedBy_Entry',
        'zeroDB.ItemViewFrame.RewardFrom'..index)

    local quest = zeroDB.db.quests[quest_id]

    getglobal(name.."_Title"):SetText(quest.name)
    getglobal(name.."_Subtitle"):SetText(zeroDB.get_quest_subtitle(quest))
    getglobal(name.."_Right"):SetText('')

    getglobal(name.."_Icon"):SetTexture('Interface\\Icons\\INV_Letter_17')

    frame.linked_object = quest
    return frame
end

function zeroDB.ItemViewFrame.on_icon_click()
    local item = zeroDB.ItemViewFrame.item

    zeroDB.ui.paste_item_clink(item)
end

function zeroDB.ItemViewFrame.show(nav)
    this = zeroDB_ItemViewFrame

    if not zeroDB.ItemViewFrame.tab_view then
        zeroDB.ItemViewFrame.tab_view = zeroDB.TabView:new{
            tabs = {
                {zeroDB_ItemViewFrame_Tab_DroppedBy, zeroDB_ItemViewFrame_DroppedBy, title = 'DROPPED BY'},
                {zeroDB_ItemViewFrame_Tab_RewardFrom, zeroDB_ItemViewFrame_RewardFrom, title = 'REWARD FROM'},
                --{zeroDB_ItemViewFrame_Tab_ReagentFor, zeroDB_ItemViewFrame_ReagentFor, title = 'REAGENT FOR'},
            },
        }
    end

    if not zeroDB.ItemViewFrame.DroppedBy.list_view then
        zeroDB.ItemViewFrame.DroppedBy.list_view = zeroDB.ListView:new{
            container = zeroDB_ItemViewFrame_DroppedBy,
            present_result = zeroDB.ItemViewFrame.get_dropped_by_frame,
            x = 5, y = 0, result_height = 42, spacing = 0, max_results = 10,
            no_results_frame = zeroDB_ItemViewFrame_DroppedBy_NoResults
        }
    end

    if not zeroDB.ItemViewFrame.RewardFrom.list_view then
        zeroDB.ItemViewFrame.RewardFrom.list_view = zeroDB.ListView:new{
            container = zeroDB_ItemViewFrame_RewardFrom,
            present_result = zeroDB.ItemViewFrame.get_reward_from_frame,
            x = 5, y = 0, result_height = 42, spacing = 0, max_results = 10
        }
    end

    local item = nav.item
    zeroDB.ItemViewFrame.item = item
    zeroDB.ItemViewFrame.item_link = "item:"..item.id..":0:0:0"

    local color = zeroDB.db.item_qualities[item.quality].color
    zeroDB_ItemViewFrame_Title:SetTextColor(color[1], color[2], color[3])
    zeroDB_ItemViewFrame_Title:SetText(item.name)
    zeroDB_ItemViewFrame_ItemIcon:SetNormalTexture('Interface\\Icons\\'..item.icon)

    local has_dropped_by = zeroDB.ItemViewFrame.DroppedBy.show(item)
    local has_reward_from = zeroDB.ItemViewFrame.RewardFrom.show(item)
    local has_reagent_for = false

    local num_visible = zeroDB.ItemViewFrame.tab_view:set_visibility({has_dropped_by, has_reward_from, has_reagent_for})

    if num_visible == 0 then
        zeroDB_ItemViewFrame_NoData:Show()
    else
        zeroDB_ItemViewFrame_NoData:Hide()
    end

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
    local encoded_results = zeroDB.db.items_dropped_by[item.id] or {}
    local num_results = table.getn(encoded_results)

    if num_results == 0 then
        return false
    end

    local results = {}
    num_results = num_results / 2

    for i = 1, num_results do
        results[i] = {encoded_results[1 + (i - 1) * 2], encoded_results[2 + (i - 1) * 2]}
    end

    zeroDB.ItemViewFrame.DroppedBy.list_view:build(results, num_results)
    return true
end

function zeroDB.ItemViewFrame.RewardFrom.show(item)
    local results = zeroDB.db.items_reward_from[item.id] or {}
    local num_results = table.getn(results)

    if num_results == 0 then
        return false
    end

    zeroDB.ItemViewFrame.RewardFrom.list_view:build(results, num_results)
    return true
end
