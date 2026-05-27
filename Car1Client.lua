--localscript startercharacterscripts Car1 (pickuptruck)
local tweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.4)
local character = script.Parent
local connection = nil
local seat = nil

character.Humanoid.Seated:Connect(function(active, seatPart)
	if connection ~= nil then connection:Disconnect() connection = nil end
	
	if seatPart == nil then 
		if seat == nil then return end
		local attachment = nil
		local height = -math.huge
		for i, child in ipairs(seat:GetChildren()) do
			if child.ClassName ~= "Attachment" then continue end
			if child.WorldPosition.Y <= height then continue end
			height = child.WorldPosition.Y
			attachment = child
		end
		character.PrimaryPart.CFrame = attachment.WorldCFrame
		seat = nil
		return
	end	
	
	if seatPart.Name ~= "PickupTruck" then return end
	
	seat = seatPart
	
	
	local attachmentFL = seatPart.Parent.PrimaryPart.AttachmentFL
	local attachmentFR = seatPart.Parent.PrimaryPart.AttachmentFR

	local cylindricalBL = seatPart.Parent.WheelBL.CylindricalConstraint
	local cylindricalBR = seatPart.Parent.WheelBR.CylindricalConstraint
	
	local maxAngularVelocity = seatPart.MaxSpeed / (seatPart.Parent.WheelBR.Size.Y / 2)
	
	connection = seatPart.Changed:Connect(function(property)
		if property == "SteerFloat" then
			local orientation = Vector3.new(0, -seatPart.SteerFloat * seatPart.TurnSpeed, 90)
			tweenService:Create(attachmentFL, tweenInfo, {Orientation = orientation}):Play()		
			tweenService:Create(attachmentFR, tweenInfo, {Orientation = orientation}):Play()


		elseif property == "ThrottleFloat" then
			local torque = math.abs(seatPart.ThrottleFloat) * seatPart.Torque
			if torque == 0 then torque = 2000 end
			local angularVelocity = math.sign(seatPart.ThrottleFloat) * maxAngularVelocity
			cylindricalBL.MotorMaxTorque = torque
			cylindricalBR.MotorMaxTorque = torque
			cylindricalBL.AngularVelocity = angularVelocity
			cylindricalBR.AngularVelocity = angularVelocity
		end
	end)
end)
