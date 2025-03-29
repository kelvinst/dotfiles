return {
	-- Better looking notifications
	"rcarriga/nvim-notify",
	config = function()
		local notify = require("notify")

		notify.setup({
			stages = "fade",
			timeout = 5000,
			merge_duplicates = true,
		})

		vim.notify = notify
	end,
}
