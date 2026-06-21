local SDFBookOfGallowmerePopupScreen = require("widgets/sdf_book_of_gallowmere_popupscreen")

AddClassPostConstruct("screens/playerhud", function(playerhud)
    playerhud.CloseSDFBookOfGallowmereScreen = function(self)
	if self.sdf_book_of_gallowmere_screen then
	    if self.sdf_book_of_gallowmere_screen.inst:IsValid() then
		GLOBAL.TheFrontEnd:PopScreen(self.sdf_book_of_gallowmere_screen)
	    end
	    self.sdf_book_of_gallowmere_screen = nil
	end
    end
	
    playerhud.OpenSDFBookOfGallowmereScreen = function(self)
	self:CloseSDFBookOfGallowmereScreen()
	self.sdf_book_of_gallowmere_screen = SDFBookOfGallowmerePopupScreen(self.owner)
	self:OpenScreenUnderPause(self.sdf_book_of_gallowmere_screen)
		
	return true
    end
end)