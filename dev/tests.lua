x = {
  function()
    local LoadAddOn   = C_AddOns.LoadAddOn
    local status, msg = LoadAddOn('LibIconPicker')
    return { loaded = status, msg = msg }
  end,
  function()
    local LoadAddOn   = C_AddOns.LoadAddOn
    local status, msg = LoadAddOn('LibIconPicker')
    if not status then return { loaded = status, msg = msg } end

    LibIconPicker:Open(function(sel)
      print('Selected icon:', sel.icon)
    end, { icon = 132089 })

    return status
  end,
}
