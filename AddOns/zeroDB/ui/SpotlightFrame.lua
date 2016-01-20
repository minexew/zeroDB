
zeroDB = zeroDB or {}
zeroDB.SpotlightFrame = {
    active_views = {},
    views = {},
}

function zeroDB.SpotlightFrame.get_result_frame_creature(index, creature)
    local name = 'zeroDB_SpotlightResultItem'..index
    local frame = zeroDB.SpotlightFrame.views[name]

    if not frame then
        frame = CreateFrame('Button', name, nil, 'zeroDB_SpotlightResultItem')
        zeroDB.SpotlightFrame.views[name] = frame
    end

    local color = {1.0, 1.0, 0.3}
    getglobal(name.."_ItemName"):SetTextColor(color[1], color[2], color[3])
    getglobal(name.."_ItemName"):SetText(creature.name)
    getglobal(name.."_ItemDesc"):SetText(zeroDB.get_creature_subtitle(creature))

    getglobal(name.."_Icon"):SetTexture('Interface\\Icons\\Spell_Shadow_BlackPlague')

    frame.linked_object = creature
    return frame
end

function zeroDB.SpotlightFrame.get_result_frame_item(index, item)
    local name = 'zeroDB_SpotlightResultItem'..index
    local frame = zeroDB.SpotlightFrame.views[name]

    if not frame then
        frame = CreateFrame('Button', name, nil, 'zeroDB_SpotlightResultItem')
        zeroDB.SpotlightFrame.views[name] = frame
    end

    local color = zeroDB.db.item_qualities[item.quality].color
    getglobal(name.."_ItemName"):SetTextColor(color[1], color[2], color[3])
    getglobal(name.."_ItemName"):SetText(item.name)
    getglobal(name.."_ItemDesc"):SetText(zeroDB.get_item_subtitle(item))

    --[[itemName, itemLink, itemRarity, itemMinLevel, itemType, itemSubType,
            itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(item.id)

    zeroDB.debug(itemName, itemLink, itemRarity, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice)

    if itemTexture then
        getglobal(name.."_Icon"):SetTexture(itemTexture)
    end]]

    getglobal(name.."_Icon"):SetTexture('Interface\\Icons\\'..item.icon)

    frame.linked_object = item
    return frame
end

function zeroDB.SpotlightFrame.hide()
    zeroDB_SpotlightFrame:Hide()
end

--[[function zeroDB.SpotlightFrame.get_result_frame_text(index, text)
    local name = 'zeroDB_SpotlightResultText'..index
    local frame = zeroDB.SpotlightFrame.views[name]

    if not frame then
        frame = CreateFrame('Frame', name, nil, 'zeroDB_SpotlightResultText')
        zeroDB.SpotlightFrame.views[name] = frame
    end

    getglobal(name.."_Text"):SetText(text)

    frame.linked_object = nil
    return frame
end]]--

function zeroDB.SpotlightFrame.on_result_click(result_frame)
    local obj = result_frame.linked_object
    local type = obj.type

    if type == 'item' then
        zeroDB.navigate.to{view = zeroDB.ItemViewFrame, item = obj}
    else
        --zeroDB.debug('Error: invalid object type', type)
    end
end

function zeroDB.SpotlightFrame.OnTextChanged(text)
    this = zeroDB_SpotlightFrame
    local list_view = zeroDB.SpotlightFrame.list_view

    local default_height = -list_view.y
    local result_height = list_view.result_height
    local spacing = list_view.spacing

    local more_results_height = 32
    local bottom_border = 5
    local max_screen_usage = 0.75

    if text == '' then
        list_view:clear()

        zeroDB_SpotlightFrame_EditBox_Placeholder:Show()
        zeroDB_SpotlightFrame_MoreResults:Hide()
        this:SetHeight(default_height)
        return
    else
        zeroDB_SpotlightFrame_EditBox_Placeholder:Hide()
    end

    -- calculate maximum number of results to view
    local max_results = floor((GetScreenHeight() - default_height - bottom_border) / (result_height + spacing) * max_screen_usage)
    list_view.max_results = max_results

    -- perform the search
    local results, num_results = zeroDB.search(text, 0, max_results + 1)

    -- build list view
    local num_viewed_results, y = list_view:build(results, num_results)

    -- display note at the bottom
    if num_viewed_results < num_results or num_viewed_results == 0 then
        bottom_border = bottom_border + more_results_height
    end

    this:SetHeight(-y + bottom_border)

    if num_viewed_results == 0 then
        zeroDB_SpotlightFrame_MoreResults:SetText('Nothing found.')
        zeroDB_SpotlightFrame_MoreResults:SetPoint("TOP", 0, y - 8)
        zeroDB_SpotlightFrame_MoreResults:Show()
    elseif num_viewed_results < num_results then
        zeroDB_SpotlightFrame_MoreResults:SetText('and '..(num_results - num_viewed_results)..' more')
        zeroDB_SpotlightFrame_MoreResults:SetPoint("TOP", 0, y - 8)
        zeroDB_SpotlightFrame_MoreResults:Show()
    else
        zeroDB_SpotlightFrame_MoreResults:Hide()
    end
end

function zeroDB.SpotlightFrame.present_result(result, index)
    --[[if result.type == 'debug' then
        return zeroDB.SpotlightFrame.get_result_frame_text(index, result.text)
    else]]--
    if result.type == 'creature' then
        return zeroDB.SpotlightFrame.get_result_frame_creature(index, result)
    elseif result.type == 'item' then
        return zeroDB.SpotlightFrame.get_result_frame_item(index, result)
    else
        zeroDB.debug('Unknown result type '..result.type)
    end
end

function zeroDB.SpotlightFrame.show(nav)
    if nav.query ~= nil then
        zeroDB_SpotlightFrame_EditBox:SetText(nav.query)
    end

    if not zeroDB.SpotlightFrame.list_view then
        local default_height = 48

        zeroDB.SpotlightFrame.list_view = zeroDB.ListView:new{
            container = zeroDB_SpotlightFrame,
            present_result = zeroDB.SpotlightFrame.present_result,
            x = 5, y = -default_height, result_height = 42, spacing = 0, max_results = 0
        }
    end

    zeroDB_SpotlightFrame_EditBox:HighlightText()
    zeroDB_SpotlightFrame:Show()
end
