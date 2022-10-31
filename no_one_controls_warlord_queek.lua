-- No one controls warlord Queek

-- check if a list of script units contains Queek
local function search_units_for_queek(script_units)
	for i = 1, script_units:count() do
        local current_sunit = script_units:item(i);
        if current_sunit.unit:type() == "wh2_main_skv_cha_queek_headtaker" then
            out("Local unit is Queek")
            --current_sunit:take_control();
            current_sunit:start_attack_closest_enemy(5000);
        end;
    end;
end;

-- call a function for every main army and for every reinforcing army
local function search_armies_for_units()
    for i = 1, bm:num_alliances() do
        for j = 1, bm:num_armies_in_alliance(i) do
            -- disable control for main armies
            local sunits_main_army = bm:get_scriptunits_for_army(i, j);
            search_units_for_queek(sunits_main_army);

            -- disable control for reinforcing armies
            for k = 1, bm:num_reinforcing_armies_for_army_in_alliance(i, j) do
                local sunits_reinforcements = bm:get_scriptunits_for_army(i, j, k);
                search_units_for_queek(sunits_reinforcements);
            end;
        end;
    end;
end;

-- Search all armies for Queek as a unit
bm:register_phase_change_callback(
    "Deployed", 
    function()
        -- initial search
        search_armies_for_units();
        
        -- repeat every 2 seconds
        bm:repeat_callback(
            function() search_armies_for_units() end,
            2000
        );
    end
);
