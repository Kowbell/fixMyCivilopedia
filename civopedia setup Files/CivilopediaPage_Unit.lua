-- ===========================================================================
--	Civilopedia - Unit Page Layout
-- ===========================================================================

PageLayouts["Unit" ] = function(page)
	local sectionId = page.SectionId;
	local pageId = page.PageId;

	SetPageHeader(page.Title);
	SetPageSubHeader(page.Subtitle);

	local unit = GameInfo.Units[pageId];
	if(unit == nil) then
		return;
	end
	local unitType = unit.UnitType;

	-- Get some info!
	local unique_to = {};
	if(unit.TraitType) then
		local traitType = unit.TraitType;
		for row in GameInfo.LeaderTraits() do
			if(row.TraitType == traitType) then
				local leader = GameInfo.Leaders[row.LeaderType];
				if(leader) then
					table.insert(unique_to, {"ICON_" .. row.LeaderType, leader.Name, row.LeaderType});
				end
			end
		end

		for row in GameInfo.CivilizationTraits() do
			if(row.TraitType == traitType) then
				local civ = GameInfo.Civilizations[row.CivilizationType];
				if(civ) then
					table.insert(unique_to, {"ICON_" .. row.CivilizationType, civ.Name, row.CivilizationType});
				end
			end
		end
	end

	local replaces;
	local replaced_by = {};
	for row in GameInfo.UnitReplaces() do
		if(row.CivUniqueUnitType == unitType) then
			local u = GameInfo.Units[row.ReplacesUnitType]; 
			if(u and u.TraitType ~= "TRAIT_BARBARIAN") then
				replaces = {"ICON_" .. u.UnitType, u.Name, u.UnitType};
			end
		end

		if(row.ReplacesUnitType == unitType) then
			local u = GameInfo.Units[row.CivUniqueUnitType];
			if(u and u.TraitType ~= "TRAIT_BARBARIAN") then
				table.insert(replaced_by, {"ICON_" .. u.UnitType, u.Name, u.UnitType});
			end
		end
	end

	local upgrades_to;			-- the unit icon of what it upgrades to.
	local upgrades_from = {};	-- the unit(s) of what it upgrades from.
	for row in GameInfo.UnitUpgrades() do
		if(row.Unit == unitType) then
			local u = GameInfo.Units[row.UpgradeUnit];
			if(u and u.TraitType ~= "TRAIT_BARBARIAN") then
				upgrades_to = {"ICON_" .. u.UnitType, u.Name, u.UnitType};
			end
		end

		if(row.UpgradeUnit == unitType) then
			local u = GameInfo.Units[row.Unit];
			if(u and u.TraitType ~= "TRAIT_BARBARIAN") then
				table.insert(upgrades_from, {"ICON_" .. u.UnitType, u.Name, u.UnitType});
			end
		end
	end

	local requires_buildings = {};
	for row in GameInfo.Unit_BuildingPrereqs() do
		if(row.Unit == unitType) then
			local building = GameInfo.Buildings[row.PrereqBuilding];
			if(building) then
				table.insert(requires_buildings, {"ICON_" .. building.BuildingType, building.Name, building.BuildingType});
			end
		end
	end

	local improvements = {};
	for row in GameInfo.Improvement_ValidBuildUnits() do
		if(row.UnitType == unitType) then
			local improvement = GameInfo.Improvements[row.ImprovementType];
			table.insert(improvements, improvement);
		end
	end

	local routes = {};
	for row in GameInfo.Route_ValidBuildUnits() do
		if(row.UnitType == unitType) then
			local route = GameInfo.Routes[row.RouteType];
			table.insert(routes, route);
		end
	end
	
	-- Right Column!
	AddPortrait("ICON_" .. unitType);

	AddRightColumnStatBox("LOC_UI_PEDIA_TRAITS", function(s)
		if(#unique_to > 0) then
			s:AddHeader("LOC_UI_PEDIA_UNIQUE_TO");
			for _, icon in ipairs(unique_to) do
				s:AddIconLabel(icon, icon[2]);
			end
		end
			
		if(replaces) then
			s:AddHeader("LOC_UI_PEDIA_REPLACES");
			s:AddIconLabel(replaces, replaces[2]);
		end

		if(#replaced_by > 0) then
			s:AddHeader("LOC_UI_PEDIA_REPLACED_BY");
			for _, icon in ipairs(replaced_by) do
				s:AddIconLabel(icon, icon[2]);
			end
		end

		if(replaces or #replaced_by > 0) then
			s:AddSeparator();
		end

		if(upgrades_to or #upgrades_from > 0) then

			if(upgrades_to) then
				s:AddHeader("LOC_UI_PEDIA_UPGRADES_TO");
				s:AddIconLabel(upgrades_to, upgrades_to[2]);
			end

			if(#upgrades_from > 0) then
				s:AddHeader("LOC_UI_PEDIA_UPGRADE_FROM");
				for _, icon in ipairs(upgrades_from) do
					s:AddIconLabel(icon, icon[2]);
				end
			end

			s:AddSeparator();
		end

		if(unit.PromotionClass ~= nil) then
			local promotionClassInfo = GameInfo.UnitPromotionClasses[unit.PromotionClass];
			if (promotionClassInfo ~= nil) then
				s:AddLabel(Locale.Lookup("LOC_UNIT_PROMOTION_CLASS", promotionClassInfo.Name));
			end
		end

		if(unit.BaseMoves ~= 0 and not unit.IgnoreMoves) then
			s:AddIconNumberLabel({"ICON_MOVES", nil,"MOVEMENT_1"}, unit.BaseMoves, "LOC_UI_PEDIA_MOVEMENT_POINTS");
		end

		if(unit.Combat ~= 0) then
			s:AddIconNumberLabel({"ICON_STRENGTH", nil,"COMBAT_5"}, unit.Combat, "LOC_UI_PEDIA_MELEE_STRENGTH");
		end

		if(unit.RangedCombat ~= 0) then
			s:AddIconNumberLabel({"ICON_RANGED_STRENGTH", nil,"COMBAT_5"}, unit.RangedCombat, "LOC_UI_PEDIA_RANGED_STRENGTH");
		end

		if(unit.Bombard ~= 0) then
			s:AddIconNumberLabel({"ICON_BOMBARD", nil,"COMBAT_5"}, unit.Bombard, "LOC_UI_PEDIA_BOMBARD_STRENGTH");
		end

		if(unit.ReligiousStrength ~= 0) then
			s:AddIconNumberLabel({"ICON_RELIGION", nil,"FAITH_6"}, unit.ReligiousStrength, "LOC_UI_PEDIA_RELIGIOUS_STRENGTH");
		end
		
		if(unit.AntiAirCombat ~= 0) then
			s:AddIconNumberLabel({"ICON_STATS_ANTIAIR", nil,"COMBAT_5"}, unit.AntiAirCombat, "LOC_UI_PEDIA_ANTIAIR_STRENGTH");
		end

		if(unit.Range ~= 0) then
			s:AddIconNumberLabel({"ICON_RANGE", nil,"COMBAT_5"}, unit.Range, "LOC_UI_PEDIA_RANGE");
		end

		if(unit.SpreadCharges ~= 0) then
			s:AddIconNumberLabel({"ICON_RELIGION", nil,"FAITH_6"}, unit.SpreadCharges, "LOC_UI_PEDIA_SPREAD_CHARGES");
		end

		if(unit.BuildCharges ~= 0) then
			s:AddIconNumberLabel({"ICON_BUILD_CHARGES", nil,"IMPROVEMENTS"}, unit.BuildCharges, "LOC_UI_PEDIA_BUILD_CHARGES");
		end		

		local airSlots = unit.AirSlots or 0;
		if(airSlots ~= 0) then
			s:AddLabel(Locale.Lookup("LOC_TYPE_TRAIT_AIRSLOTS", airSlots));
		end

		s:AddSeparator();
	end);

	AddRightColumnStatBox("LOC_UI_PEDIA_REQUIREMENTS", function(s)
		s:AddSeparator();
		if(unit.PrereqTech or unit.PrereqCivic or unit.PrereqDistrict or unit.StrategicResource or #requires_buildings > 0) then
			if(unit.PrereqDistrict ~= nil) then
				local district = GameInfo.Districts[unit.PrereqDistrict];
				if(district) then
					s:AddHeader("LOC_DISTRICT_NAME");
					s:AddIconLabel({"ICON_" .. district.DistrictType, district.Name, district.DistrictType}, district.Name);
				end
			end

			if(unit.PrereqCivic ~= nil) then
				local civic = GameInfo.Civics[unit.PrereqCivic];
				if(civic) then
					s:AddHeader("LOC_CIVIC_NAME");
					s:AddIconLabel({"ICON_" .. civic.CivicType, civic.Name, civic.CivicType}, civic.Name);
				end
			end

			if(unit.PrereqTech ~= nil) then
				local technology = GameInfo.Technologies[unit.PrereqTech];
				if(technology) then
					s:AddHeader("LOC_TECHNOLOGY_NAME");
					s:AddIconLabel({"ICON_" .. technology.TechnologyType, technology.Name, technology.TechnologyType}, technology.Name);
				end
			end

			if(unit.StrategicResource ~= nil) then
				local resource = GameInfo.Resources[unit.StrategicResource];
				if(resource) then
					s:AddHeader("LOC_RESOURCE_NAME");
					s:AddIconLabel({"ICON_" .. resource.ResourceType, resource.Name, resource.ResourceType}, resource.Name);
				end
			end

			if(#requires_buildings > 0) then
				s:AddHeader("LOC_BUILDING_NAME");		
				for i,v in ipairs(requires_buildings) do
					s:AddIconLabel(v, v[2]);
				end
			end

			s:AddSeparator();
		end
				
		if(unit.CanTrain and not unit.MustPurchase) then
			local yield = GameInfo.Yields["YIELD_PRODUCTION"];
			if(yield) then
				s:AddHeader("LOC_UI_PEDIA_PRODUCTION_COST");
				local t = Locale.Lookup("LOC_UI_PEDIA_BASE_COST", tonumber(unit.Cost), yield.IconString, yield.Name);
				s:AddLabel(t);
			end
		end

		if(unit.PurchaseYield) then	
			local y = GameInfo.Yields[unit.PurchaseYield];
			if(y) then
				s:AddHeader("LOC_UI_PEDIA_PURCHASE_COST");
				local t = Locale.Lookup("LOC_UI_PEDIA_BASE_COST", tonumber(unit.Cost), y.IconString, y.Name);
				s:AddLabel(t);
			end
		end
	
		if(tonumber(unit.Maintenance) ~= 0) then
			local yield = GameInfo.Yields["YIELD_GOLD"];
			if(yield) then
				s:AddHeader("LOC_UI_PEDIA_MAITENANCE_COST");
				local t = Locale.Lookup("LOC_UI_PEDIA_BASE_COST", tonumber(unit.Maintenance), yield.IconString, yield.Name );
				s:AddLabel(t);
			end
		end
		s:AddSeparator();
	end);

	AddRightColumnStatBox("LOC_UI_PEDIA_USAGE", function(s)
		s:AddSeparator();
		if(#improvements > 0 or #routes > 0) then
			s:AddHeader("LOC_UI_PEDIA_USAGE_CAN_CONSTRUCT");

			if(#improvements <= 3) then
				for i,v in ipairs(improvements) do
					s:AddIconLabel({"ICON_" .. v.ImprovementType, v.Name, v.ImprovementType}, v.Name);
				end
			else
				local icons = {};
				for _, v in ipairs(improvements) do
					table.insert(icons, {"ICON_" .. v.ImprovementType, v.Name, v.ImprovementType});	
				
					if(#icons == 4) then
						s:AddIconList(icons[1], icons[2], icons[3], icons[4]);
						icons = {};
					end
				end

				if(#icons > 0) then
					s:AddIconList(icons[1], icons[2], icons[3], icons[4]);
				end
			end
			
			for _ ,v in ipairs(routes) do
				s:AddLabel("[ICON_BULLET] " .. Locale.Lookup(v.Name));
			end
			
		end

		s:AddSeparator();
	end);

	-- Left Column!
	AddChapter("LOC_UI_PEDIA_DESCRIPTION", unit.Description);

	local chapters = GetPageChapters(page.PageLayoutId);
	for i, chapter in ipairs(chapters) do
		local chapterId = chapter.ChapterId;
		local chapter_header = GetChapterHeader(sectionId, pageId, chapterId);
		local chapter_body = GetChapterBody(sectionId, pageId, chapterId);

		AddChapter(chapter_header, chapter_body);
	end
end
