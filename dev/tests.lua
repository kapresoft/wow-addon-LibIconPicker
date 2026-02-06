local x = {
  
  --- Load the addon
  --- /dump LibIconPicker
  function()
    --- Run this one-liner to load the library
    --- /run
    (function() local loaded, msg = C_AddOns.LoadAddOn('LibIconPicker'); local x={ loaded=loaded, msg=msg }; DevTools_Dump(x, 'loaded') end)()
  end,
  
  --- One liners
  function()
    -- /run
    (function() LibIconPicker:Open(function(sel) print('sel:', sel.icon) end) end)()
    -- with text
    -- /run
    (function() LibIconPicker:Open(function(sel) print(('text=%s icon=%s'):format(sel.textInputValue, sel.icon)) end, { showTextInput = true }) end)()
  end,
  
  --- Open
function()
  --- @type LibIconPicker_Options
  local opt = {
    icon=132111, showTextInput = true,
    textInput = { label = 'Name:', value = 'My name'}
  }
  LibIconPicker:Open(function(sel)
    print('selected:', pf(sel))
  end, opt)
end,
  
  function()
    if LibIconPicker then return LibIconPicker end
    
    local LoadAddOn   = C_AddOns.LoadAddOn or LoadAddOn
    local EnableAddOn = C_AddOns.EnableAddOn or EnableAddOn
    local libName     = 'LibIconPicker'
    local c           = UnitName('player')
    EnableAddOn(libName, UnitName('player'))
    local status, msg = LoadAddOn(libName)
    if not status then
      print(('LoadAddOn(%q) failed with status=%s; msg=%s'):format(libName, status, msg))
      return nil
    end
    local lip = LibIconPicker
    lip:Open(function(sel)
      print('selected:', sel.icon)
    end)
  end,
  
  function()
    local function getLIP()
      if LibIconPicker then return LibIconPicker end
      
      local LoadAddOn   = C_AddOns.LoadAddOn or LoadAddOn
      local EnableAddOn = C_AddOns.EnableAddOn or EnableAddOn
      local libName     = 'LibIconPicker'
      local c           = UnitName('player')
      EnableAddOn(libName, UnitName('player'))
      local status, msg = LoadAddOn(libName)
      if not status then
        print(('LoadAddOn(%q) failed with status=%s; msg=%s'):format(libName, status, msg))
        return nil
      end
      return LibIconPicker
    end
    local lip = getLIP()
    if not lip then return end
    
    --- @type LibIconPicker_Options
    local opt = {
      icon      = 132111, showTextInput = true,
      textInput = { label = 'Name:', value = 'My name' }
    }
    lip:Open(function(sel)
      print('selected:', pf(sel))
    end, opt)
  end
  
}
