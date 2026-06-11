local tweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.4)
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local connections = {}
local currentSeat = nil

-- Clears old connections safely to avoid memory leaks
local function disconnectSignals()
	for _, conn in ipairs(connections) do
		if conn then conn:Disconnect() end
	end
	table.clear(connections)
end

humanoid.Seated:Connect(function(active, seatPart)
	disconnectSignals()

	-- HANDLE EXITING
	if not active or seatPart == nil then 
		if not currentSeat then return end

		local attachment = nil
		local height = -math.huge
		for _, child in ipairs(currentSeat:GetChildren()) do
			if child:IsA("Attachment") and child.WorldPosition.Y > height then
				height = child.WorldPosition.Y
				attachment = child
			end
		end

		if attachment then
			-- PivotTo is the modern, safer way to move models/characters
			character:PivotTo(attachment.WorldCFrame)
		end
		currentSeat = nil
		return
	end	

	-- HANDLE ENTERING
	if seatPart.Name ~= "PickupTruck" or not seatPart:IsA("VehicleSeat") then return end
	currentSeat = seatPart

	local vehicleModel = seatPart.Parent
	local primaryPart = vehicleModel.PrimaryPart
	if not primaryPart then return end

	local attachmentFL = primaryPart:FindFirstChild("AttachmentFL")
	local attachmentFR = primaryPart:FindFirstChild("AttachmentFR")
	local wheelBL = vehicleModel:FindFirstChild("WheelBL")
	local wheelBR = vehicleModel:FindFirstChild("WheelBR")

	if not (attachmentFL and attachmentFR and wheelBL and wheelBR) then return end

	local cylindricalBL = wheelBL:FindFirstChildOfClass("CylindricalConstraint")
	local cylindricalBR = wheelBR:FindFirstChildOfClass("CylindricalConstraint")

	if not (cylindricalBL and cylindricalBR) then return end

	local maxAngularVelocity = seatPart.MaxSpeed / (wheelBR.Size.Y / 2)

	-- OPTIMIZATION: Only listen to specific property changes
	table.insert(connections, seatPart:GetPropertyChangedSignal("SteerFloat"):Connect(function()
		local orientation = Vector3.new(0, -seatPart.SteerFloat * seatPart.TurnSpeed, 90)
		tweenService:Create(attachmentFL, tweenInfo, {Orientation = orientation}):Play()		
		tweenService:Create(attachmentFR, tweenInfo, {Orientation = orientation}):Play()
	end))

	table.insert(connections, seatPart:GetPropertyChangedSignal("ThrottleFloat"):Connect(function()
		local torque = math.abs(seatPart.ThrottleFloat) * seatPart.Torque
		if torque == 0 then torque = 2000 end
		local angularVelocity = math.sign(seatPart.ThrottleFloat) * maxAngularVelocity

		cylindricalBL.MotorMaxTorque = torque
		cylindricalBR.MotorMaxTorque = torque
		cylindricalBL.AngularVelocity = angularVelocity
		cylindricalBR.AngularVelocity = angularVelocity
	end))
end)
