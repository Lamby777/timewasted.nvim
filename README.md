# timewasted.nvim

Recreating the "Time Wasted Debugging:" stopwatch from x64dbg as a Neovim plugin

![](https://i.ibb.co/vks1GSP/image.png)

![](https://pbs.twimg.com/media/C06oAZNXcAArLPA.jpg)

---

## How to use

First, install it with your favorite plugin manager. Then, go to your statusline
configs or whatever you want to add this to, and make it evaluate the following:

```lua
-- default formatted time (1d 2h 3m 4s)
require("timewasted").dhms_fmt()

-- evaluates a function to format the result (customizable)
require("timewasted").get_fmt()

-- just give me the number of seconds, goddammit!
-- useful if you want to just get the value and do your own stuff after
require("timewasted").get_time()
```

---

## CONFIG OPTIONS

These are the defaults, with explanations.

```lua
{
    -- seconds between automatic writes to disk
    -- set to 0 or below to disable autosave...
    -- (not recommended, won't save any time spent before crashes)
    autosave_delay = 30,

    -- Don't mess with this if you aren't using get_fmt()
    -- Just overrides the formatter function. You can use
    -- dhms_fmt() or dhms() or other stuff like that inside
    -- it, and do your own custom format. By default, it
    -- adds a humorous little x64dbg reference before the date.
    time_formatter = function(total_sec)
        local time_str = require("timewasted").dhms_fmt(total_sec)
        return string.format("Time Wasted Configuring: %s", time_str)
    end
}
```
