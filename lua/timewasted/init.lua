local M = {}

-- File path to store the session time
local session_time_file = vim.fn.stdpath("data") .. "/timewasted"
local TIME_FMT = "Time Wasted Configuring: %01dd %01dh %01dm %01ds"
local AUTOSAVE_DELAY = 60
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
	return M.read_log() + (os.time() - start_time)
end

-- write the logged time and reset the start time
function M.write_log()
	local current_time = os.time()
	local elapsed_seconds = current_time - start_time
	local new_total = M.read_log() + elapsed_seconds

	local f = io.open(session_time_file, "w")
	if f then
		f:write(tostring(new_total))
		f:close()
		start_time = current_time
	else
		error("Unable to write time to file: " .. session_time_file)
	end
end

-- read the logged time
function M.read_log()
	local f = io.open(session_time_file, "r")
	if f then
		local logged = tonumber(f:read("*a")) or 0
		f:close()
		return logged
	else
		return 0
	end
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
