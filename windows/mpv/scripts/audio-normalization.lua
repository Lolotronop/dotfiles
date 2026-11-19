local mp = require('mp')
local utils = require('mp.utils')

-- Observe the actual filter so the button also follows keyboard toggles.
local function update_button()
    local active = false
    for _, filter in ipairs(mp.get_property_native('af', {})) do
        if filter.label == 'normalize' then
            active = filter.enabled ~= false
            break
        end
    end

    mp.commandv('script-message-to', 'uosc', 'set-button', 'audio-normalization',
        utils.format_json({
            icon = 'graphic_eq',
            tooltip = 'Audio normalization',
            active = active,
            command = {'af', 'toggle', '@normalize'},
        }))
end

mp.observe_property('af', 'native', update_button)
-- Republish if uosc starts after this script.
mp.register_script_message('uosc-version', update_button)
mp.add_timeout(0, update_button)
