--serverscript Car1 (PickupTruck) in ServerScriptService
game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character.Humanoid.Seated:Connect(function(active, seatPart)
			if seatPart == nil then return end
			if seatPart.Name ~= "PickupTruck" then return end
			seatPart:SetNetworkOwner(player)
			print("Owner", player.Name)
		end)
	end)
end)
