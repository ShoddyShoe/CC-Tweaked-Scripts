authPlayerUUID = "1540f590-f9cc-4966-b590-f327f7377957"
authPlayer = "ShoddyShoe51945"

chatbox = peripheral.find("chatBox")
inventory = peripheral.find("inventoryManager")
barrel = peripheral.find("create:item_vault")

local function remove_duplicates(slots)
    local seen = {}
    local unique_slots = {}
    for _, slot in ipairs(slots) do
        if slot >= 0 and not seen[slot] then
            seen[slot] = true
            table.insert(unique_slots, slot)
        end
    end
    return unique_slots
end

local function condense_slots(slots)
    slots = remove_duplicates(slots)
    table.sort(slots)
    local ranges, start, finish = {}, slots[1], slots[1]
    for i = 2, #slots do
        if slots[i] == finish + 1 then
            finish = slots[i]
        else
            table.insert(ranges, start == finish and tostring(start) or start .. "-" .. finish)
            start, finish = slots[i], slots[i]
        end
    end
    table.insert(ranges, start == finish and tostring(start) or start .. "-" .. finish)
    return table.concat(ranges, ", ")
end

local function expand_slots(condensed)
    local result = {}
    for range in string.gmatch(condensed, '([^,]+)') do
        local start, finish = string.match(range, '(%d+)%-(%d+)')
        if start and finish then
            for i = tonumber(start), tonumber(finish) do table.insert(result, i) end
        else
            table.insert(result, tonumber(range))
        end
    end
    result = remove_duplicates(result)
    table.sort(result)
    return result
end

local function is_slot_in_list(slot_list, number)
    if not slot_list then return false end
    for part in string.gmatch(slot_list, '([^,]+)') do
        local start, finish = string.match(part, '(%d+)%-(%d+)')
        if start and finish and tonumber(number) >= tonumber(start) and tonumber(number) <= tonumber(finish) then
            return true
        elseif tonumber(part) == tonumber(number) then
            return true
        end
    end
    return false
end

while true do
    ::reset::
    local event, username, message, uuid, isHidden = os.pullEvent("chat")
    if username == authPlayer and uuid == authPlayerUUID and isHidden then
        if message == "reboot" then os.reboot() end

        if message == "itemList" or string.find(message, "withdraw ") or string.find(message, "deposit ") then
            local aggregated_items = {}
            if message == "itemList" or string.find(message, "withdraw ") then
                for slot, item in pairs(barrel.list()) do
                    if aggregated_items[item.name] then
                        aggregated_items[item.name].count = aggregated_items[item.name].count + item.count
                        table.insert(aggregated_items[item.name].slots, slot)
                    else
                        aggregated_items[item.name] = {count = item.count, slots = {slot}}
                    end
                end
            else 
                for _, item in pairs(inventory.getItems()) do
                    item.slot = item.slot + 1
                    if aggregated_items[item.name] then
                        aggregated_items[item.name].count = aggregated_items[item.name].count + item.count
                        table.insert(aggregated_items[item.name].slots, item.slot)
                    else
                        aggregated_items[item.name] = {count = item.count, slots = {item.slot}}
                    end
                end
            end

            local messages, slotLists = {}, {}
            for name, data in pairs(aggregated_items) do
                local SlotList = condense_slots(data.slots)
                slotLists[name] = SlotList
                table.insert(messages, {
                    text = ("\n%d x %s in " .. (#data.slots > 1 and "slots" or "slot") .. " %s"):format(data.count, name, SlotList),
                    color = "aqua",
                    insertion = "$withdraw " .. name .. "|" .. data.slots[1]
                })
            end
            table.insert(messages, {text = "\n-----------", color = "aqua", insertion = ""})

            if message == "itemList" then
                chatbox.sendFormattedMessageToPlayer(textutils.serializeJSON(messages), authPlayer, "&b=( Vault )=", "--", "&b")
            end

            if string.find(message, "withdraw ") or string.find(message, "deposit ") then
                local item, itemSlot
                if string.find(message, "withdraw") then item, itemSlot = string.match(message, "^withdraw ([^|]*)|(.*)")
                else item, itemSlot = string.match(message, "^deposit ([^|]*)|(.*)")
                end
                if item and itemSlot then
                    local slotsToProcess = expand_slots(itemSlot)
                    if #slotsToProcess <= 0 then
                        chatbox.sendMessageToPlayer("Invalid slot range specified.", authPlayer, "&bVault", "<>")
                        goto reset
                    end

                    local SlotList = slotLists[item]
                    local totalItemCount, ExtraSpace, totalSlots = 0, 0, 0
                    for _, slot in ipairs(slotsToProcess) do
                        local itemData = (string.find(message, "withdraw ") and barrel.getItemDetail(slot)) and barrel.getItemDetail(slot) or inventory.getItems()[slot]
                        if itemData and itemData.name == item then
                            if string.find(message, "deposit ") and barrel.getItemDetail(slot) then totalSlots = totalSlots + 1 end
                            totalItemCount = totalItemCount + itemData.count
                        end
                    end
                    for _, items in pairs(string.find(message, "withdraw ") and inventory.getItems() or barrel.list()) do
                        if items.name == item then
                            ExtraSpace = ExtraSpace + 64 - items.count
                        end
                    end
                    local emptySpace
                    if string.find(message, "withdraw ") then emptySpace = inventory.getEmptySpace() * 64 + ExtraSpace
                    else emptySpace = (barrel.size() - totalSlots) * 64 + ExtraSpace
                    end
                    if totalItemCount > emptySpace then
                        chatbox.sendMessageToPlayer(
                            "The total count of " .. item .. " ("..totalItemCount..") in the specified range exceeds your inventory space (" .. emptySpace .. "). Please specify a smaller range.",
                            authPlayer, "&bVault", "<>"
                        )
                        goto reset
                    end

                    local slotsContainingItem, slotsNotContainingItem = {}, {}
                    for _, slot in ipairs(slotsToProcess) do
                        if is_slot_in_list(SlotList, slot) then
                            table.insert(slotsContainingItem, slot)
                        else
                            table.insert(slotsNotContainingItem, slot)
                        end
                    end

                    if #slotsNotContainingItem > 0 then
                        chatbox.sendMessageToPlayer(
                            (#slotsContainingItem == 0 and "No valid slots containing " .. item or (#slotsNotContainingItem == 1 and "Slot " .. slotsNotContainingItem[1] .. " does" or "Slots " .. condense_slots(slotsNotContainingItem) .. " do") .. " not contain " .. item .. "."),
                            authPlayer, "&bVault", "<>"
                        )
                    end

                    if #slotsContainingItem > 0 then
                        for _, slot in ipairs(slotsContainingItem) do
                            if string.find(message, "withdraw ") then inventory.addItemToPlayer("east", {name = item, fromSlot = slot - 1})
                            else inventory.removeItemFromPlayer("east", {name = item, fromSlot = slot - 1})
                            end
                        end
                    end
                end
            end
        end
    end
end
