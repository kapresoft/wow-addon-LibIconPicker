--- @alias IconTypeFilter string | "'spell'" | "'item'" | "'both'"
--- @alias LibIconChooserCallbackFn fun(sel:LibIconChooserSelection) | "function(sel) end"

--- @class LibIconChooserSelection
--- @field textInputValue string|nil The final text input value, if enabled
--- @field iconID number The ID of the selected entity (spell or item)

--- @class TextInputOptions
--- @field value string|nil
--- @field label string|nil

--- @class LibIconPickerOptions
--- @field type IconTypeFilter
--- @field showTextInput boolean|nil Defaults to false
--- @field textInput TextInputOptions|nil Text Input Options (only if showTextInput)

--- ### Open the LibIconPicker Dialog
--- **Defaults**:
--- - opt.type = "both"
--- - opt.showTextInput = false
--- - opt.textInput.value = ""
--- - opt.textInput.label = "Choose Icon:" (localized)
--- @param opt LibIconPickerOptions
--- @param fn LibIconChooserCallbackFn
function Open(opt, fn)  end

-- Usecase #1: Show icon picker without textInput
Open({ type = 'both' }, function(sel)
    print('xx selected icon:', sel.iconID)
end)

-- Usecase #2: Show icon picker with textInput
Open({
        type = 'both',
        showTextInput = true,
        textInput = { value = 'MyName', label='Name:' },
     }, function(sel)
    print('xx selected icon:', sel.iconID, ' user-input-text:', sel.textInputValue)
end)
