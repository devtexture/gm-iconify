# gm-iconfiy

A lightweight script for render icon using [Iconify API](https://iconify.design/).

[glua-SVG](https://github.com/noaccessl/glua-SVG) - needed to draw SVG.
## Usage/Examples

```lua
local icons = include('icons.lua')

hook.Add('HUDPaint', 'icons.example', function()
    local icon_size = 128
    local icon = icons:get('emojione', 'cat')
    :setsize(icon_size, icon_size)
    :setpos( ScrW() / 2 - icon_size / 2, ScrH() / 2 - icon_size / 2 )
    :draw()
end)
```
![Result](https://raw.githubusercontent.com/devtexture/gm-iconify/refs/heads/main/result.png)


