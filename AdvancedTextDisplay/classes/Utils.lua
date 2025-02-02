-- auxilary function for ternary operator (cond ? T : F)
function _G.ternary ( cond , T , F )
  if cond then return T else return F end
end

-- auxilary function to return default value when input is Nil
function _G.defaultNil ( val , def )
  return ternary(val == nil, def, val)
end

-- auxilary function to return default value when input is Infinity
function _G.defaultInf ( val, def )
  return ternary(tostring(val) == "inf", def, val)
end

-- auxilary function to set return default value if input is Nan
function _G.defaultNan ( val , def )
  return ternary(val ~= val, def, val)
end