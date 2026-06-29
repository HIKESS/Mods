local function onPlayChange(inst)
local self=inst.components.aipc_score_ball_effect
if self~=nil and self.ball~=nil then
local xSpeed=self.xSpeed:value()
if xSpeed~=0 then
self:ClientPlay()
else
self:ClientStop()
end
end
end

local ScoreBallEffect=Class(function(self,inst)
self.inst=inst
self.ball=nil

self.ySpeed=net_float(inst.GUID,"aipc_score_ball_y_speed")


self.continueBump=net_bool(inst.GUID,"aipc_score_ball_continue")
self.xSpeed=net_float(inst.GUID,"aipc_score_ball_x_speed","aipc_score_ball_x_speed_dirty")
self.y=net_float(inst.GUID,"aipc_score_ball_y")

self.inst:ListenForEvent("aipc_score_ball_x_speed_dirty",onPlayChange)
end)





function ScoreBallEffect:StartPlay(continueBump,speed,y)
self.continueBump:set(continueBump==true)
self.y:set(y)
self.xSpeed:set(speed)
end


function ScoreBallEffect:StopPlay()
self.xSpeed:set(0)
end





function ScoreBallEffect:ClientPlay()
local newJump=self.continueBump:value()~=true

if newJump then
local anim=math.random() > .5 and "runLeft" or "runRight"

if self.ball.AnimState:IsCurrentAnimation("idle") then
self.ball.AnimState:PlayAnimation(anim,true)
elseif not self.ball.AnimState:IsCurrentAnimation(anim) then
local len=self.ball.AnimState:GetCurrentAnimationLength()/FRAMES
local time=self.ball.AnimState:GetCurrentAnimationTime()
local reverseTime=len-time
self.ball.AnimState:PlayAnimation(anim,true)
self.ball.AnimState:SetTime(math.max(reverseTime,1))
end
end

self.ball.AnimState:SetDeltaTimeMultiplier(0.3+math.sqrt(self.xSpeed:value()*5))
self.ball.AnimState:Resume()


if newJump then
self.ball.Physics:Teleport(0,self.y:value(),0)
end

self.inst:StartUpdatingComponent(self)
end


function ScoreBallEffect:ClientStop()
self.ball.AnimState:Pause()

self.ball.Physics:Teleport(0,0,0)
self.inst:StopUpdatingComponent(self)
end


function ScoreBallEffect:SyncY(y,ySpeed)
self.y:set(y)
self.ySpeed:set(ySpeed)
end

function ScoreBallEffect:OnUpdate(dt)
local x,y,z=self.ball.Transform:GetWorldPosition()
local realY=self.y:value()
local targetY=y+self.ySpeed:value()*dt


local diffY=targetY*0.95+realY*0.05

self.ball.Physics:Teleport(0,diffY,0)
end


return ScoreBallEffect