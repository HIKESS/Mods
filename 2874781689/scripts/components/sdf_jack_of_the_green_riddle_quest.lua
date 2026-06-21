local SDFJack_Of_The_Green_Riddle_Quest = Class(function (self,inst)
    self.inst=inst
    self.riddle_completed_id_lock = {false,false,false,false}
    self.riddle_solved_id_lock = {false,false,false,false}

    self.riddle_one_lock = {false,false,false,false,false}

    --testing
    --self.riddle_id_completed_lock = {true,true,true,true}
    --testing
    --self.riddle_solved_id_lock = {true,true,true,true}

    self.riddle_master_enabled = false
    self.book_of_gallowmere_enabled = false
    self.book_of_gallowmere_riddle_counter = 0
    self.book_of_gallowmere_restored_enabled = false
    self.secluded_lifebottle_found = false
    self.meet_jack = false
end)

---
function SDFJack_Of_The_Green_Riddle_Quest:GetRiddleCompletedIdLockNew(riddleCompletedIdLock)
    local riddleCompletedIdLockNew = 0

    --Check for first true riddleCompletedIdLockNew
    for i, v in ipairs(riddleCompletedIdLock) do
	if v == false then
		riddleCompletedIdLockNew = i
		return riddleCompletedIdLockNew
	end
    end
    return riddleCompletedIdLockNew
end

function SDFJack_Of_The_Green_Riddle_Quest:GetRiddleCompletedIdLock()
    return self.riddle_completed_id_lock
end

function SDFJack_Of_The_Green_Riddle_Quest:SetCompletedIdLock(lock,key)
    lock[key] = true
end
---

---
function SDFJack_Of_The_Green_Riddle_Quest:GetRiddleSolvedIdLockNew(riddleSolvedIdLock)
    local riddleSolvedIdLockNew = 0

    --Check for first true riddleSolvedIdLockNew
    for i, v in ipairs(riddleSolvedIdLock) do
	if v == false then
		riddleSolvedIdLockNew = i
		return riddleSolvedIdLockNew
	end
    end
    return riddleSolvedIdLockNew
end

function SDFJack_Of_The_Green_Riddle_Quest:GetRiddleSolvedIdLock()
    return self.riddle_solved_id_lock
end

function SDFJack_Of_The_Green_Riddle_Quest:CheckRiddleSolvedIdLock(lock,key)
     return lock[key]
end

function SDFJack_Of_The_Green_Riddle_Quest:SetRiddleSolvedIdLock(lock,key)
    lock[key] = true
end

function SDFJack_Of_The_Green_Riddle_Quest:RemoveRiddleSolvedIdLock(lock,key)
     lock[key] = false
end
---

---
function SDFJack_Of_The_Green_Riddle_Quest:CheckRiddleMaster()
    return self.riddle_master_enabled
end

function SDFJack_Of_The_Green_Riddle_Quest:EnableRiddleMaster()
    self.riddle_master_enabled = true
end
---

---
function SDFJack_Of_The_Green_Riddle_Quest:CheckBookOfGallowmere()
    return self.book_of_gallowmere_enabled
end

function SDFJack_Of_The_Green_Riddle_Quest:GetBookOfGallowmereRiddleCounter()
    return self.book_of_gallowmere_riddle_counter
end

function SDFJack_Of_The_Green_Riddle_Quest:CheckBookOfGallowmereRestored()
    return self.book_of_gallowmere_restored_enabled
end

function SDFJack_Of_The_Green_Riddle_Quest:EnableBookOfGallowmere()
    self.book_of_gallowmere_enabled = true
end

function SDFJack_Of_The_Green_Riddle_Quest:SetBookOfGallowmereRiddleCounter(val)
    self.book_of_gallowmere_riddle_counter = val
end

function SDFJack_Of_The_Green_Riddle_Quest:EnableBookOfGallowmereRestored()
    self.book_of_gallowmere_restored_enabled = true
end
---

---
function SDFJack_Of_The_Green_Riddle_Quest:CheckMeetJack()
    return self.meet_jack
end

function SDFJack_Of_The_Green_Riddle_Quest:EnableMeetJack()
    self.meet_jack = true
end
---

---
--Riddle 1
function SDFJack_Of_The_Green_Riddle_Quest:GetRiddleOneLock()
    return self.riddle_one_lock
end

function SDFJack_Of_The_Green_Riddle_Quest:CheckRiddleOneLock(lock,key)
     return lock[key]
end

function SDFJack_Of_The_Green_Riddle_Quest:SetRiddleOneLock(lock,key)
    lock[key] = true
end

function SDFJack_Of_The_Green_Riddle_Quest:GetRiddleOneStarsFound(riddleOneLock)
    local riddleOneStarsFound = 0

    --Check for first true riddleOneStarsFound
    for i, v in ipairs(riddleOneLock) do
	if v == true then
		riddleOneStarsFound = riddleOneStarsFound + 1
	end
    end
    return riddleOneStarsFound
end
---

---
function SDFJack_Of_The_Green_Riddle_Quest:OnSave()
    return{
	    riddle_completed_id_lock=self.riddle_completed_id_lock,
	    riddle_solved_id_lock=self.riddle_solved_id_lock,
	    riddle_master_enabled=self.riddle_master_enabled,
	    book_of_gallowmere_enabled=self.book_of_gallowmere_enabled,
	    book_of_gallowmere_riddle_counter=self.book_of_gallowmere_riddle_counter,
	    book_of_gallowmere_restored_enabled=self.book_of_gallowmere_restored_enabled,
	    meet_jack=self.meet_jack,
    }
end

function SDFJack_Of_The_Green_Riddle_Quest:OnLoad(data)
    if data.riddle_completed_id_lock ~= nil and self.riddle_completed_id_lock ~= data.riddle_completed_id_lock then
	self.riddle_completed_id_lock = data.riddle_completed_id_lock or 
	{false,false,false,false}
    end

    if data.riddle_solved_id_lock ~= nil and self.riddle_solved_id_lock ~= data.riddle_solved_id_lock then
	self.riddle_solved_id_lock = data.riddle_solved_id_lock or 
	{false,false,false,false}
    end

    if data.riddle_master_enabled ~= nil and self.riddle_master_enabled ~= data.riddle_master_enabled then
	self.riddle_master_enabled = data.riddle_master_enabled or false
    end

    if data.book_of_gallowmere_enabled ~= nil and self.book_of_gallowmere_enabled ~= data.book_of_gallowmere_enabled then
	self.book_of_gallowmere_enabled = data.book_of_gallowmere_enabled or false
    end

    if data.book_of_gallowmere_riddle_counter ~= nil and self.book_of_gallowmere_riddle_counter ~= data.book_of_gallowmere_riddle_counter then
	self.book_of_gallowmere_riddle_counter = data.book_of_gallowmere_riddle_counter or 0
    end

    if data.book_of_gallowmere_restored_enabled ~= nil and self.book_of_gallowmere_restored_enabled ~= data.book_of_gallowmere_restored_enabled then
	self.book_of_gallowmere_restored_enabled = data.book_of_gallowmere_restored_enabled or false
    end

    if data.meet_jack ~= nil and self.meet_jack ~= data.meet_jack then
	self.meet_jack = data.meet_jack or false
    end
end

return SDFJack_Of_The_Green_Riddle_Quest