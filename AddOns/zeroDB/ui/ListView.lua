
zeroDB = zeroDB or {}
zeroDB.ListView = {}

function zeroDB.ListView:new(options)
    local o = options
    setmetatable(o, self)
    self.__index = self

    o.active_views = {}
    return o
end

function zeroDB.ListView:clear()
    for i, view in pairs(self.active_views) do
        view:Hide()
        view:SetParent(nil)
    end

    self.active_views = {}
end

function zeroDB.ListView:build(results, num_results)
    self:clear()

    local x = self.x
    local y = self.y

    local num_viewed_results = num_results

    if num_viewed_results > self.max_results then
        num_viewed_results = self.max_results - 1
    end

    local views, num_views = zeroDB.list_map(results, num_viewed_results, self.present_result)

    for i = 1, num_views do
        views[i]:SetParent(self.container)
        views[i]:SetPoint("TOPLEFT", x, y)
        views[i]:Show()

        y = y - self.result_height - self.spacing
    end

    if self.no_results_frame then
        if num_views > 0 then
            self.no_results_frame:Hide()
        else
            self.no_results_frame:Show()
        end
    end

    self.active_views = views
    return num_viewed_results, y
end
