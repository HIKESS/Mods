local SDFAnubis_Stone_Quest = Class(function (self,inst)
    self.inst=inst
    self.anubis_stone_part1_found = false --mullock cheifs memorial
    self.anubis_stone_part2_found = false --pumpkin king
    self.anubis_stone_part3_found = false --shadow demons tomb
    self.anubis_stone_part4_found = false --king peregrin
end)

function SDFAnubis_Stone_Quest:GetAnubisStonePart1FoundStatus()
    return self.anubis_stone_part1_found
end

function SDFAnubis_Stone_Quest:GetAnubisStonePart2FoundStatus()
    return self.anubis_stone_part2_found
end
function SDFAnubis_Stone_Quest:GetAnubisStonePart3FoundStatus()
    return self.anubis_stone_part3_found
end
function SDFAnubis_Stone_Quest:GetAnubisStonePart4FoundStatus()
    return self.anubis_stone_part4_found
end

function SDFAnubis_Stone_Quest:SetAnubisStonePart1FoundStatus()
    self.anubis_stone_part1_found = true
end

function SDFAnubis_Stone_Quest:SetAnubisStonePart2FoundStatus()
    self.anubis_stone_part2_found = true
end

function SDFAnubis_Stone_Quest:SetAnubisStonePart3FoundStatus()
    self.anubis_stone_part3_found = true
end

function SDFAnubis_Stone_Quest:SetAnubisStonePart4FoundStatus()
    self.anubis_stone_part4_found = true
end

function SDFAnubis_Stone_Quest:OnSave()
    return{
	    anubis_stone_part1_found =self.anubis_stone_part1_found,
	    anubis_stone_part2_found =self.anubis_stone_part2_found,
	    anubis_stone_part3_found =self.anubis_stone_part3_found,
	    anubis_stone_part4_found =self.anubis_stone_part4_found,
    }
end

function SDFAnubis_Stone_Quest:OnLoad(data)
    if data.anubis_stone_part1_found ~= nil and self.anubis_stone_part1_found ~= data.anubis_stone_part1_found then
	self.anubis_stone_part1_found = data.anubis_stone_part1_found or false
    end
    if data.anubis_stone_part2_found ~= nil and self.anubis_stone_part2_found ~= data.anubis_stone_part2_found then
	self.anubis_stone_part2_found = data.anubis_stone_part2_found or false
    end
    if data.anubis_stone_part3_found ~= nil and self.anubis_stone_part3_found ~= data.anubis_stone_part3_found then
	self.anubis_stone_part3_found = data.anubis_stone_part3_found or false
    end
    if data.anubis_stone_part4_found ~= nil and self.anubis_stone_part4_found ~= data.anubis_stone_part4_found then
	self.anubis_stone_part4_found = data.anubis_stone_part4_found or false
    end
end

return SDFAnubis_Stone_Quest