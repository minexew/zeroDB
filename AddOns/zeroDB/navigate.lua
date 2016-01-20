zeroDB = zeroDB or {}
zeroDB.navigate = {}
zeroDB.navigate.history = nil

function zeroDB.navigate.back()
    zeroDB.navigate.history.view.hide()
    zeroDB.navigate.history = zeroDB.navigate.history.previous
    zeroDB.navigate.show_view(zeroDB.navigate.history)
end

function zeroDB.navigate.to(nav)
    if zeroDB.navigate.history then
        zeroDB.navigate.history.view.hide()
    end

    zeroDB.navigate.push_history(nav)
    zeroDB.navigate.show_view(nav)
end

function zeroDB.navigate.show_view(nav)
    nav.view.show(nav)
end

function zeroDB.navigate.push_history(nav)
    nav.previous = zeroDB.navigate.history
    zeroDB.navigate.history = nav
end
