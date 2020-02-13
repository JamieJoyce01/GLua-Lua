AddCSLuaFile()

ENT.Type 				= "anim"
ENT.Base 				= "base_gmodentity"
ENT.PrintName 			= "Jump Pack"
ENT.Category            = "Sneaky's MVG Custom"
ENT.Spawnable 			= true
ENT.RenderGroup			= RENDERGROUP_TRANSLUCENT


function ENT:Initialize()

	if SERVER then
		self:SetModel( "models/themexicanjew/Jetpack.mdl" )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:Wake()

		self:SetPos( self:GetPos() + self:GetUp() * 10 )


		self:SetUseType( SIMPLE_USE )
	end

end

function ENT:Use( _, ent )
	if ( not IsValid( ent ) or not ent:IsPlayer() ) then return end

	if ent:GetNWBool( "HasJumpJet", false ) then
		JumpNotify( ent, "You're already wearing a jump pack!" )
		return
	end

	ent:SetNWBool( "HasJumpJet", true )

	JumpNotify( ent, "You have equipped a jump pack!" )
	self:Remove()
end