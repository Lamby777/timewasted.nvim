local M = {}

-- File path to store the session time
local session_time_file = vim.fn.stdpath("data") .. "/timewasted"
local TIME_FMT = "%01dd %01dh %01dm %01ds"
local AUTOSAVE_DELAY = 60

M.start_time = os.time()

M.fmt_time = function(total_sec)
	local days = math.floor(total_sec / 86400)
	local hours = math.floor((total_sec % 86400) / 3600)
	local minutes = math.floor((total_sec % 3600) / 60)
	local seconds = total_sec % 60

	return string.format(TIME_FMT, days, hours, minutes, seconds)
end

-- write the logged time and reset the start time
function M.write_time()
	local current_time = os.time()
	local elapsed_seconds = current_time - M.start_time
	local new_total = M.read_time() + elapsed_seconds

	local f = io.open(session_time_file, "w")
	if f then
		f:write(tostring(new_total))
		f:close()
		M.start_time = current_time
	else
		error("Unable to write time to file: " .. session_time_file)
	end
end

-- read the logged time
function M.read_time()
	local f = io.open(session_time_file, "r")
	if f then
		local logged = tonumber(f:read("*a")) or 0
		f:close()
		return logged
	else
		return 0
	end
end

-- create open/close autocmds
vim.api.nvim_create_autocmd("VimEnter", "*", [[lua require("timewasted").load_time()]])
vim.api.nvim_create_autocmd("VimLeave", "*", [[lua require("timewasted").write_time()]])

return M
