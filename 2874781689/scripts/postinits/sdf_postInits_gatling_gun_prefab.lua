--Used with gatling gun projectile targeting
function SDFTotemTargetsPostInit(inst)
    inst:AddTag("SDF_Totem_Target")
end
AddPrefabPostInit("pighead", SDFTotemTargetsPostInit)
AddPrefabPostInit("mermhead", SDFTotemTargetsPostInit)

function SDFFloatingTargetsPostInit(inst)
    inst:AddTag("SDF_Floating_Target")
end
AddPrefabPostInit("eyeofterror", SDFFloatingTargetsPostInit)
AddPrefabPostInit("eyeofterror_mini", SDFFloatingTargetsPostInit)
AddPrefabPostInit("eyeofterror_mini_grounded", SDFFloatingTargetsPostInit)
AddPrefabPostInit("twinofterror1", SDFFloatingTargetsPostInit)
AddPrefabPostInit("twinofterror2", SDFFloatingTargetsPostInit)
AddPrefabPostInit("malbatross", SDFFloatingTargetsPostInit)

function SDFGenericTargetsPostInit(inst)
    inst:AddTag("SDF_Generic_Target")
end
AddPrefabPostInit("skeleton", SDFGenericTargetsPostInit)
AddPrefabPostInit("scorched_skeleton", SDFGenericTargetsPostInit)