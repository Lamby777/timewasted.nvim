local M = {}

-- File path to store the session time
local session_time_file = vim.fn.stdpath("data") .. "/timewasted"
local TIME_FMT = "%01dd %01dh %01dm %01ds"
local AUTOSAVE_DELAY = 60

-- last time file was saved or vim was opened
M.last_touch = os.time()

M.fmt_time = function(total_sec)
	local days = math.floor(total_sec / 86400)
	local hours = math.floor((total_sec % 86400) / 3600)
	local minutes = math.floor((total_sec % 3600) / 60)
	local seconds = total_sec % 60

	return string.format(TIME_FMT, days, hours, minutes, seconds)
end

function M.save_session_time()
	local current_time = os.time()
	local elapsed_seconds = current_time - M.last_touch

	local f = io.open(session_time_file, "w")
	if f then
		f:write(tostring(elapsed_seconds))
		f:close()
	end
end

function M.load_session_time()
	local f = io.open(session_time_file, "r")
	if f then
		local elapsed_seconds = tonumber(f:read("*a")) or 0
		f:close()
		M.last_touch = os.time() - elapsed_seconds
	end
end

-- create open/close autocmds
vim.api.nvim_create_autocmd("VimEnter", "*", [[lua require("timewasted").load_session_time()]])
vim.api.nvim_create_autocmd("VimLeave", "*", [[lua require("timewasted").save_session_time()]])

return M
