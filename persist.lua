package.preload["flat"] = package.preload["flat"] or function(...)
  local mp = require("MessagePack")
  
  local function isFile(path)
  	local f = io.open(path, "r")
  	if f then
  		f:close()
  		return true
  	end
  	return false
  end
  
  local function isDir(path)
  	path = string.gsub(path.."/", "//", "/")
  	local ok, err, code = os.rename(path, path)
  	if ok or code == 13 then
  		return true
  	end
  	return false
  end
  
  local function load_page(path)
  	local ret
  	local f = io.open(path, "rb")
  	if f then
  		ret = mp.unpack(f:read("*a"))
  		f:close()
  	end
  	return ret
  end
  
  local function store_page(path, page)
  	if type(page) == "table" then
  		local f = io.open(path, "wb")
  		if f then
  			f:write(mp.pack(page))
  			f:close()
  			return true
  		end
  	end
  	return false
  end
  
  local pool = {}
  
  local db_funcs = {
  	save = function(db, p)
  		if p then
  			if type(p) == "string" and type(db[p]) == "table" then
  				return store_page(pool[db].."/"..p, db[p])
  			else
  				return false
  			end
  		end
  		for p, page in pairs(db) do
  			if not store_page(pool[db].."/"..p, page) then
  				return false
  			end
  		end
  		return true
  	end
  }
  
  local mt = {
  	__index = function(db, k)
  		if db_funcs[k] then return db_funcs[k] end
  		if isFile(pool[db].."/"..k) then
  			db[k] = load_page(pool[db].."/"..k)
  		end
  		return rawget(db, k)
  	end
  }
  
  pool.hack = db_funcs
  
  return setmetatable(pool, {
  	__mode = "kv",
  	__call = function(pool, path)
  		assert(isDir(path), path.." is not a directory.")
  		if pool[path] then return pool[path] end
  		local db = {}
  		setmetatable(db, mt)
  		pool[path] = db
  		pool[db] = path
  		return db
  	end
  })
end
local function _1_(db_path)
  assert((nil ~= db_path), string.format("Missing argument %s on %s:%s", "db_path", "persist.fnl", 1))
  local db = require("flat")(db_path)
  local function _2_(category)
    assert((nil ~= category), string.format("Missing argument %s on %s:%s", "category", "persist.fnl", 18))
    local category_map = db[category]
    local sorting_done
    local function _3_(a, b)
      return (a.hot > b.hot)
    end
    sorting_done = table.sort(category_map, _3_)
    local _4_
    do
      local tbl_12_auto = {}
      for i, e in ipairs(category_map) do
        tbl_12_auto[(#tbl_12_auto + 1)] = string.format("%s:%s", i, e.value)
      end
      _4_ = tbl_12_auto
    end
    return table.concat(_4_, "\n")
  end
  local function _5_(category, key)
    assert((nil ~= key), string.format("Missing argument %s on %s:%s", "key", "persist.fnl", 10))
    assert((nil ~= category), string.format("Missing argument %s on %s:%s", "category", "persist.fnl", 10))
    local value = db[category][key].value
    db[category][key]["hot"] = os.time()
    db:save()
    return value
  end
  local function _6_(category, key, value)
    assert((nil ~= value), string.format("Missing argument %s on %s:%s", "value", "persist.fnl", 5))
    assert((nil ~= key), string.format("Missing argument %s on %s:%s", "key", "persist.fnl", 5))
    assert((nil ~= category), string.format("Missing argument %s on %s:%s", "category", "persist.fnl", 5))
    do end (db)[category][key] = {hot = os.time(), value = value}
    return db:save()
  end
  return {list = _2_, load = _5_, save = _6_}
end
return _1_
