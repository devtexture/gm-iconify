local icons = {}
icons.cache = icons.cache or {}
icons.api_url = 'https://api.iconify.design'

local function toHex( color )
    return ('#%02X%02X%02X'):format(color.r, color.g, color.b)
end

function icons:get(prefix, icon)
    local _icon = prefix .. ':' .. icon
    if self.cache[_icon] then return self.cache[_icon] end

    local obj = {
        x = 0, y = 0,
        w = 32, h = 32,

        prefix = prefix,
        icon = icon,
        color = color_white,

        exists = false,
        svg = '',

        setsize = function(this, w, h)
            this.w, this.h = w, h 
            return this
        end,

        setpos = function(this, x, y)
            this.x, this.y = x, y
            return this
        end,

        getsize = function(this) return this.w, this.h end,
        getpos = function(this) return this.x, this.y end,

        valid = function(this)
            return this.exists and this.svg ~= ''
        end,

        search = function(this)
            if this.exists then return isstring(this.svg) and this.svg or true end
            if this.proccessing then return end

            this.retry = 1
            this.proccessing = true 
            http.Fetch((self.api_url .. '/search?query=%s&prefix=%s&limit=32&pretty=1'):format(this.icon, this.prefix), function(body, _, _, code)
                this.proccessing = false 
                if code ~= 200 then
                    if this.retry < 3 then
                        this:search()
                        this.retry = this.retry + 1
                    end
                    return 
                end

                local data = util.JSONToTable(body)
                if (data and data['icons']) then
                    if data['total'] < 1 then
                        this.exists = false 
                        return 
                    end
                    this.exists = true 
                    this.svg = data['icons'][1]
                end
            end)

            return this
        end,

        get_svg = function(this)
            if not this:valid() then return end
            if this.getting then return end

            this.getting = true 

            local w, h = this:getsize()
            local hex = toHex(this.color)
            hex = hex:Replace('#', '%23')
            this.svg = self.api_url .. '/' .. this.prefix .. '/' .. this.icon .. '.svg?width=' .. w .. '&height=' .. h .. '&color=' .. hex

            http.Fetch(this.svg, function(body, _, _, code)
                this.getting = false 

                if code ~= 200 then return end
                if not body:StartsWith('<svg') then return end

                this.svg = {
                    obj = svg.Generate(_icon, w, h, [[]] .. body .. [[]]),
                    w = w, h = h
                }
            end)

        end,

        draw = function(this)
            if not this:valid() then return end

            if not this.svg.obj then
                this:get_svg()
                return 
            end

            local w, h = this:getsize()
            if this.svg.w ~= w or this.svg.h ~= h then
                this:get_svg()
                return 
            end

            return this.svg.obj(this.x, this.y)
        end
    }

    obj:search()

    self.cache[_icon] = obj
    return self.cache[_icon]
end

return icons