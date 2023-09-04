local M = {}

M.start_time = os.time()

M.get_session_time = function()
	local current_time = os.time()
	local elapsed_seconds = current_time - M.start_time

	local hours = math.floor(elapsed_seconds / 3600)
	local minutes = math.floor((elapsed_seconds % 3600) / 60)
	local seconds = elapsed_seconds % 60

	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

return M
