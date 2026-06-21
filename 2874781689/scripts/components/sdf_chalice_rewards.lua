local SDFChalice_Rewards = Class(function (self,inst)
    self.inst=inst
    self.rewardBank={}
    self.bonusRewardBank={}
end)

function SDFChalice_Rewards:SetRewardBank(val)
    self.rewardBank=val
end

function SDFChalice_Rewards:GetRewardBank()
     return self.rewardBank
end

function SDFChalice_Rewards:GetReward(bank,chalice)
    return bank[chalice]
end


function SDFChalice_Rewards:SetBonusRewardBank(val)
    self.bonusRewardBank=val
end

function SDFChalice_Rewards:GetBonusRewardBank()
     return self.bonusRewardBank
end

function SDFChalice_Rewards:GetBonusReward(bank)
    return bank[math.random(#bank)]
end

function SDFChalice_Rewards:OnSave()
    return{
	    rewardBank=self.rewardBank,
	    bonusRewardBank=self.bonusRewardBank,
    }
end

function SDFChalice_Rewards:OnLoad(data)
    if data.rewardBank ~= nil and self.rewardBank ~= data.rewardBank then
	self.rewardBank = data.rewardBank or {}
    end
    if data.bonusRewardBank ~= nil and self.bonusRewardBank ~= data.bonusRewardBank then
	self.bonusRewardBank = data.bonusRewardBank or {}
    end
end

return SDFChalice_Rewards