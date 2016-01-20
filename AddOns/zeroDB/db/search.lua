
zeroDB = zeroDB or {}

zeroDB.class_names = {'Warrior', 'Paladin', 'Hunter', 'Rogue', 'Priest', 'Death Knight', 'Shaman', 'Mage', 'Warlock', 'Monk', 'Druid'}
zeroDB.MAX_CLASS = 11
zeroDB.MAX_LEVEL = 60

function zeroDB.get_object(ref)
    if ref < 1000000 then
        return zeroDB.db.items[ref]
    elseif ref < 2000000 then
        return zeroDB.db.creatures[ref - 1000000]
    else
        return nil
    end
end

function zeroDB.get_item_subtitle(item)
    local desc = zeroDB.db.item_classes[item.class] or '???'

    if zeroDB.db.item_subclasses[item.class] and zeroDB.db.item_subclasses[item.class][item.subclass] then
        desc = desc..', '..zeroDB.db.item_subclasses[item.class][item.subclass]
    end

    -- slot only applies to armor
    if item.class == 4 and zeroDB.db.item_slots[item.slot] then
        desc = desc..', '..zeroDB.db.item_slots[item.slot]
    end

    if item.classes ~= nil then
        local allowable_classes = ''

        for i = 1, zeroDB.MAX_CLASS do
            if item.classes[i] then
                if allowable_classes ~= '' then allowable_classes = allowable_classes..', ' end
                allowable_classes = allowable_classes..zeroDB.class_names[i]
            end
        end

        desc = desc..' – '..allowable_classes
    end

    if item.requiredlevel > 1 then
        desc = desc..' – Level '..item.requiredlevel

        if item.requiredlevel < zeroDB.MAX_LEVEL then
            desc = desc..'+'
        end
    end

    return desc
end

function zeroDB.get_creature_subtitle(creature)
    local desc

    if creature.minlevel == creature.maxlevel then
        desc = 'Level '..creature.minlevel
    else
        desc = 'Level '..creature.minlevel..'-'..creature.maxlevel
    end

    if creature.creature_type ~= 0 then
        desc = desc..' '..zeroDB.db.creature_types[creature.creature_type]
    end

    if creature.rank ~= 0 then
        desc = desc..' ('..zeroDB.db.creature_ranks[creature.rank]..')'
    end

    return desc
end

function zeroDB.test_keyword(obj, keyword)
    if zeroDB.begins_with(keyword, '-l') then
        if obj.requiredlevel then
            local level = tonumber(string.sub(keyword, 3))

            if level and obj.requiredlevel >= level - 3 and obj.requiredlevel <= level + 3 then
                return true
            end
        end
    end

    local pos1, pos2 = string.find(obj.keywords, '|' .. keyword)
    return pos1 ~= nil
end

function zeroDB.search(text, skip, max_results)
    local keywords, num_keywords = zeroDB.explode(string.lower(text), ' ')

    if num_keywords == 0 then return nul, 0 end

    local results = {}
    local num_results = 0

    -- preprocess (level XY => -lXY)
    for i = 1, num_keywords do
        if keywords[i] == 'level' and i + 1 <= num_keywords then
            keywords[i] = '-l'..keywords[i + 1]
            table.remove(keywords, i + 1)
            num_keywords = num_keywords - 1
        end
    end

    -- 0 for A, 1 for B etc.
    local char_index = string.byte(keywords[1], 1) - string.byte('a', 1) + 1

    if char_index < 1 or char_index > 26 then
        -- FIXME: should test ALL rather than NONE
        return nul, 0
    end

    -- iterate through all keywords starting with the same letter
    for k, object_list in pairs(zeroDB.db.keywords[char_index]) do
        -- does this match the first keyword of the query?
        if zeroDB.begins_with(k, keywords[1]) then
            -- iterate all objects for this keyword
            for _, object_ref in pairs(object_list) do
                local obj = zeroDB.get_object(object_ref)

                if obj and obj.type ~= 'item' then
                elseif obj then
                    local ok = true

                    -- test if the object matches the rest of the keywords
                    for i = 2, num_keywords do
                        if not zeroDB.test_keyword(obj, keywords[i]) then
                            ok = false
                            break
                        end
                    end

                    -- object matched all filters
                    if ok then
                        if skip == 0 then
                            num_results = num_results + 1
                            --results[num_results] = obj

                            if num_results < max_results then
                                results[num_results] = obj
                            end

                            --if num_results >= max_results then
                            --    return results, num_results
                            --end
                        else
                            skip = skip - 1
                        end
                    end
                else
                    zeroDB.debug('Warning: no object found for ref '..object_ref)
                end
            end
        end
    end

    return results, num_results
end
