AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("cctv_view")
util.AddNetworkString("cctv_stop")
util.AddNetworkString("cctv_changelocation")

function ENT:Initialize()

	self:SetModel("models/props_combine/combine_interface001.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end

	self:SetUseType(SIMPLE_USE)
end

function SetOperator(ply)
	// Show their view.
	net.Start("cctv_view")
	net.Send(ply)

	// Remember their shit.
	ply:SetNW2Vector("previousLocation", ply:GetPos())
	--ply:SetNW2Vector("previousangle", ply:GetShootPos()) If you are not a retard you will have read this message and realised that i have touched your shit. Do not worry no i didnt. All i tried to do was A. Disable gravity because if you spam click your camera you can take fall damage and die. B. Tried to get it to remember the angles you were looking at when you pressed E but gmod is disabled so.
	ply:SetMoveType(MOVETYPE_NONE)
	--ply:SetGravity(0)
	ply:Lock()
	ply:StripWeapons()
	ply:SetRenderMode(RENDERMODE_NONE)
	ply:SetEyeAngles(cctvLocations[1].ang)
	ply:SetPos(cctvLocations[1].pos)
	
	SetGlobalBool("cctvOperaterActive", true)
end

net.Receive("cctv_stop", function(len, ply)
	ply:Spawn()
	ply:SetPos(ply:GetNW2Vector("previousLocation"))
	--ply:SetEyeAngles(ply:GetNW2Vector("previousangles"):Angle())
	ply:UnLock()
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetRenderMode(RENDERMODE_NORMAL)

	SetGlobalBool("cctvOperaterActive", false)
end)

net.Receive("cctv_changelocation", function(len, ply)
	local pos = net.ReadVector()
	local ang = net.ReadAngle()
	ply:UnLock()
    ply:SetEyeAngles(ang)
	ply:SetPos(pos)
	timer.Simple(0.04, function() ply:Lock() end)
end)

function ENT:Use(ply)
	if GetGlobalBool("cctvOperaterActive", false) == false then
		ply:SetNW2Bool("operating_cctv", true)
		ply:SendLua("chat.AddText(Color(255, 0, 0), 'CCTV | ', Color(255, 255, 255), 'Entering operator mode!')")

		// Show the operater view.
		SetOperator(ply)
	else
		ply:SendLua("chat.AddText(Color(255, 0, 0), 'CCTV | ', Color(255, 255, 255), 'Someone is already operating CCTV!')")
	end

end