--- @alias LibIconPicker_CallbackFn fun(sel:LibIconPicker_Selection) | "function(sel) end"

--- @class LibIconPicker_Selection
--- @field textInputValue string|nil The final text input value, if enabled
--- @field iconID number The ID of the selected entity (spell or item)

--- @class LibIconPicker_TextInputOptions
--- @field value string|nil
--- @field label string|nil

--- @class LibIconPicker_Options
--- @field icon IconIDOrPath|nil Set the selected icon/texture. nil defaults to the question-mark icon (ID=134400)
--- @field showTextInput boolean|nil Defaults to false
--- @field textInput LibIconPicker_TextInputOptions|nil Text Input Options (only if showTextInput)
--- @field anchor LibIconPicker_Anchor

--[[-----------------------------------------------------------------------------
AnchorPoint
-------------------------------------------------------------------------------]]
--- @alias LibIconPicker_AnchorPoint string | "'TOPLEFT'" | "'TOPRIGHT'" | "'BOTTOMLEFT'" | "'BOTTOMRIGHT'" | "'TOP'" | "'BOTTOM'" | "'LEFT'" | "'RIGHT'" | "'CENTER'"

--[[-----------------------------------------------------------------------------
Anchor
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_Anchor
--- @field point LibIconPicker_AnchorPoint
--- @field relativePoint LibIconPicker_AnchorPoint
--- @field relativeTo any
--- @field x number
--- @field y number

--[[-----------------------------------------------------------------------------
CallbackInfo
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_CallbackInfo
--- @field callback LibIconPicker_CallbackFn
--- @field opt LibIconPicker_Options

--- ### Open the LibIconPicker Dialog
--- **Defaults**:
--- - opt.type = "both"
--- - opt.showTextInput = false
--- - opt.textInput.value = ""
--- - opt.textInput.label = "Choose Icon:" (localized)
--- @param opt LibIconPicker_Options
--- @param fn LibIconPicker_CallbackFn
function Open(opt, fn)  end

-- Usecase #1: Show icon picker with textInput
Open(function(sel)
    print('xx selected icon:', sel.iconID)
end, { showTextInput = true })

-- Usecase #2: Show icon picker with textInput and anchor
local opt = {
    showTextInput = true,
    textInput = { value = 'MyName', label = 'Name:' },
    anchor = { point='TOPLEFT', relativeTo=MacroFrame, relativePoint='TOPRIGHT', x=0, y=5 }
}
Open(function(sel)
    print('xx selected icon:', sel.iconID, ' user-input-text:', sel.textInputValue)
end, opt)
