local SDFChalice_Id_Key = Class(function (self,inst)
    self.inst=inst
    self.chalice_id_key = 0
end)

function SDFChalice_Id_Key:SetKey(val)
    self.chalice_id_key=val
end

function SDFChalice_Id_Key:GetKey()
     return self.chalice_id_key
end

function SDFChalice_Id_Key:OnSave()
    return{chalice_id_key=self.chalice_id_key}
end

function SDFChalice_Id_Key:OnLoad(data)
    self.chalice_id_key=data and data.chalice_id_key or 0
end

return SDFChalice_Id_Key