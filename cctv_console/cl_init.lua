include("shared.lua")
local ply = LocalPlayer()

function ENT:Draw()
	self:DrawModel()
end

function stopOperating()
	local ply = LocalPlayer()
	net.Start("cctv_stop")
	net.SendToServer()
	hook.Remove("HUDPaint", "drawCCTVInfo")
	chat.AddText(Color(255, 0, 0), "CCTV | ", Color(255, 255, 255), "Stopped operating CCTV!")
end

local mat = Material("effects/combine_binocoverlay")
local camera = "Training Room"

net.Receive("cctv_view", function()
	local ply = LocalPlayer()
	local f = vgui.Create("DFrame")
	f:SetSize(400, 300)
	f:SetPos(ScrW()-f:GetWide()-10, 70)
	f:ShowCloseButton(false)
	f:SetTitle("CCTV | Control Panel")
	f.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 230)) end
	local cameras = vgui.Create("DIconLayout", f)
	cameras:Dock(FILL)
	cameras:SetSpaceX(5)
	cameras:SetSpaceY(5)
	for k, v in pairs(cctvLocations) do
		local camselector = cameras:Add("DButton")
		camselector:SetText(v.name)
		camselector:SetSize(100, 80)
		camselector:SetTextColor(Color(255, 255, 255))
		camselector:SetFont("ChatFont")
		camselector.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 100, 255)) end
		camselector.DoClick = function() camera = v.name net.Start("cctv_changelocation") net.WriteVector(v.pos) net.WriteAngle(v.ang) net.SendToServer() end
	end

	local close = vgui.Create("DButton", f)
	close:Dock(BOTTOM)
	close:SetText("Stop Opperating")
	close.DoClick = function() f:Close() stopOperating() end

	hook.Add("HUDPaint", "drawCCTVInfo", function()

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(mat)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())


		draw.RoundedBox(0, 0, 0, ScrW(), 65, Color(60, 60, 60))
		draw.SimpleText("CCTV OPEREATING :: ACTIVE", "CloseCaption_Normal", ScrW()/2, 25, Color(255, 255, 255), 1, 1)
		draw.SimpleText("Hold F3 to change cameras!", "CloseCaption_Normal", ScrW()/2, 50, Color(255, 255, 255), 1, 1)
		draw.SimpleText("CAM: "..camera, "CloseCaption_Normal", 10, 40, Color(255, 255, 255), 0, 1)
		draw.SimpleText("X: "..math.Round(ply:GetPos().x).." Y: "..math.Round(ply:GetPos().y).." Z: "..math.Round(ply:GetPos().z), "CloseCaption_Normal", ScrW()-200, 40, Color(255, 255, 255), 0, 1)
	end)

end)