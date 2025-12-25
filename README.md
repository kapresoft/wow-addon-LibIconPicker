# LibIconPicker:: Fast Icons, Happy Addons

![Log](doc/media/LibIconPicker-Logo-1-Dark-100px.png)

LibIconPicker is a high-performance icon selection library for World of Warcraft addons. It provides a clean, callback-based API that lets addons open an icon picker and receive the selected icon instantly — without managing UI state, layouts, or large icon lists themselves.

Designed from the ground up to be lightweight and efficient, LibIconPicker uses a hybrid scroll frame and lazy rendering so only visible icons are processed at any time. This keeps CPU usage low during scrolling and filtering, even with very large icon sets, and avoids unnecessary redraws or background work.

The UI is lazy-loaded and initialized only when needed, ensuring minimal memory usage and zero impact on addon startup time. No persistent data or saved variables are created by the library, keeping memory footprints small and predictable.

LibIconPicker is safe to embed or use standalone, supports multiple addons simultaneously, and avoids global side effects by following established WoW library conventions. The result is a fast, scalable, and memory-efficient icon picker that integrates cleanly into any addon without adding performance overhead or maintenance burden.

## Public Interface
See [LibIconPickerPublicInterface.lua](LibIconPicker/Core/Lib/Developer/Interface/LibIconPickerPublicInterface.lua) for more details.

### LibIconPicker_Options

- [LibIconPicker_TextInputOptions](https://github.com/kapresoft/wow-addon-LibIconPicker/blob/main/LibIconPicker/Core/Lib/Developer/Interface/LibIconPickerPublicInterface.lua#L7-L9)
- [LibIconPicker_Anchor](https://github.com/kapresoft/wow-addon-LibIconPicker/blob/main/LibIconPicker/Core/Lib/Developer/Interface/LibIconPickerPublicInterface.lua#L22-L30)

```lua
--- @type LibIconPicker_Options
local opt = {
    showTextInput = true,
    -- @type LibIconPicker_TextInputOptions
    textInput = { label = 'Enter Name:', value = 'Uber Spell' },
    -- @type LibIconPicker_Anchor
    anchor = {
        point = 'TOPRIGHT',
        relativeTo = UIParent,
        relativePoint = 'TOPRIGHT',
        x = -50,
        y = -100
    },
}
```

### Callback: LibIconPicker_CallbackFn

- [LibIconPicker_Selection](https://github.com/kapresoft/wow-addon-LibIconPicker/blob/main/LibIconPicker/Core/Lib/Developer/Interface/LibIconPickerPublicInterface.lua#L3-L5)


```lua
--- @param sel LibIconPicker_Selection
function callbackFn(sel)
    -- sel.icon           : The user selected icon
    -- sel.textInputValue : The user text input value
end
```

## Usecases

### Usecase #1: Show Icon Picker
> Displays a dialog for the user to pick and icon

```lua
--- @param sel LibIconPicker_Selection
LibIconPicker:Open(function(sel)
    print('Selected icon:', sel.icon, ' user-input-text:', sel.textInputValue)
end)
```

### Usecase #2: Show Icon Picker with TextInput

> Minimal Call

```lua
--- @param sel LibIconPicker_Selection
LibIconPicker:Open(function(sel)
    print('Selected icon:', sel.icon, ' user-input-text:', sel.textInputValue)
end, { showTextInput = true })
```
> Customized Label and Value

```lua
--- @type LibIconPicker_Options
local opt = { 
    showTextInput = true,
    textInput = { label = 'Enter Name:', value = 'Uber Spell' } 
}
--- @param sel LibIconPicker_Selection
LibIconPicker:Open(function(sel)
    print('Selected icon:', sel.icon, ' user-input-text:', sel.textInputValue)
end, opt)
```

### Usecase #3: Show icon picker with textInput and anchor

```lua
--- @type LibIconPicker_Options
local opt = {
    showTextInput = true,
    anchor = {
        point = 'TOPRIGHT',
        relativeTo = UIParent,
        relativePoint = 'TOPRIGHT',
        x = -50,
        y = -100
    },
}
--- @param sel LibIconPicker_Selection
LibIconPicker:Open(function(sel)
    print('Selected icon:', sel.icon, ' user-input-text:', sel.textInputValue)
end, opt)
```

### Usecase #4: Close the Icon Picker
> Closes the Icon Picker Dialog

```lua
LibIconPicker:Close()
```
