hs.hotkey.bind({ 'ctrl, shift' }, 'return',
    function()                                    -- change your own hotkey combo here, available keys could be found here:https://www.hammerspoon.org/docs/hs.hotkey.html#bind
        local BUNDLE_ID = 'com.mitchellh.ghostty' -- more accurate to avoid mismatching on browser titles

        function getMainWindow(app)
            -- get main window from app
            local win = nil
            while win == nil do
                win = app:mainWindow()
            end
            return win
        end

        function moveWindow(ghostty, space, mainScreen)
            -- move to main space
            local win = getMainWindow(ghostty)
            if win:isFullScreen() then
                hs.eventtap.keyStroke('fn', 'f', 0, ghostty)
            end
            --   This moves Kitty to the top third of the screen, which I don't need right now.
            --   winFrame = win:frame()
            --   scrFrame = mainScreen:fullFrame()
            --   winFrame.w = scrFrame.w
            --   winFrame.y = scrFrame.y
            --   winFrame.x = scrFrame.x
            --   win:setFrame(winFrame, 0)
            hs.spaces.moveWindowToSpace(win, space)
            if win:isFullScreen() then
                hs.eventtap.keyStroke('fn', 'f', 0, ghostty)
            end
            win:focus()
        end

        local kitty = hs.application.get(BUNDLE_ID)
        if kitty ~= nil and kitty:isFrontmost() then
            kitty:hide()
        else
            local space = hs.spaces.activeSpaceOnScreen()
            local mainScreen = hs.screen.mainScreen()
            if kitty == nil and hs.application.launchOrFocusByBundleID(BUNDLE_ID) then
                local appWatcher = nil
                appWatcher = hs.application.watcher.new(function(name, event, app)
                    if event == hs.application.watcher.launched and app:bundleID() == BUNDLE_ID then
                        -- This moves Kitty to the top third of the screen, which I don't need right now.
                        -- getMainWindow(app):move(hs.geometry({x=0,y=0,w=1,h=0.4})) -- move kitty window on top, you could set the window percentage here
                        app:hide()
                        moveWindow(app, space, mainScreen)
                        appWatcher:stop()
                    end
                end)
                appWatcher:start()
            end
            if kitty ~= nil then
                moveWindow(kitty, space, mainScreen)
            end
        end
    end)
