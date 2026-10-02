local P=game:GetService("Players").LocalPlayer
local RS=game:GetService("RunService")
local PG=P:WaitForChild("PlayerGui")
local C,H
local T,S={},{}
local rec,play,pause,loop,esp=false,false,false,false,false
local sp={.5,1,2,4};local si=2;local clock=0;local idx=1
local sample=1/30;local last=0;local start=0

local function char()
 C=P.Character or P.CharacterAdded:Wait()
 H=C:WaitForChild("HumanoidRootPart")
end
char()
P.CharacterAdded:Connect(function()task.wait(.3);char()end)

local G=Instance.new("ScreenGui",PG);G.Name="TrackFlowGui";G.ResetOnSpawn=false
local F=Instance.new("Frame",G);F.Size=UDim2.fromOffset(300,410);F.Position=UDim2.new(1,-315,.5,-205)
F.BackgroundColor3=Color3.fromRGB(20,20,25);F.Visible=false
Instance.new("UICorner",F).CornerRadius=UDim.new(0,12)

local function b(n,t,x,y,w)
 local q=Instance.new("TextButton",F);q.Name=n;q.Text=t;q.Position=UDim2.fromOffset(x,y)
 q.Size=UDim2.fromOffset(w or 85,35);q.BackgroundColor3=Color3.fromRGB(35,35,43)
 q.TextColor3=Color3.new(1,1,1);q.BorderSizePixel=0
 Instance.new("UICorner",q).CornerRadius=UDim.new(0,7)
 return q
end

local title=b("Title","TRACKFLOW",10,10,280,35)
local R=b("Record","● REC",10,55)
local PL=b("Play","▶ PLAY",105,55)
local PA=b("Pause","Ⅱ PAUSE",200,55)
local ST=b("Stop","■ STOP",10,100)
local RW=b("Rewind","↶ REWIND",105,100)
local E=b("ESP","ESP OFF",200,100)
local SP=b("Speed","1x",10,145,85)
local LP=b("Loop","LOOP OFF",105,145,85)
local SV=b("Save","SAVE",200,145,85)

local NM=Instance.new("TextBox",F)
NM.PlaceholderText="Nama track...";NM.Text=""
NM.Position=UDim2.fromOffset(10,190);NM.Size=UDim2.fromOffset(275,35)
NM.BackgroundColor3=Color3.fromRGB(30,30,37);NM.TextColor3=Color3.new(1,1,1)
Instance.new("UICorner",NM).CornerRadius=UDim.new(0,7)

local List=Instance.new("ScrollingFrame",F)
List.Position=UDim2.fromOffset(10,235);List.Size=UDim2.fromOffset(275,120)
List.BackgroundColor3=Color3.fromRGB(27,27,33);List.BorderSizePixel=0
List.ScrollBarThickness=4
local L=Instance.new("UIListLayout",List);L.Padding=UDim.new(0,4)

local TF=b("TF","TF",0,0,50,50)
TF.Position=UDim2.new(1,-60,.5,-25);TF.Parent=G

local X=b("Close","×",260,10,30,35)
local path=Instance.new("Folder",workspace);path.Name="TrackFlowPath"

local function status(x)title.Text=x end
local function clear()
 for _,v in ipairs(path:GetChildren())do v:Destroy()end
end

local function draw()
 clear();if not esp or #T<2 then return end
 for i=1,#T-1 do
  local a,z=T[i].c,T[i+1].c
  local d=(a.Position-z.Position).Magnitude
  if d>.05 then
   local p=Instance.new("Part",path)
   p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
   p.Material=Enum.Material.Neon;p.Size=Vector3.new(.1,.1,d)
   p.CFrame=CFrame.lookAt((a.Position+z.Position)/2,z.Position)
  end
 end
end

local function carry()
 if not C then return false end
 for _,v in ipairs(C:GetDescendants())do
  if v:IsA("WeldConstraint") or v:IsA("Weld") then
   if v.Part0 and v.Part1 then return true end
  end
 end
 return false
end

R.MouseButton1Click:Connect(function()
 if rec then rec=false;status("REC DONE");return end
 T={};rec=true;play=false;start=os.clock();last=0;status("RECORDING")
end)

PL.MouseButton1Click:Connect(function()
 if #T<2 then status("NO TRACK");return end
 rec=false;play=true;pause=false;clock=0;idx=1;H.CFrame=T[1].c;status("PLAYING")
end)

PA.MouseButton1Click:Connect(function()
 if not play then return end
 pause=not pause;status(pause and "PAUSED" or "PLAYING")
end)

ST.MouseButton1Click:Connect(function()
 rec=false;play=false;pause=false;status("STOP")
end)

RW.MouseButton1Click:Connect(function()
 if #T<2 then return end
 clock=math.max(0,clock-1);idx=1
 while idx<#T and T[idx+1].t<=clock do idx+=1 end
end)

SP.MouseButton1Click:Connect(function()
 si=si%#sp+1;SP.Text=sp[si].."x"
end)

LP.MouseButton1Click:Connect(function()
 loop=not loop;LP.Text=loop and "LOOP ON" or "LOOP OFF"
end)

E.MouseButton1Click:Connect(function()
 esp=not esp;E.Text=esp and "ESP ON" or "ESP OFF";draw()
end)

SV.MouseButton1Click:Connect(function()
 if #T<2 then status("NO TRACK");return end
 local n=NM.Text~="" and NM.Text or "Track "..(#S+1)
 S[n]={}
 for i,v in ipairs(T)do S[n][i]={t=v.t,c=v.c}end
 local q=b(n,n,0,0,255,30)
 q.Parent=List
 q.MouseButton1Click:Connect(function()
  T={}
  for i,v in ipairs(S[n])do T[i]={t=v.t,c=v.c}end
  draw();status("LOADED "..n)
 end)
end)

X.MouseButton1Click:Connect(function()F.Visible=false;TF.Visible=true end)
TF.MouseButton1Click:Connect(function()F.Visible=true;TF.Visible=false end)

RS.Heartbeat:Connect(function()
 if rec and H then
  local t=os.clock()-start
  if t-last>=sample then
   last=t;T[#T+1]={t=t,c=H.CFrame}
  end
 end
end)

RS.RenderStepped:Connect(function(dt)
 if not play or pause or #T<2 or carry() then return end
 clock+=dt*sp[si]
 while idx<#T and T[idx+1].t<=clock do idx+=1 end
 if idx>=#T then
  if loop then clock=0;idx=1;H.CFrame=T[1].c
  else play=false;status("PLAY DONE");H.CFrame=T[#T].c end
  return
 end
 local a,z=T[idx],T[idx+1]
 local k=(clock-a.t)/math.max(z.t-a.t,.001);k=math.clamp(k,0,1)
 H.CFrame=H.CFrame:Lerp(a.c:Lerp(z.c,k),1-math.exp(-22*dt))
end)
