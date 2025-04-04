return {
	-- Better looking notifications
	"rcarriga/nvim-notify",
	config = function()
		local notify = require("notify")

		notify.setup({
			max_width = 50,
			merge_duplicates = true,
		})

		vim.notify = notify
	end,
}
