-- MM2 client utilities. RightShift toggles the menu.
-- Role colors infer visible tools; not authoritative. No silent aim.
do
local P=game:GetService("Players")
local R=game:GetService("RunService")
local U=game:GetService("UserInputService")
local L=game:GetService("Lighting")
local p=P.LocalPlayer
for _,k in ipairs({"MM2PanelCleanup","MM2ExtrasCleanup","MM2EmotesCleanup","MM2UnifiedCleanup"}) do
 if type(_G[k])=="function" then pcall(_G[k]) end
end
local s,cons,visual,move,coll,esp,cameras={},{},{},{},{},{},{}
local live=true
local av,at,fh,fa,track,cc
local fov
local oldZoom=p.CameraMaxZoomDistance
local lighting={Brightness=L.Brightness,ClockTime=L.ClockTime,FogEnd=L.FogEnd,GlobalShadows=L.GlobalShadows}
local function on(signal,fn)
 local c=signal:Connect(fn); table.insert(cons,c); return c
end
local function char()
 local c=p.Character
 return c,c and c:FindFirstChildOfClass("Humanoid"),c and c:FindFirstChild("HumanoidRootPart")
end
local function stopFly()
 if av then av:Destroy() end
 if at then at:Destroy() end
 if fh and fh.Parent then fh.AutoRotate=fa end
 av,at,fh=nil,nil,nil
end
local function stopEmote()
 if track then track:Stop(.15); track:Destroy(); track=nil end
end
local function restoreCollision()
 for part,v in pairs(coll) do if part.Parent then part.CanCollide=v end end
 table.clear(coll)
end
local function restoreVisual()
 for obj,props in pairs(visual) do
  if obj.Parent then for k,v in pairs(props) do obj[k]=v end end
 end
 table.clear(visual)
end
local function restoreMove()
 for h,v in pairs(move) do
  if h.Parent then h.WalkSpeed=v[1]; h.JumpPower=v[2]; h.JumpHeight=v[3] end
 end
 table.clear(move)
end
local function remember(obj,key)
 visual[obj]=visual[obj] or {}
 if visual[obj][key]==nil then visual[obj][key]=obj[key] end
 return visual[obj][key]
end
local function visuals()
 local c=p.Character; if not c then return end
 local head=c:FindFirstChild("Head")
 for _,obj in ipairs(c:GetDescendants()) do
  local isHead=head and (obj==head or obj:IsDescendantOf(head))
  if obj:IsA("BasePart") then
   local original=remember(obj,"LocalTransparencyModifier")
   if (s.Headless and isHead) or (s.Accessories and obj:FindFirstAncestorOfClass("Accessory")) then
    obj.LocalTransparencyModifier=1
   elseif s.Ghost then obj.LocalTransparencyModifier=math.max(original,.65)
   else obj.LocalTransparencyModifier=original end
  elseif obj:IsA("Decal") or obj:IsA("Texture") then
   local original=remember(obj,"Transparency")
   obj.Transparency=(s.Headless and isHead) and 1 or original
  end
 end
end
local function camera()
 local c=workspace.CurrentCamera; if not c then return end
 if cameras[c]==nil then cameras[c]=c.FieldOfView end
 c.FieldOfView=fov or cameras[c]
end
local gui=Instance.new("ScreenGui")
gui.Name="MM2Unified"; gui.ResetOnSpawn=false; gui.Parent=p:WaitForChild("PlayerGui")
local panel=Instance.new("Frame")
panel.Size=UDim2.new(0,275,.8,0); panel.Position=UDim2.new(0,24,.1,0)
panel.BackgroundColor3=Color3.fromRGB(24,26,34); panel.Parent=gui
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,12)
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,44); title.BackgroundTransparency=1
title.Text="MM2 | RightShift"; title.TextColor3=Color3.new(1,1,1)
title.Font=Enum.Font.GothamBold; title.TextSize=18; title.Parent=panel
local list=Instance.new("ScrollingFrame")
list.Position=UDim2.fromOffset(10,48); list.Size=UDim2.new(1,-20,1,-58)
list.BackgroundTransparency=1; list.BorderSizePixel=0; list.ScrollBarThickness=4
list.CanvasSize=UDim2.new(); list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.Parent=panel
local layout=Instance.new("UIListLayout",list)
layout.Padding=UDim.new(0,6); layout.SortOrder=Enum.SortOrder.LayoutOrder
local crossGui=Instance.new("ScreenGui")
crossGui.Name="MM2Crosshair"; crossGui.IgnoreGuiInset=true; crossGui.ResetOnSpawn=false; crossGui.Parent=p.PlayerGui
local cross=Instance.new("Frame")
cross.Size=UDim2.fromOffset(6,6); cross.AnchorPoint=Vector2.new(.5,.5)
cross.Position=UDim2.fromScale(.5,.5); cross.BackgroundColor3=Color3.fromRGB(100,255,150)
cross.BorderSizePixel=0; cross.Visible=false; cross.Parent=crossGui
Instance.new("UICorner",cross).CornerRadius=UDim.new(1,0)
local order=0
local function button(label,fn)
 order+=1
 local b=Instance.new("TextButton")
 b.LayoutOrder=order; b.Size=UDim2.new(1,-8,0,35)
 b.BackgroundColor3=Color3.fromRGB(43,46,59); b.TextColor3=Color3.new(1,1,1)
 b.Font=Enum.Font.Gotham; b.TextSize=13; b.Text=label; b.Parent=list
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
 on(b.MouseButton1Click,function() fn(b) end)
 return b
end
local function toggle(label,key,fn)
 button(label..": OFF",function(b)
  s[key]=not s[key]; b.Text=label..(s[key] and ": ON" or ": OFF")
  b.BackgroundColor3=s[key] and Color3.fromRGB(45,110,85) or Color3.fromRGB(43,46,59)
  if fn then fn() end
 end)
end
local function clearESP()
 for _,h in pairs(esp) do h:Destroy() end; table.clear(esp)
end
local function tool(target,name)
 local c=target.Character; local b=target:FindFirstChildOfClass("Backpack")
 return (c and c:FindFirstChild(name)) or (b and b:FindFirstChild(name))
end
local function updateESP()
 for target,h in pairs(esp) do
  if not s.ESP or target.Parent~=P or h.Adornee~=target.Character then h:Destroy(); esp[target]=nil end
 end
 if not s.ESP then return end
 for _,target in ipairs(P:GetPlayers()) do
  if target~=p and target.Character then
   local h=esp[target]
   if not h then
    h=Instance.new("Highlight"); h.Adornee=target.Character
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.FillTransparency=.55; h.Parent=gui; esp[target]=h
   end
   local color=Color3.fromRGB(80,220,120)
   if tool(target,"Knife") then color=Color3.fromRGB(255,65,65)
   elseif tool(target,"Gun") then color=Color3.fromRGB(65,155,255) end
   h.FillColor=color; h.OutlineColor=color
  end
 end
end
local ids={
 R6={Wave={"128777973"},Point={"128853357"},Cheer={"129423030"},Laugh={"129423131"},Dance={"182435998","182436842","182436935"}},
 R15={Wave={"507770239"},Point={"507770453"},Cheer={"507770677"},Laugh={"507770818"},Dance={"507771019","507776043","507777268"}}
}
local dance=0
local function emote(name)
 stopEmote()
 local _,h=char(); local animator=h and h:FindFirstChildOfClass("Animator")
 if not animator or h.Health<=0 then title.Text="Character not ready"; return end
 local rig=h.RigType==Enum.HumanoidRigType.R15 and "R15" or "R6"
 local choices=ids[rig][name]; local index=1
 if name=="Dance" then dance=dance%#choices+1; index=dance end
 local a=Instance.new("Animation"); a.AnimationId="rbxassetid://"..choices[index]
 local ok,result=pcall(function() return animator:LoadAnimation(a) end); a:Destroy()
 if not ok then title.Text="Animation unavailable"; return end
 track=result; track.Priority=Enum.AnimationPriority.Action; track.Looped=name=="Dance"
 local played=pcall(function() track:Play(.15) end)
 title.Text=played and "MM2 | RightShift" or "Animation unavailable"
end
local function watch(c)
 if cc then cc:Disconnect() end
 stopFly(); stopEmote(); restoreCollision(); restoreMove(); restoreVisual()
 cc=c.DescendantAdded:Connect(function()
  task.defer(function() if live and p.Character==c then visuals() end end)
 end)
 visuals()
end
local function cleanup()
 if not live then return end; live=false
 for _,c in ipairs(cons) do c:Disconnect() end
 if cc then cc:Disconnect() end
 stopFly(); stopEmote(); clearESP(); restoreCollision(); restoreMove(); restoreVisual()
 p.CameraMaxZoomDistance=oldZoom
 for c,v in pairs(cameras) do if c.Parent then c.FieldOfView=v end end
 for k,v in pairs(lighting) do L[k]=v end
 gui:Destroy(); crossGui:Destroy(); _G.MM2UnifiedCleanup=nil
end
_G.MM2UnifiedCleanup=cleanup
toggle("ESP / roles","ESP",updateESP)
toggle("Speed 28","Speed")
toggle("High jump","Jump")
toggle("Fly","Fly",function() if not s.Fly then stopFly() end end)
toggle("Noclip","Noclip",function() if not s.Noclip then restoreCollision() end end)
toggle("Fullbright","Bright",function()
 for k,v in pairs(lighting) do L[k]=v end
 if s.Bright then L.Brightness=3; L.ClockTime=14; L.FogEnd=100000; L.GlobalShadows=false end
end)
toggle("Camera distance 128+","Zoom",function()
 p.CameraMaxZoomDistance=s.Zoom and math.max(oldZoom,128) or oldZoom
end)
local fovs={70,85,100,110}; local fi=0
local fb=button("FOV: default",function(b)
 fi=fi%#fovs+1; fov=fovs[fi]; camera(); b.Text="FOV: "..fov
end)
button("Reset FOV",function() fov=nil; camera(); fb.Text="FOV: default" end)
toggle("Crosshair","Crosshair",function() cross.Visible=s.Crosshair end)
toggle("Transparent character","Ghost",visuals)
toggle("Hide accessories","Accessories",visuals)
toggle("Visual Headless","Headless",visuals)
for _,entry in ipairs({{"Wave","Wave"},{"Point","Point"},{"Cheer","Cheer"},{"Laugh","Laugh"},{"Dance / next","Dance"}}) do
 local name=entry[2]; button(entry[1],function() emote(name) end)
end
button("Stop emote",stopEmote)
button("Close and restore",cleanup)
on(U.InputBegan,function(input,processed)
 if not processed and input.KeyCode==Enum.KeyCode.RightShift then panel.Visible=not panel.Visible end
end)
on(p.CharacterAdded,watch)
on(workspace:GetPropertyChangedSignal("CurrentCamera"),camera)
on(R.Stepped,function()
 if not s.Noclip then return end
 local c=p.Character; if not c then return end
 for _,part in ipairs(c:GetDescendants()) do
  if part:IsA("BasePart") then
   if coll[part]==nil then coll[part]=part.CanCollide end
   part.CanCollide=false
  end
 end
end)
local elapsed=0
on(R.Heartbeat,function(dt)
 local _,h,root=char()
 if h and h.Health>0 then
  if not move[h] then move[h]={h.WalkSpeed,h.JumpPower,h.JumpHeight} end
  h.WalkSpeed=s.Speed and 28 or move[h][1]
  h.JumpPower=s.Jump and 85 or move[h][2]
  h.JumpHeight=s.Jump and 15 or move[h][3]
 end
 if s.Fly and root and h and h.Health>0 then
  if not at or at.Parent~=root then
   stopFly(); fh=h; fa=h.AutoRotate
   at=Instance.new("Attachment"); at.Parent=root
   av=Instance.new("LinearVelocity"); av.Attachment0=at
   av.RelativeTo=Enum.ActuatorRelativeTo.World; av.MaxForce=math.huge; av.Parent=root
  end
  h.AutoRotate=false
  local c=workspace.CurrentCamera; local d=Vector3.zero
  if c and not U:GetFocusedTextBox() then
   if U:IsKeyDown(Enum.KeyCode.W) then d+=c.CFrame.LookVector end
   if U:IsKeyDown(Enum.KeyCode.S) then d-=c.CFrame.LookVector end
   if U:IsKeyDown(Enum.KeyCode.D) then d+=c.CFrame.RightVector end
   if U:IsKeyDown(Enum.KeyCode.A) then d-=c.CFrame.RightVector end
   if U:IsKeyDown(Enum.KeyCode.Space) then d+=Vector3.yAxis end
   if U:IsKeyDown(Enum.KeyCode.LeftControl) then d-=Vector3.yAxis end
  end
  av.VectorVelocity=d.Magnitude>0 and d.Unit*45 or Vector3.zero
 else stopFly() end
 elapsed+=dt
 if elapsed>=.25 then elapsed=0; updateESP() end
end)
if p.Character then watch(p.Character) end
end
