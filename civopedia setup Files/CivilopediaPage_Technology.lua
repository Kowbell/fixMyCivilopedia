-- ===========================================================================
--	Civilopedia - Technology Page Layout
-- ===========================================================================

PageLayouts["Technology" ] = function(page)
	local sectionId = page.SectionId;
	local pageId = page.PageId;

	SetPageHeader(page.Title);
	SetPageSubHeader(page.Subtitle);

	local tech = GameInfo.Technologies[pageId];
	if(tech == nil) then
		return;
	end
	local techType = tech.TechnologyType;

	local required_techs = {};
	local leadsto = {};

	for row in GameInfo.TechnologyPrereqs() do
		if(row.Technology == techType) then
			local c = GameInfo.Technologies[row.PrereqTech];
			if(c) then
				table.insert(required_techs, {"ICON_" .. c.TechnologyType, c.Name, c.TechnologyType});
			end
		end

		if(row.PrereqTech == techType) then
			local c = GameInfo.Technologies[row.Technology];
			if(c) then
				table.insert(leadsto, {"ICON_" .. c.TechnologyType, c.Name, c.TechnologyType});
			end
		end
	end

	local boosts = {};
	for row in GameInfo.Boosts() do
		if(row.TechnologyType == techType) then
			table.insert(boosts, row);
		end
	end

	local unlockables = GetUnlockablesForTech(techType);

	local unlocks = {};
	for i,v in ipairs(unlockables) do
		table.insert(unlocks, {"ICON_" .. v[1], Locale.Lookup(v[2]), v[1]});
	end

	local function SortUnlockables(a,b)
		local ta = GameInfo.Types[a[3]];
		local tb = GameInfo.Types[b[3]];

		if(ta.Kind == tb.Kind) then
			-- sort by Name
			return Locale.Compare(a[2], b[2]) == -1;
		else
			-- Ideally we should sort by Kind's NAME but this field does not exist yet.
			return ta.Kind < tb.Kind;
		end
	end

	table.sort(unlocks, SortUnlockables);
		
	-- Right Column
	AddPortrait("ICON_" .. techType);

	-- Quotes!
	for row in GameInfo.TechnologyQuotes() do
		if(row.TechnologyType == techType) then
			AddQuote(row.Quote, row.QuoteAudio);
		end
	end

	AddRightColumnStatBox("LOC_UI_PEDIA_UNLOCKS", function(s)
		s:AddSeparator();
		local icons = {};
		for _, icon in ipairs(unlocks) do
			table.insert(icons, icon);	
				
			if(#icons == 4) then
				s:AddIconList(icons[1], icons[2], icons[3], icons[4]);
				icons = {};
			end
		end

		if(#icons > 0) then
			s:AddIconList(icons[1], icons[2], icons[3], icons[4]);
		end
		s:AddSeparator();
	end);

	AddRightColumnStatBox("LOC_UI_PEDIA_REQUIREMENTS", function(s)
		s:AddSeparator();

		if(tech.EraType) then
			local era = GameInfo.Eras[tech.EraType];
			if(era) then
				s:AddLabel(era.Name);
				s:AddSeparator();
			end
		end

		if(#required_techs > 0) then
			s:AddHeader("LOC_UI_PEDIA_REQUIRED_TECHNOLOGIES");
			local icons = {};
			for _, icon in ipairs(required_techs) do
				s:AddIconLabel(icon, icon[2]);
			end
			s:AddSeparator();
		end
				
		local yield = GameInfo.Yields["YIELD_SCIENCE"];
		if(yield) then
			s:AddHeader("LOC_UI_PEDIA_RESEARCH_COST");
			local t = Locale.Lookup("LOC_UI_PEDIA_BASE_COST", tonumber(tech.Cost), yield.IconString, yield.Name);
			s:AddLabel(t);
			s:AddSeparator();
		end


		if(#boosts > 0) then
			s:AddHeader("LOC_UI_PEDIA_BOOSTS");

			for i,b in ipairs(boosts) do
				s:AddLabel(b.TriggerDescription);
			end
			s:AddSeparator();
		end
	end);

	AddRightColumnStatBox("LOC_UI_PEDIA_PROGRESSION", function(s)
		s:AddSeparator();

		if(#leadsto > 0) then
			s:AddHeader("LOC_UI_PEDIA_LEADS_TO_TECHS");
			for _, tech in ipairs(leadsto) do
				s:AddIconLabel(tech, tech[2]);
			end
		end
		s:AddSeparator();
	end);

	-- Left Column
	AddChapter("LOC_UI_PEDIA_DESCRIPTION", tech.Description);

	local chapters = GetPageChapters(page.PageLayoutId);
	for i, chapter in ipairs(chapters) do
		local chapterId = chapter.ChapterId;
		local chapter_header = GetChapterHeader(sectionId, pageId, chapterId);
		local chapter_body = GetChapterBody(sectionId, pageId, chapterId);

		AddChapter(chapter_header, chapter_body);
	end
end
