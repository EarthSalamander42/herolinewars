-- The overall game state has changed
function GameMode:_OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		self.bSeenWaitForPlayers = true
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameMode:OnGameInProgress()
	end
end

mode = nil

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:_OnConnectFull(keys)
	if mode == nil then
		-- Set GameMode parameters
		mode = GameRules:GetGameModeEntity()
		mode:SetRecommendedItemsDisabled(false)
		mode:SetCameraDistanceOverride(1350)
		mode:SetBuybackEnabled(false)

		mode:SetFogOfWarDisabled(true)
		mode:SetUnseenFogOfWarEnabled(false)

--		mode:SetAnnouncerDisabled( DISABLE_ANNOUNCER )

--		mode:SetFountainConstantManaRegen( FOUNTAIN_CONSTANT_MANA_REGEN )
--		mode:SetFountainPercentageHealthRegen( FOUNTAIN_PERCENTAGE_HEALTH_REGEN )
--		mode:SetFountainPercentageManaRegen( FOUNTAIN_PERCENTAGE_MANA_REGEN )

	end
end
