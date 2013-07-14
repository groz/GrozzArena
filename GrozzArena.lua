if not MyCombatFrame then
	CreateFrame("Frame", "MyCombatFrame", UIParent)
end

MyCombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
MyCombatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

function MyCombatFrame_OnEvent(self, event, ...)
	if event == "PLAYER_REGEN_ENABLED" then
		print("Leaving combat")
	elseif event == "PLAYER_REGEN_DISABLED" then
		print("Entering combat")
	end
end