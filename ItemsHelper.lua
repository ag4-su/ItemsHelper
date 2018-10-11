local ItemsHelper = {}

ItemsHelper.MenuPath = {"Utility", "Items Helper"}
ItemsHelper.MEnabled = Menu.AddOptionBool(ItemsHelper.MenuPath, "Enabled", false)
ItemsHelper.MBlink = Menu.AddOptionBool(ItemsHelper.MenuPath, "Max Blink Range", false)
ItemsHelper.LocalHero = nil
ItemsHelper.TpPos = nil
local ItemArmlet ={}

-- Local Wrapper --
local Wrap = require("scripts.modules.WrapUtility")
--/\ Local Wrapper /\ --

function ItemsHelper.ResetVars()
	ItemsHelper.LocalHero = nil
	ItemArmlet = require("scripts.modules.Armlet")
		setmetatable(ItemArmlet, {__index = ItemsHelper})
	ItemDagon = require("scripts.modules.Dagon")
		setmetatable(ItemArmlet, {__index = ItemsHelper})
end

ItemsHelper.ResetVars()

function ItemsHelper.CheckBlink(p1, p2, p3, p4)
	if p4 == Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION and p1 ~= nil and p1 ~= 0 then
		local AbilityName = Ability.GetName(p1)
		if AbilityName == 'item_tpscroll' or AbilityName == 'item_travel_boots' or AbilityName == 'item_travel_boots_2' then
			ItemsHelper.TpPos = p2
		end
	end
	if p4 == Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION and p1 ~= nil and p1 ~= 0 and Ability.GetName(p1) == 'item_blink' then
		local k1 = Entity.GetAbsOrigin(p3)
		if NPC.HasModifier(p3, "modifier_teleporting")	then
			if ItemsHelper.TpPos then
				k1 = ItemsHelper.TpPos
				ItemsHelper.TpPos = nil
			end
		end
		local k3 = p2:Distance(k1):Length()
		if k3 < (1199 + NPC.GetCastRangeBonus(p3)) then return false end
		Ability.CastPosition(p1, Wrap.Extend(k1, p2, 1199 + NPC.GetCastRangeBonus(p3)))
		return true
	end
end

function ItemsHelper.OnPrepareUnitOrders(p1)
	if Menu.IsEnabled(ItemsHelper.MEnabled) == false or ItemsHelper.LocalHero == nil or p1 == nil then return end

	if Menu.IsEnabled(ItemsHelper.MBlink) and ItemsHelper.CheckBlink(p1.ability, p1.position, p1.npc, p1.order) then
		return false
	end
	
	ItemArmlet.OnPrepareUnitOrders(p1)
	
	return true
end

function ItemsHelper.OnUpdate(p1)
	ItemsHelper.LocalHero = Heroes.GetLocal()
	if ItemsHelper.LocalHero == nil then return end
	ItemArmlet.OnUpdate(p1)
	if Menu.IsEnabled(ItemDagon.optionEnable) then
		ItemDagon.OnUpdate()
	end
end

function ItemsHelper.OnUnitAnimation( animation )
	ItemArmlet.OnUnitAnimation( animation )
end

function ItemsHelper.OnProjectile( projectile )
	ItemArmlet.OnProjectile( projectile )
end

function ItemsHelper.OnGameStart()
	ItemsHelper.ResetVars()
end

function ItemsHelper.OnGameEnd()
	ItemsHelper.ResetVars()
end

return ItemsHelper