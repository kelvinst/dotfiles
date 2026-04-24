local max_length = 30
local logo_color = 0xff1db954

local spotify_anchor = SBAR.add("item", "spotify", {
	position = "right",
	icon = {
		font = { size = DEFAULT_ITEM.icon.font.size * 1.2 },
		string = "",
		color = logo_color,
	},
	label = {
		string = "Spotify",
		drawing = true,
		y_offset = 0,
	},
})

local function update_spotify()
	SBAR.exec(
		[[osascript -e 'if application "Spotify" is running then tell application "Spotify" if player state is playing then set t to name of current track set a to artist of current track return t & " - " & a else return "paused" end tell else return "stopped" end']],
		function(result)
			local status = result:gsub("\n", "")

			if status == "stopped" or status == "" then
				spotify_anchor:set({ drawing = false })
			elseif status == "paused" then
				spotify_anchor:set({
					drawing = true,
					label = { string = "Paused", color = COLORS.disabled_color },
					icon = { color = COLORS.disabled_color },
				})
			else
				if string.len(status) > max_length then
					status = string.sub(status, 1, max_length) .. "..."
				end

				spotify_anchor:set({
					drawing = true,
					label = { string = status, color = COLORS.accent_color },
					icon = { color = logo_color },
				})
			end
		end
	)
end

SBAR.add("event", "spotify_change", "com.spotify.client.PlaybackStateChanged")
spotify_anchor:subscribe("spotify_change", update_spotify)

spotify_anchor:subscribe("mouse.clicked", function(env)
	local script = ""

	if env.BUTTON == "left" then
		script = 'tell application "Spotify" to playpause'
	elseif env.BUTTON == "right" then
		script = 'tell application "Spotify" to next track'
	end

	if script ~= "" then
		SBAR.exec("osascript -e '" .. script .. "'")
	end
end)

update_spotify()
