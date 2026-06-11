local currentSeats = {}

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		humanoid.Seated:Connect(function(active, seatPart)
			-- IF PLAYER ENTERS CAR
			if active and seatPart and seatPart.Name == "PickupTruck" and seatPart:IsA("VehicleSeat") then
				currentSeats[player] = seatPart

				-- Set ownership of the entire physical assembly to the player
				local rootPart = seatPart.AssemblyRootPart
				if rootPart then
					rootPart:SetNetworkOwner(player)
				end

				-- IF PLAYER EXITS CAR
			else
				local oldSeat = currentSeats[player]
				if oldSeat and oldSeat.Parent then
					local rootPart = oldSeat.AssemblyRootPart
					if rootPart and rootPart:GetNetworkOwner() == player then
						rootPart:SetNetworkOwner(nil) -- Revert ownership to server
					end
				end
				currentSeats[player] = nil
			end
		end)
	end)
end)

-- Security clean-up if a player rage-quits/disconnects while driving
game.Players.PlayerRemoving:Connect(function(player)
	local oldSeat = currentSeats[player]
	if oldSeat and oldSeat.Parent then
		local rootPart = oldSeat.AssemblyRootPart
		if rootPart and rootPart:GetNetworkOwner() == player then
			rootPart:SetNetworkOwner(nil)
		end
	end
	currentSeats[player] = nil
end)
