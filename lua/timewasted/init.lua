local M = {}

-- File path to store the session time
local session_time_file = vim.fn.stdpath("data") .. "/timewasted"
local TIME_FMT = "Time Wasted Configuring: %01dd %01dh %01dm %01ds"
local AUTOSAVE_DELAY = 30

local start_time = os.time()

M.get_fmt = function()
	return M.fmt_time(M.get_time())
end

M.fmt_time = function(total_sec)
	local days = math.floor(total_sec / 86400)
	local hours = math.floor((total_sec % 86400) / 3600)
	local minutes = math.floor((total_sec % 3600) / 60)
	local seconds = total_sec % 60

	return string.format(TIME_FMT, days, hours, minutes, seconds)
end

function M.get_time()
	-- we don't care if the time is written by another
	-- process... it might even be more accurate (I think)
	return M.read_log().time + (os.time() - start_time)
end

-- write the logged time and reset the start time
function M.write_log()
	local log = M.read_log()

	-- if the last write time is newer than the one we're
	-- keeping track of, chances are there's another nvim
	-- instance running... Oh, boy! Concurrency!
	if log.lastsave > start_time then
		-- yep, this part is probably gonna introduce some
		-- bugs, but in favor of keeping this commit brief,
		-- i'll fix that next.
		return
	end

	local current_time = os.time()
	local elapsed_seconds = current_time - start_time
	local new_total = log.time + elapsed_seconds

	local f = io.open(session_time_file, "w")
	if f then
		local newlog = string.format("%d,%d", new_total, current_time)
		f:write(newlog)
		f:close()

		start_time = current_time
	else
		error("Unable to write time to file: " .. session_time_file)
	end
end

-- read the logged time
function M.read_log()
	local f = io.open(session_time_file, "r")
	local res = { time = 0, lastsave = 0 }

	if f then
		local content = f:read("*all")
		f:close()

		local csv_iter = content:gmatch("[^,]+")
		res.time = tonumber(csv_iter())
		res.lastsave = tonumber(csv_iter())
	end

	return res
end

M.delete_log = function()
	-- Delete log file... prob will only get called manually
	os.remove(session_time_file)
end

-- write to file on end of session
vim.api.nvim_create_autocmd({ "VimLeave" }, { command = [[lua require("timewasted").write_log()]] })

-- enable autosave if not nil
if AUTOSAVE_DELAY ~= nil then
	local delay_ms = AUTOSAVE_DELAY * 1000

	local autosave_timer = vim.loop.new_timer()
	autosave_timer:start(delay_ms, delay_ms, vim.schedule_wrap(M.write_log))
end

return M
