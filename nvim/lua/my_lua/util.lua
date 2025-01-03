local util = {}

function util.remove_duplicates(array)
  local seen = {}
  local result = {}

  for _, value in ipairs(array) do
    if not seen[value] then
      table.insert(result, value)
      seen[value] = true
    end
  end

  return result
end

local function assert_arg_iterable(idx,val)
  if not types.is_iterable(val) then
    complain(idx,"iterable")
  end
end

function util.merge (t1,t2,dup)
    assert_arg_iterable(1,t1)
    assert_arg_iterable(2,t2)
    local res = {}
    for k,v in pairs(t1) do
        if dup or t2[k] then res[k] = v end
    end
    if dup then
      for k,v in pairs(t2) do
        res[k] = v
      end
    end
    return setmeta(res,t1,'Map')
end

return util
