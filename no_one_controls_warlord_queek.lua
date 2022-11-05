-- No one controls warlord Queek

local function get_units_in_alliance(alliance, search_unit)
    local return_unit_list = nil;
    for j = 1, bm:num_armies_in_alliance(alliance) do
        local scriptunits_army = bm:get_scriptunits_for_army(alliance, j);
        for i = 1, scriptunits_army:count() do
            local current_script_unit = scriptunits_army:item(i);
            if current_script_unit.unit:type() == search_unit then
                out(current_script_unit.unit:type());
                return_unit_list = {next = return_unit_list, value = current_script_unit}
            end;
        end;

        for k = 1, bm:num_reinforcing_armies_for_army_in_alliance(alliance, j) do
            scriptunits_army = bm:get_scriptunits_for_army(alliance, j, k);
            for i = 1, scriptunits_army:count() do
                local current_script_unit = scriptunits_army:item(i);
                if current_script_unit.unit:type() == search_unit then
                    out(current_script_unit.unit:type());
                    return_unit_list = {next = return_unit_list, value = current_script_unit}
                end;
            end;
        end;
    end;

    return return_unit_list;
end

local function get_units_in_alliance_by_class(alliance, unit_class)
    local return_unit_list = nil;
    for j = 1, bm:num_armies_in_alliance(alliance) do
        local scriptunits_army = bm:get_scriptunits_for_army(alliance, j);
        for i = 1, scriptunits_army:count() do
            local current_script_unit = scriptunits_army:item(i);
            if current_script_unit.unit:unit_class() == unit_class then
                out(current_script_unit.unit:type());
                return_unit_list = {next = return_unit_list, value = current_script_unit}
            end;
        end;

        for k = 1, bm:num_reinforcing_armies_for_army_in_alliance(alliance, j) do
            scriptunits_army = bm:get_scriptunits_for_army(alliance, j, k);
            for i = 1, scriptunits_army:count() do
                local current_script_unit = scriptunits_army:item(i);
                if current_script_unit.unit:unit_class() == unit_class then
                    out(current_script_unit.unit:type());
                    return_unit_list = {next = return_unit_list, value = current_script_unit}
                end;
            end;
        end;
    end;

    return return_unit_list;
end;

local function force_queek_attack(queek_list, targets)
    while queek_list do
        local current_distance = 999999999
        local queek_scriptunit = queek_list.value
        local queek_position = queek_scriptunit.unit:position()

        while targets do
            local target_scriptunit = targets.value
            
            -- break out of while loop
            if target_scriptunit.unit:type() == "" then break end
            
            -- only attack valid targets
            if target_scriptunit.unit:is_valid_target() then
                -- do not attack shattered generals/heroes
                if not target_scriptunit.unit:is_shattered() then
                    local target_position = target_scriptunit.unit:position()
                    local distance = queek_position:distance(target_position)
                    
                    -- attack enemy if closer than current target
                    if distance < current_distance then
                        current_distance = distance;
                        -- attack
                        queek_scriptunit.uc:take_control();
                        queek_scriptunit.uc:attack_unit(target_scriptunit.unit, true, true)
                    end;
                end;
            end;
            
            targets = targets.next
        end;

        if current_distance == 999999999 then
            -- no generals/heroes found? attack closest enemy
            queek_scriptunit:start_attack_closest_enemy(5000);
        end;
        
        queek_list = queek_list.next
    end;
end;


-- search alliance 1 for Queeks
first_alliance_queeks = get_units_in_alliance(1, "wh2_main_skv_cha_queek_headtaker");
-- search alliance 1 for all generals and heroes
first_alliance_targets = get_units_in_alliance_by_class(1,  "com")

-- search alliance 2 for Queeks
second_alliance_queeks = get_units_in_alliance(2, "wh2_main_skv_cha_queek_headtaker");
-- search alliance 2 for all generals and heroes
second_alliance_targets = get_units_in_alliance_by_class(2,  "com")

-- Search all armies for Queek as a unit
bm:register_phase_change_callback(
    "Deployed",
    function()
        force_queek_attack(first_alliance_queeks, second_alliance_targets);
        force_queek_attack(second_alliance_queeks, first_alliance_targets);

        -- repeat every 2 seconds
        bm:repeat_callback(
            function()
                force_queek_attack(first_alliance_queeks, second_alliance_targets);
                force_queek_attack(second_alliance_queeks, first_alliance_targets);
            end,
            2000
        );
    end
);
