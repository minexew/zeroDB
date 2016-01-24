
zeroDB = zeroDB or {}
zeroDB.TabView = {}

local tab_inactive = 'Interface\\AddOns\\zeroDB\\assets\\tab_inactive'
local tab_active = 'Interface\\AddOns\\zeroDB\\assets\\tab_active'

function zeroDB.TabView:new(options)
    local o = options
    setmetatable(o, self)
    self.__index = self
    self = o

    local sample_tab = options.tabs[1][1]
    local point, relativeTo, relativePoint, xOffset, yOffset = sample_tab:GetPoint(1)
    self.x = xOffset
    self.y = yOffset
    self.tab_width = sample_tab:GetWidth()
    self.active_tab = nil

    self.num_tabs = table.getn(self.tabs)

    for i = 1, self.num_tabs do
        self.tabs[i][2]:Hide()
        self.tabs[i][1]:SetNormalTexture(tab_inactive)

        if self.tabs[i].title then
            getglobal(self.tabs[i][1]:GetName()..'_Text'):SetText(self.tabs[i].title)
        end

        local index = i
        self.tabs[i][1]:SetScript("OnClick", function() self:activate_tab(index) end)
    end

    if self.num_tabs > 0 then
        self:activate_tab(1)
    end

    self:set_visibility(nil)
    return self
end

function zeroDB.TabView:activate_tab(index)
    if self.active_tab then
        self.tabs[self.active_tab][1]:SetNormalTexture(tab_inactive)
        self.tabs[self.active_tab][2]:Hide()
    end

    self.tabs[index][1]:SetNormalTexture(tab_active)
    self.tabs[index][2]:Show()
    self.active_tab = index
end

function zeroDB.TabView:set_visibility(visible)
    local x = self.x
    local y = self.y

    local num_visible_tabs = 0
    local last_visible_tab_index = nil

    for i = 1, self.num_tabs do
        if not visible or visible[i] then
            self.tabs[i][1]:SetPoint("TOPLEFT", x, y)
            self.tabs[i][1]:Show()

            x = x + self.tab_width
            num_visible_tabs = num_visible_tabs + 1
            last_visible_tab_index = i

            if not self.active_tab then
                self:activate_tab(i)
            end
        else
            if self.active_tab == i then
                self.tabs[i][1]:SetNormalTexture(tab_inactive)
                self.tabs[i][2]:Hide()
                self.active_tab = nil
            end

            self.tabs[i][1]:Hide()
        end
    end

    if not self.active_tab and last_visible_tab_index then
        self:activate_tab(last_visible_tab_index)
    end

    return num_visible_tabs
end
