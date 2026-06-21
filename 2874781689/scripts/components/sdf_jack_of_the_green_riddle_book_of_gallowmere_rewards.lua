local SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere_Rewards = Class(function (self,inst)
    self.inst=inst
    self.rewardBank={}
    self.bonusRewardBank={}
end)

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere_Rewards:SetRewardBank(val)
    self.rewardBank=val
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere_Rewards:GetRewardBank()
     return self.rewardBank
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere_Rewards:GetReward(bank)
    return bank[math.random(#bank)]
end


function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere_Rewards:SetBonusRewardBank(val)
    self.bonusRewardBank=val
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere_Rewards:GetBonusRewardBank()
     return self.bonusRewardBank
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere_Rewards:GetBonusReward(bank)
    return bank[math.random(#bank)]
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere_Rewards:OnSave()
    return{
	    --rewardBank=self.rewardBank,
	    --bonusRewardBank=self.bonusRewardBank,
    }
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere_Rewards:OnLoad(data)
    --Can be turned off for more updates.
    --[[if data.rewardBank ~= nil and self.rewardBank ~= data.rewardBank then
	self.rewardBank = data.rewardBank or {}
    end
    if data.bonusRewardBank ~= nil and self.bonusRewardBank ~= data.bonusRewardBank then
	self.bonusRewardBank = data.bonusRewardBank or {}
    end]]
end

return SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere_Rewards