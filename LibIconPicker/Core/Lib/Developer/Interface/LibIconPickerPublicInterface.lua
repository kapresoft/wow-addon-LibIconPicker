--- @alias IconSource string | "'spell'" | "'item'" | "'both'"
--- @alias IconSelectionType string | '"spell"' | '"item"'
--- @alias LibIconChooserCallbackFn fun(sel:LibIconChooserSelection) | "function(sel) end"

--- @class LibIconChooserSelection
--- @field type IconSelectionType
--- @field value string The user-updated text field value (if any)
--- @field id number The ID of the selected entity (spell or item)

--- Example Usage:
--- @param source IconSource
--- @param fn LibIconChooserCallbackFn
function Open(source, fn)  end

Open('both', function(sel)
    print('xx selected icon:', sel.id, 'type:', sel.type, ' user-input-text:', sel.value)
end)
