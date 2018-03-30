function GameMode:OnDisconnect(keys)
	GameMode:HLWPrint("OnDisconnect")

	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid

	local playerID = keys.PlayerID
end

function GameMode:OnGameRulesStateChange(keys)
	GameMode:HLWPrint("OnGameRulesStateChange")

	GameMode:_OnGameRulesStateChange(keys)

	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		Timers:CreateTimer(1, function()
			Notifications:TopToAll({text="#hlw_tutorial_message_controller", duration=5.0, style={color="white", ["font-size"]="30px"}})
			EmitGlobalSound("HLW.TutorialSound")
		end)
		Timers:CreateTimer(7, function()
			Notifications:TopToAll({text="#hlw_tutorial_message_income", duration=5.0, style={color="white", ["font-size"]="30px"}})
			EmitGlobalSound("HLW.TutorialSound")
		end)
		Timers:CreateTimer(13, function()
			Notifications:TopToAll({text="#hlw_tutorial_message_objective", duration=5.0, style={color="white", ["font-size"]="30px"}})
			EmitGlobalSound("HLW.TutorialSound")
		end)
	elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then		

		--[[for k, v in pairs(GameMode.UpgradeCost) do
			GameMode.UpgradeCost[k] = v * GameMode.GoldMultiplier
		end

		for k, v in pairs(GameMode.CreepCost) do
			GameMode.CreepCost[k] = v * GameMode.GoldMultiplier
		end

		for k, v in pairs(GameMode.CreepIncome) do
			GameMode.CreepIncome[k] = v * GameMode.GoldMultiplier
		end]]
	end
end

function GameMode:OnPlayerReconnect(keys)
	GameMode:HLWPrint("OnPlayerReconnect")
	local PlayerID = keys.PlayerID

	GameMode:InitializeCreepPanoramaForPlayer(PlayerID)
	GameMode:InitializeIncomePanoramaForPlayer(PlayerID)
end

function GameMode:OnItemPurchased( keys )
	GameMode:HLWPrint("OnItemPurchased")

	local plyID = keys.PlayerID
	if not plyID then return end

	local itemName = keys.itemname 
	local itemcost = keys.itemcost
	
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(plyID), "UpdateButtonStatuses", GameMode:GetButtonUpdateData(plyID) )
end

-- An entity died
function GameMode:OnEntityKilled( keys )
	GameMode:HLWPrint("OnEntityKilled")
	
	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	-- The ability/item used to kill, or nil if not killed by an item/ability
	local killerAbility = nil

	if keys.entindex_inflictor ~= nil then
		killerAbility = EntIndexToHScript( keys.entindex_inflictor )
	end

	-- possible crash cause?
	if killedUnit.IsRealHero and killedUnit:IsRealHero() then
		local newOrder = 
		{
			UnitIndex = keys.entindex_inflictor, 
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			TargetIndex = nil, --Optional.  Only used when targeting units
			AbilityIndex = 0, --Optional.  Only used when casting abilities
			Position = GameMode.AncientPosition[killedUnit:GetTeam()], --Optional.  Only used when targeting the ground
			Queue = 1 --Optional.  Used for queueing up abilities
		}

		ExecuteOrderFromTable(newOrder)
	end

	if string.sub(killedUnit:GetUnitName(), 1, 23) == "npc_dota_unit_hlw_level" then
		GameMode.TeamCreepCounts[killedUnit:GetTeamNumber()] = GameMode.TeamCreepCounts[killedUnit:GetTeamNumber()] - 1
	end

	-- Put code here to handle when an entity gets killed
	if killerEntity and killerEntity.IsRealHero and killerEntity:IsRealHero() then
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(killerEntity:GetPlayerID()), "UpdateButtonStatuses", GameMode:GetButtonUpdateData(killerEntity:GetPlayerID()) )
	end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
	DebugPrint('[BAREBONES] OnConnectFull')
	DebugPrintTable(keys)

	GameMode:_OnConnectFull(keys)

	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)

	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()

	if GameMode.FirstPlayerLoaded ~= true then
		Timers:CreateTimer(0.1, function()
			if GameMode.RecievedSetHost ~= true then
				CustomGameEventManager:Send_ServerToPlayer(ply, "SetHost", nil)
				return 0.5
			end
		end)

		GameMode.FirstPlayerLoaded = true
	else
		Timers:CreateTimer(1, function()
			for k, v in pairs(GameMode.Settings) do
				CustomGameEventManager:Send_ServerToAllClients("SetSettingFromServer", {panel=k, choice=v})
			end
		end)
	end
end

--[[
-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
	DebugPrint('[BAREBONES] OnNPCGoalReached')
	DebugPrintTable(keys)

	local goalEntity = EntIndexToHScript(keys.goal_entindex)
	local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
	local npc = EntIndexToHScript(keys.npc_entindex)
end
--]]
