if SERVER then
    resource.AddFile("sound/jetyeet/jetpackbobasound.wav")
	//Handles notifications
	function JumpNotify( ply, str )
		if ( DarkRP ) then
			DarkRP.notify( ply, 1, 3, str )
		else
			ply:ChatPrint( str )
		end

	end

	//Handles launching
	hook.Add( "KeyPress", "JumpJetKeyPress", function( ply, key )

		//Sanity checking
		if not IsValid( ply ) then return end

		if not IsFirstTimePredicted() then return end

		//If we don't have a jump jet, none of this matters
		if not ply:GetNWBool( "HasJumpJet", false ) then return end

		//Can't jump jet if we're on the ground or have already done it
		if ( ply:IsOnGround() or ply.JumpJettedAlready ) then return end

		if key == IN_JUMP then
		    
			local yeet = ply:GetAimVector()
			local up = Vector(ply:GetForward() * 0.5 + ply:GetUp()*1.2)

			//Thrust the player into the air
			ply:SetVelocity( ( up * 500 ) )

			//Make sure we can't jump twice
			ply.JumpJettedAlready = true

			//Give us some cinematic view punching
			ply:ViewPunch( Angle( -10, 0, 0 ) )

			//Play sounds
			ply:EmitSound( "sound/jetyeet/jetpackbobasound.wav" )
			ply:EmitSound( "ambient/machines/thumper_dust.wav" )

			//Water Ripple
			local effectdata = EffectData()
			effectdata:SetStart( ply:GetPos() )
			effectdata:SetOrigin( ply:GetPos() )
			effectdata:SetEntity( ply )
			effectdata:SetScale( 25 )
			util.Effect( "waterripple", effectdata, true, true )

			//Smoke/Dust
			local effectdata = EffectData()
			effectdata:SetStart( ply:GetPos() )
			effectdata:SetOrigin( ply:GetPos() )
			effectdata:SetEntity( ply )
			effectdata:SetColor( 0 )
			effectdata:SetScale( 500 )
			util.Effect( "ThumperDust", effectdata, true, true )

		end
    end )
    //If we die, we lose our jump jet
    --[[
	hook.Add( "PlayerDeath", "JumpJetPlayerDeath", function( ply ) 

		if not ply:GetNWBool( "HasJumpJet", false ) then return end

		//Chance to drop jump jet on death
		if ( math.random() < (GetConVar( "JumpJet_DropChance" ):GetFloat()/100) ) then

			//DarkRP.notify( ply, 1, 3, "Your jump jet has been dropped!")
			JumpNotify( ply, "Your jump jet has been dropped!" )
			
			local jumpjet = ents.Create( "jump_jet" )

			local boneid = ply:LookupBone( "ValveBiped.Bip01_Spine2" )

			//Sanity checking
			if not boneid then
				return
			end

			local matrix = ply:GetBoneMatrix( boneid )
			
			local offsetvec = Vector( 3, -5.6, 0 )
			local offsetang = Angle( 180, 90, -90 )
			local newpos, newang = LocalToWorld( offsetvec, offsetang, matrix:GetTranslation(), matrix:GetAngles() )

			jumpjet:SetPos( newpos )
			jumpjet:SetAngles( newang )

			jumpjet:Spawn()

			jumpjet:SetVelocity( ply:GetVelocity() )
		else
			//DarkRP.notify( ply, 1, 3, "Your jump jet has been destroyed!")
			JumpNotify( ply, "Your jump jet has been destroyed!" )

			//Jump jet explodes
			local vPoint = ply:GetPos()
			local effectdata = EffectData()
			effectdata:SetOrigin( vPoint )
			util.Effect( "Explosion", effectdata )
		end

		ply:SetNWBool( "HasJumpJet", false )
		ply.JumpJettedAlready = nil

	end )
]]--

	//When we land we can use it again
	hook.Add( "OnPlayerHitGround", "JumpJetPlayerHitGround", function( ply, speed ) 
	    if not ply:GetNWBool( "HasJumpJet", false ) then return end
		ply.JumpJettedAlready = false
		speed = 0
		return speed
	end)
 
--[[
    hook.Add("GetFallDamage", "nofall", function( ply, speed )
        if not ply:GetNWBool( "HasJumpJet", false ) then return end
        ply.JumpJettedAlready = false
        speed = 0
        return speed
    end)
]]--
end
if CLIENT then

	//Make and hide a clientside jetpack model
	local model = ClientsideModel( "models/themexicanjew/Jetpack.mdl" )
	model:SetNoDraw( true )

	local offsetvec = Vector( 8, -4, 0 )
	local offsetang = Angle( 180, -90, 90 )

	hook.Add( "PostPlayerDraw" , "manual_model_draw_example" , function( ply )

		//Don't draw jump jets on players who don't have them
		if not ply:GetNWBool( "HasJumpJet", false ) then return end

		//Get the spine bone we'll be drawing the jump jet on
		local boneid = ply:LookupBone( "ValveBiped.Bip01_Spine2" )

		//Sanity checking
		if not boneid then
			return
		end

		local matrix = ply:GetBoneMatrix( boneid )

		//Sanity checking
		if not matrix then
			return
		end

		//Transform our bone positions
		local newpos, newang = LocalToWorld( offsetvec, offsetang, matrix:GetTranslation(), matrix:GetAngles() )

		model:SetPos( newpos )
		model:SetAngles( newang )
		model:SetupBones()

		model:DrawModel()

	end )

end