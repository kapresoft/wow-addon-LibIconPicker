# LibIconPicker:: Fast Icons, Happy Addons

![Log](doc/media/LibIconPicker-Logo-1-Dark-100px.png)

LibIconPicker is a high-performance icon selection library for World of Warcraft addons. It provides a clean, callback-based API that lets addons open an icon picker and receive the selected icon instantly — without managing UI state, layouts, or large icon lists themselves.

Designed from the ground up to be lightweight and efficient, LibIconPicker uses a hybrid scroll frame and lazy rendering so only visible icons are processed at any time. This keeps CPU usage low during scrolling and filtering, even with very large icon sets, and avoids unnecessary redraws or background work.

The UI is lazy-loaded and initialized only when needed, ensuring minimal memory usage and zero impact on addon startup time. No persistent data or saved variables are created by the library, keeping memory footprints small and predictable.

LibIconPicker is safe to embed or use standalone, supports multiple addons simultaneously, and avoids global side effects by following established WoW library conventions. The result is a fast, scalable, and memory-efficient icon picker that integrates cleanly into any addon without adding performance overhead or maintenance burden.

## Public Interface

See [LibIconPickerPublicInterface.lua](LibIconPicker/Core/Lib/Developer/Interface/LibIconPickerPublicInterface.lua) for the full EmmyLua function definitions and type annotations.  
You can import this file into your project to enable code completion and type hints.

## LibIconPicker_Options

The `options` table controls initial state, optional UI elements, and anchoring behavior.
All fields are optional unless otherwise noted. 

Here is an example of a fully populated LibIconPicker options table:

- [LibIconPicker_TextInputOptions](https://github.com/kapresoft/wow-addon-LibIconPicker/blob/main/LibIconPicker/Core/Lib/Developer/Interface/LibIconPickerPublicInterface.lua#L7-L9)
- [LibIconPicker_Anchor](https://github.com/kapresoft/wow-addon-LibIconPicker/blob/main/LibIconPicker/Core/Lib/Developer/Interface/LibIconPickerPublicInterface.lua#L22-L30)

```lua
--- @type LibIconPicker_Options
local opt = {
    icon = 132089,
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

### `icon`

**Type:** `number`
**Default:** `nil`

Initial icon ID to preselect when the picker opens.
This may be a **SpellID or ItemID**, depending on the active source. If omitted, no icon is preselected.

```lua
icon = 132089
```

### `showTextInput`

**Type:** `boolean`
**Default:** `false`

Controls visibility of the optional text input field.
This is typically used when the icon is associated with a user-defined label, name, or identifier.

```lua
showTextInput = true
```

### `textInput`

**Type:** `table`
**Default:** `nil`

Configuration for the optional text input field.
Only used when `showTextInput` is `true`.

```lua
textInput = {
    label = "Enter Name:",
    value = "Uber Spell"
}
```

#### `textInput.label`

**Type:** `string`
Label text displayed next to or above the input field.

#### `textInput.value`

**Type:** `string`
Initial value populated in the input field.
The final value entered by the user is returned via `selection.value` in the callback.

### `anchor`

**Type:** `table`
**Default:** Library-defined fallback anchor

Defines how the picker frame is positioned on screen.
If omitted, the picker uses its default positioning logic.

```lua
anchor = {
    point = "TOPRIGHT",
    relativeTo = UIParent,
    relativePoint = "TOPRIGHT",
    x = -50,
    y = -100
}
```

#### `anchor.point`

**Type:** `FramePoint`
Anchor point on the picker frame.

#### `anchor.relativeTo`

**Type:** `Frame`
Frame used as the anchor reference.

#### `anchor.relativePoint`

**Type:** `FramePoint`
Anchor point on the reference frame.

#### `anchor.x`, `anchor.y`

**Type:** `number`
Pixel offsets applied after anchoring.

Notes:

* Unsupported or missing fields are safely ignored.
* The options table is **read-only after `Open()`**; subsequent changes have no effect.
* Anchoring is resolved once per `Open()` call.
* The library does not retain option state between invocations.

## Callback: LibIconPicker_CallbackFn

The callback is invoked when the user confirms an icon selection.
It is called exactly once per Open() invocation.

- [LibIconPicker_Selection](https://github.com/kapresoft/wow-addon-LibIconPicker/blob/main/LibIconPicker/Core/Lib/Developer/Interface/LibIconPickerPublicInterface.lua#L3-L5)


```lua
--- @param sel LibIconPicker_Selection
function callbackFn(sel)
    -- sel.icon           : The user selected icon
    -- sel.textInputValue : The user text input value
end
```

### `sel.icon`

**Type:** `number`
The selected icon ID (SpellID or ItemID, depending on the active source).

### `sel.textInputValue`

**Type:** `string | nil`
The final value of the text input field.
`nil` if text input was not enabled.

## Use Cases

### Use Case #1: Simple Icon Selection

Displays the icon picker and returns the user’s selection via the callback.

```lua
--- @param sel LibIconPicker_Selection
LibIconPicker:Open(function(sel)
    print('Selected icon:', sel.icon, ' user-input-text:', sel.textInputValue)
end)
```

Notes:
* Uses default picker configuration.
* No text input field is shown unless explicitly enabled.
* The callback is invoked once the user confirms a selection.

### Usecase #2: Simple Case for Showing Icon Picker

There may be cases where you want to preselect an icon—for example, when reopening the picker with a previously chosen icon. This icon may have been saved from a prior session or persisted by the addon.

```lua
--- @param sel LibIconPicker_Selection
LibIconPicker:Open(function(sel)
    print('Selected icon:', sel.icon, ' user-input-text:', sel.textInputValue)
end, { icon = 132089 })
```

### Use Case #3: Icon Picker with Text Input

Enables an optional text input field alongside icon selection.
This is useful when the icon represents a user-defined name, label, or identifier.

#### Default Text Input

Displays the picker with the text input enabled using default label and empty value.

```lua
--- @param sel LibIconPicker_Selection
LibIconPicker:Open(function(sel)
    print('Selected icon:', sel.icon, ' user-input-text:', sel.textInputValue)
end, { showTextInput = true })
```
#### Customized Label and Initial Value

Configures the text input field with a custom label and prefilled value, typically when editing an existing name.

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

Notes:

* `textInput` is ignored unless `showTextInput` is `true`.
* The final text value is returned via `sel.textInputValue`.
* Text input state is not persisted by the library.

### Use Case #4: Icon Picker with Text Input and Custom Anchor

Displays the icon picker with the text input field enabled and positioned using a custom anchor definition.
This is useful when integrating the picker into an existing configuration UI or aligning it relative to a specific frame.

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

Notes:

* Anchoring is resolved once when the picker is opened.
* The picker does not track subsequent movement of the reference frame.
* If no anchor is provided, the library uses its default positioning behavior.

### Other Uses 

#### Close the Icon Picker

Programmatically closes the icon picker dialog if it is currently open.

```lua
LibIconPicker:Close()
```

Notes:

* Safe to call even if the picker is not open.
* Closing the picker does not invoke the selection callback.
* Any pending picker state is discarded.

#### Run from Console

Prints diagnostic information about the library to the chat frame.
Intended for quick inspection and debugging.

```console
/run LibIconPicker:Info()
```

