local SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere = Class(function (self,inst)
    self.inst=inst
    self.riddleBank={}
    self.current_riddle = 0
    self.previous_riddle = 0
    self.riddle_counter = 0

    self.book_of_gallowmere_enabled = false
end)

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:SetRiddleBank(val)
    self.riddleBank=val
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:GetRiddleBank()
     return self.riddleBank
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:GetRiddle(bank)
    return bank[math.random(#bank)]
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:GetCurrentRiddle()
    return self.current_riddle
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:SetCurrentRiddle(riddleID)
    self.current_riddle = riddleID
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:GetPreviousRiddle()
    return self.previous_riddle
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:SetPreviousRiddle(riddleID)
    self.previous_riddle = riddleID
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:GetRiddleCounter()
    return self.riddle_counter
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:SetCounterRiddle(riddleNum)
    self.riddle_counter = riddleNum
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:CheckBookOfGallowmere()
    return self.book_of_gallowmere_enabled
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:EnableBookOfGallowmere()
    self.book_of_gallowmere_enabled = true
end


function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:OnSave()
    return{
	    riddleBank=self.riddleBank,
	    current_riddle=self.current_riddle,
	    previous_riddle=self.previous_riddle,
	    riddle_counter=self.riddle_counter,
	    book_of_gallowmere_enabled=self.book_of_gallowmere_enabled,
    }
end

function SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere:OnLoad(data)
    if data.riddleBank ~= nil and self.riddleBank ~= data.riddleBank then
	self.riddleBank = data.riddleBank or {}
    end
    if data.current_riddle ~= nil and self.current_riddle ~= data.current_riddle then
	self.current_riddle = data.current_riddle or 0
    end
    if data.previous_riddle ~= nil and self.previous_riddle ~= data.previous_riddle then
	self.previous_riddle = data.previous_riddle or 0
    end
    if data.riddle_counter ~= nil and self.riddle_counter ~= data.riddle_counter then
	self.riddle_counter = data.riddle_counter or 0
    end
    if data.book_of_gallowmere_enabled ~= nil and self.book_of_gallowmere_enabled ~= data.book_of_gallowmere_enabled then
	self.book_of_gallowmere_enabled = data.book_of_gallowmere_enabled or false
    end
end

return SDFJack_Of_The_Green_Riddle_Book_Of_Gallowmere