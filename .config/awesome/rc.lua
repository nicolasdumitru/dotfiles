-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/gruvbox.lua")

-- Use correct status icon size
awesome.set_preferred_icon_size(32)

-- Enable/disable window snapping
awful.mouse.snap.edge_enabled = true

-- Default utilities
Utility = {
	launcher = "dmenu_run",
	bookmark = "dmenubookmarkinsert",
	usb_mounter = "dmenumounter",
	usb_unmounter = "dmenuunmounter",
	characters = "dmenucharacters",
	screenshot = {
		full = "screenshot -n full",
		interactive = "dmenuscreenshot",
	},
	display = {
		dual = "displayctl -n dual",
		interactive = "dmenudisplayctl",
		temperature = "dmenudisplaytemperature",
	},

	shell = "zsh",
	terminal = "alacritty",
	terminal_here = "terminalhere",
	text_editor = os.getenv("nvim") or "nvim",
	browser = "chromium",
	mail = "thunderbird",
	feed_reader = "newsboat",
	file_manager = "fmcd",
	directory_fuzzy_finder = "ffcd",
	music_player = "ncmpcpp",
	system_monitor = "btop",
	password_manager = "keepassxc",
	torrent = "transmission-gtk",
}

function Terminal_open(name)
	return Utility.terminal ..
		" -e " .. Utility.shell .. " -i -c " .. "'" .. name .. " ; exec " .. Utility.shell .. " -i -s" .. "'"
end

Editor_cmd = Terminal_open(Utility.text_editor)

-- Default modkey.
Modkey = "Mod4"
Modkey2 = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.max,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
Myawesomemenu = {
	{ "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
	{ "manual",      Utility.terminal .. " -e man awesome" },
	{ "edit config", Editor_cmd .. " " .. awesome.conffile },
	{ "restart",     awesome.restart },
	{ "quit",        function() awesome.quit() end },
}

Mymainmenu = awful.menu({
	items = { { "awesome", Myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", Utility.terminal }
	}
})

Mylauncher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = Mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = Utility.terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
Mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
Mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t) t:view_only() end),
	awful.button({ Modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ Modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal(
				"request::activate",
				"tasklist",
				{ raise = true }
			)
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end))

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local function set_initial_tag(s)
	local screen = s
	local tag = screen.tags[3]
	if tag then
		tag:view_only()
	end
end

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ " code ", " www ", " home ", " gnrl ", " comm ", " node ", " syst " }, s, awful.layout.layouts[1])

	-- Set the tag that is focused when awesome starts
	set_initial_tag(s)

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function() awful.layout.inc(1) end),
		awful.button({}, 3, function() awful.layout.inc(-1) end),
		awful.button({}, 4, function() awful.layout.inc(1) end),
		awful.button({}, 5, function() awful.layout.inc(-1) end)))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		buttons = taglist_buttons
	}

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist {
		screen  = s,
		filter  = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons
	}

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s, height = 25 })

	-- Create a systray (system tray)
	s.systray = wibox.widget.systray()

	-- Add widgets to the wibox
	s.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			Mylauncher,
			s.mytaglist,
			s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{       -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			Mykeyboardlayout,
			s.systray,
			--wibox.widget.systray(),
			Mytextclock,
			s.mylayoutbox,
		},
	}
end)
-- }}}

-- {{{ Key bindings
Globalkeys = gears.table.join(
	awful.key({ Modkey, }, "s", hotkeys_popup.show_help,
		{ description = "show help", group = "awesome" }),
	awful.key({ Modkey, Modkey2 }, "h", awful.tag.viewprev,
		{ description = "view previous", group = "tag" }),
	awful.key({ Modkey, Modkey2 }, "l", awful.tag.viewnext,
		{ description = "view next", group = "tag" }),

	awful.key({ Modkey, }, "]",
		function()
			awful.client.focus.byidx(1)
		end,
		{ description = "focus next by index", group = "client" }
	),
	awful.key({ Modkey, }, "[",
		function()
			awful.client.focus.byidx(-1)
		end,
		{ description = "focus previous by index", group = "client" }
	),

	-- Moving window focus works between desktops
	awful.key({ Modkey, }, "j", function(c)
			awful.client.focus.global_bydirection("down")
		end,
		{ description = "focus next window up", group = "client" }),
	awful.key({ Modkey, }, "k", function(c)
			awful.client.focus.global_bydirection("up")
		end,
		{ description = "focus next window down", group = "client" }),
	awful.key({ Modkey, }, "l", function(c)
			awful.client.focus.global_bydirection("right")
		end,
		{ description = "focus next window right", group = "client" }),
	awful.key({ Modkey, }, "h", function(c)
			awful.client.focus.global_bydirection("left")
		end,
		{ description = "focus next window left", group = "client" }),

	-- Layout manipulation

	awful.key({ Modkey, "Shift" }, "h", function(c)
			awful.client.swap.global_bydirection("left")
		end,
		{ description = "swap with left client", group = "client" }),
	awful.key({ Modkey, "Shift" }, "l", function(c)
			awful.client.swap.global_bydirection("right")
		end,
		{ description = "swap with right client", group = "client" }),
	awful.key({ Modkey, "Shift" }, "j", function(c)
			awful.client.swap.global_bydirection("down")
		end,
		{ description = "swap with down client", group = "client" }),
	awful.key({ Modkey, "Shift" }, "k", function(c)
			awful.client.swap.global_bydirection("up")
		end,
		{ description = "swap with up client", group = "client" }),
	awful.key({ Modkey, "Control" }, "Tab", function() awful.client.swap.byidx(1) end,
		{ description = "swap with next client by index", group = "client" }),
	awful.key({ Modkey, "Control", "Shift" }, "Tab", function() awful.client.swap.byidx(-1) end,
		{ description = "swap with previous client by index", group = "client" }),
	awful.key({ Modkey, Modkey2 }, "]", function() awful.screen.focus_relative(1) end,
		{ description = "focus the next screen", group = "screen" }),
	awful.key({ Modkey, Modkey2 }, "[", function() awful.screen.focus_relative(-1) end,
		{ description = "focus the previous screen", group = "screen" }),
	awful.key({ Modkey, }, "u", awful.client.urgent.jumpto,
		{ description = "jump to urgent client", group = "client" }),
	awful.key({ Modkey, Modkey2, "Shift" }, "l", function()
			local screen = awful.screen.focused()
			local t = screen.selected_tag
			if t then
				local idx = t.index + 1
				if idx > #screen.tags then idx = 1 end
				if client.focus then
					client.focus:move_to_tag(screen.tags[idx])
					screen.tags[idx]:view_only()
				end
			end
		end,
		{ description = "move focused client to next tag and view tag", group = "tag" }),
	awful.key({ Modkey, Modkey2, "Shift" }, "h", function()
			local screen = awful.screen.focused()
			local t = screen.selected_tag
			if t then
				local idx = t.index - 1
				if idx == 0 then idx = #screen.tags end
				if client.focus then
					client.focus:move_to_tag(screen.tags[idx])
					screen.tags[idx]:view_only()
				end
			end
		end,
		{ description = "move focused client to previous tag and view tag", group = "tag" }),

	-- Quit/reload awesome
	awful.key({ Modkey, "Control" }, "r", awesome.restart,
		{ description = "reload awesome", group = "awesome" }),
	awful.key({ Modkey, Modkey2, "Control", "Shift" }, "\\", awesome.quit,
		{ description = "quit awesome", group = "awesome" }),

	-- Master and stack manipulation
	awful.key({ Modkey, }, ",", function() awful.tag.incnmaster(1, nil, true) end,
		{ description = "increase the number of master clients", group = "layout" }),
	awful.key({ Modkey, "Shift" }, ",", function() awful.tag.incnmaster(-1, nil, true) end,
		{ description = "decrease the number of master clients", group = "layout" }),
	awful.key({ Modkey, }, ".", function() awful.tag.incncol(1, nil, true) end,
		{ description = "increase the number of columns", group = "layout" }),
	awful.key({ Modkey, "Shift" }, ".", function() awful.tag.incncol(-1, nil, true) end,
		{ description = "decrease the number of columns", group = "layout" }),
	awful.key({ Modkey, "Control" }, "space", function() awful.layout.inc(1) end,
		{ description = "select next", group = "layout" }),
	awful.key({ Modkey, "Control", "Shift" }, "space", function() awful.layout.inc(-1) end,
		{ description = "select previous", group = "layout" }),

	awful.key({ Modkey, }, "w",
		function()
			local c = awful.client.restore()
			-- Focus restored client
			if c then
				c:emit_signal(
					"request::activate", "key.unminimize", { raise = true }
				)
			end
		end,
		{ description = "restore minimized", group = "client" }),

	-- Launcher
	awful.key({ Modkey, }, "space", function()
			awful.spawn(Utility.launcher)
		end,
		{ description = "program launcher (" .. Utility.launcher .. ")", group = "launcher" }),
	-- Bookmark inserting utility
	awful.key({ Modkey, Modkey2, }, "b", function()
			awful.spawn(Utility.bookmark)
		end,
		{ description = "bookmarks - insert a bookmark", group = "launcher" }),
	-- Mount a USB drive
	awful.key({ Modkey, Modkey2, }, "u", function()
			awful.spawn.with_shell(Utility.usb_mounter)
		end,
		{ description = "Mount a usb drive", group = "launcher" }),
	-- Unmount a USB drive
	awful.key({ Modkey, Modkey2, "Shift" }, "u", function()
			awful.spawn.with_shell(Utility.usb_unmounter)
		end,
		{ description = "Unmount a usb drive", group = "launcher" }),
	-- Characters utility
	awful.key({ Modkey, }, "c", function()
			awful.spawn(Utility.characters)
		end,
		{ description = "characters - copy a unicode character/emoji/glyph etc", group = "launcher" }),
	-- Configure dual displays
	awful.key({ Modkey, }, "d", function()
			awful.spawn.with_shell(Utility.display.dual)
		end,
		{ description = "Switch to the dual screen setup", group = "screen" }),
	-- Interactive displays utility
	awful.key({ Modkey, "Shift", }, "d", function()
			awful.spawn(Utility.display.interactive)
		end,
		{ description = "configure displays interactvely", group = "launcher" }),
	-- Dismiss notifications
	awful.key({ Modkey, }, "n", function()
			awful.spawn.with_shell("dunstctl close-all")
		end,
		{ description = "Switch to the dual screen setup", group = "screen" }),

	-- Terminal
	awful.key({ Modkey, }, "Return", function()
			awful.spawn(Utility.terminal)
		end,
		{ description = "open a terminal", group = "launcher" }),
	-- Terminal here
	awful.key({ Modkey, "Shift", }, "Return", function()
			awful.spawn.with_shell(Utility.terminal_here)
		end,
		{ description = "open a terminal in the working directory of the focused window", group = "launcher" }),
	-- Text Editor
	awful.key({ Modkey, Modkey2, }, "Return", function()
			awful.spawn(Editor_cmd)
		end,
		{ description = "Open a text editor (" .. Utility.text_editor .. ")", group = "launcher" }),
	-- Browser
	awful.key({ Modkey, }, "b", function()
			awful.spawn(Utility.browser)
		end,
		{ description = "Open a browser (" .. Utility.browser .. ")", group = "launcher" }),
	awful.key({ Modkey, }, "e", function()
			awful.spawn("emacsclient -c -a 'emacs'")
		end,
		{ description = "Open GNU Emacs", group = "launcher" }),
	-- Email client
	awful.key({ Modkey, Modkey2, }, "m", function()
			awful.spawn(Utility.mail)
		end,
		{ description = "Open an email bloatware (" .. Utility.mail .. ")", group = "launcher" }),
	-- Feed reader
	awful.key({ Modkey, }, "r", function()
			awful.spawn(Terminal_open(Utility.feed_reader))
		end,
		{ description = "Open an RSS/Atom feed reader (" .. Utility.feed_reader .. ")", group = "launcher" }),
	-- File manager
	awful.key({ Modkey, }, "/", function()
			awful.spawn(Terminal_open(Utility.file_manager))
		end,
		{ description = "Open a file manager (" .. Utility.file_manager .. ")", group = "launcher" }),
	-- Directory fuzzy finder
	awful.key({ Modkey, "Shift" }, "/", function()
			awful.spawn(Terminal_open(Utility.directory_fuzzy_finder))
		end,
		{ description = "Open a directory fuzzy finder (" .. Utility.directory_fuzzy_finder .. ")", group = "launcher" }),
	-- Music player
	awful.key({ Modkey, Modkey2 }, "p", function()
			awful.spawn(Terminal_open(Utility.music_player))
		end,
		{ description = "Open a music player (" .. Utility.music_player .. ")", group = "launcher" }),
	-- System monitor
	awful.key({ Modkey, Modkey2, }, "s", function()
			awful.spawn(Terminal_open(Utility.system_monitor))
		end,
		{ description = "Open a system monitor (" .. Utility.system_monitor .. ")", group = "launcher" }),
	-- Password Manager
	awful.key({ Modkey, }, "p", function()
			awful.spawn(Utility.password_manager)
		end,
		{ description = "Open a password manager (" .. Utility.password_manager .. ")", group = "launcher" }),
	-- Display temperature
	awful.key({ Modkey, Modkey2 }, "t", function()
			awful.spawn(Utility.display.temperature)
		end,
		{ description = "Set the display temperature (" .. Utility.display.temperature .. ")", group = "launcher" }),

	-- Lock the screen
	awful.key({ Modkey }, "Escape", function()
			awful.spawn("slock")
		end,
		{ description = "Lock the screen", group = "screen" }),
	-- Take a screenshot
	awful.key({}, "Print", function()
			awful.spawn.with_shell(Utility.screenshot.full)
		end,
		{ description = "Take a full screenshot (all screens)", group = "screen" }),

	-- Choose a screenshot type
	awful.key({ "Shift", }, "Print", function()
			awful.spawn.with_shell(Utility.screenshot.interactive)
		end,
		{ description = "Choose what kind of screenshot to take", group = "screen" }),

	-- Volume control
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn.with_shell("command wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+")
	end),
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn.with_shell("command wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-")
	end),
	awful.key({}, "XF86AudioMute", function()
		awful.spawn.with_shell("command wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
	end),
	-- Brightness control
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn.with_shell("command brightnessctl set +10%")
	end),
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn.with_shell("command brightnessctl set 10%-")
	end),
	awful.key({ Modkey, Modkey2 }, "=", function()
		awful.spawn.with_shell("command brightnessctl set +10%")
	end),
	awful.key({ Modkey, Modkey2 }, "-", function()
		awful.spawn.with_shell("command brightnessctl set 10%-")
	end),

	--Move systray to another monitor
	awful.key({ Modkey, "Shift", }, "t", function()
		local traywidget = wibox.widget.systray()
		traywidget:set_screen(awful.screen.focused())
	end, { description = "move systray to screen", group = "awesome" })

)

Clientkeys = gears.table.join(
	awful.key({ Modkey, }, "f",
		function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{ description = "toggle fullscreen", group = "client" }),
	awful.key({ Modkey, "Shift", }, "w", function(c) c:kill() end,
		{ description = "close", group = "client" }),
	awful.key({ Modkey, "Shift", }, "f", awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }),
	--[[
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
		]]
	awful.key({ Modkey, Modkey2, "Shift" }, "[", function(c) c:move_to_screen() end,
		{ description = "move to screen", group = "client" }),
	awful.key({ Modkey, Modkey2, "Shift" }, "]", function(c) c:move_to_screen() end,
		{ description = "move to screen", group = "client" }),
	awful.key({ Modkey, }, "t", function(c) c.ontop = not c.ontop end,
		{ description = "toggle keep on top", group = "client" }),
	awful.key({ Modkey, "Control" }, "w",
		function(c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end,
		{ description = "minimize", group = "client" }),
	awful.key({ Modkey, }, "m",
		function(c)
			c.maximized = not c.maximized
			c:raise()
		end,
		{ description = "(un)maximize", group = "client" }),
	awful.key({ Modkey, "Control" }, "m",
		function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end,
		{ description = "(un)maximize vertically", group = "client" }),
	awful.key({ Modkey, "Shift" }, "m",
		function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end,
		{ description = "(un)maximize horizontally", group = "client" }),

	-- Resize windows
	awful.key({ Modkey, Modkey2 }, "Up", function(c)
			if c.floating then
				c:relative_move(0, 0, 0, -5)
			else
				awful.client.incwfact(0.02)
			end
		end,
		{ description = "Resize window vertically -", group = "client" }),
	awful.key({ Modkey, Modkey2 }, "Down", function(c)
			if c.floating then
				c:relative_move(0, 0, 0, 5)
			else
				awful.client.incwfact(-0.02)
			end
		end,
		{ description = "Resize window vertically +", group = "client" }),
	awful.key({ Modkey, Modkey2 }, "Left", function(c)
			if c.floating then
				c:relative_move(0, 0, -5, 0)
			else
				awful.tag.incmwfact(-0.02)
			end
		end,
		{ description = "Resize window horizontally -", group = "client" }),
	awful.key({ Modkey, Modkey2 }, "Right", function(c)
			if c.floating then
				c:relative_move(0, 0, 5, 0)
			else
				awful.tag.incmwfact(0.02)
			end
		end,
		{ description = "Resize window horizontally +", group = "client" }),

	-- Moving floating windows
	awful.key({ Modkey, "Shift" }, "Down", function(c)
			c:relative_move(0, 10, 0, 0)
		end,
		{ description = "Floating Move Down", group = "client" }),
	awful.key({ Modkey, "Shift" }, "Up", function(c)
			c:relative_move(0, -10, 0, 0)
		end,
		{ description = "Floating Move Up", group = "client" }),
	awful.key({ Modkey, "Shift" }, "Left", function(c)
			c:relative_move(-10, 0, 0, 0)
		end,
		{ description = "Floating Move Left", group = "client" }),
	awful.key({ Modkey, "Shift" }, "Right", function(c)
			c:relative_move(10, 0, 0, 0)
		end,
		{ description = "Floating Move Right", group = "client" })

)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	Globalkeys = gears.table.join(Globalkeys,
		-- View tag only.
		awful.key({ Modkey }, "#" .. i + 9,
			function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end,
			{ description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ Modkey, Modkey2 }, "#" .. i + 9,
			function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end,
			{ description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ Modkey, "Shift" }, "#" .. i + 9,
			function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end,
			{ description = "move focused client to tag #" .. i, group = "tag" }),

		-- Toggle tag on focused client.
		awful.key({ Modkey, Modkey2, "Shift" }, "#" .. i + 9,
			function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end,
			{ description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

Clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ Modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ Modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(Globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = Clientkeys,
			buttons = Clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen
		}
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
				"eog"
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			}
		},
		properties = { floating = true }
	},

	-- Add titlebars to normal clients and dialogs
	--{ rule_any = {type = { "normal", "dialog" }
	--  }, properties = { titlebars_enabled = true }
	--},

	-- Set Firefox to always map on the tag named "2" on screen 1.
	--{ rule = { class = "Firefox" },
	--properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup
		and not c.size_hints.user_position
		and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup {
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout  = wibox.layout.fixed.horizontal
		},
		{ -- Middle
			{ -- Title
				align  = "center",
				widget = awful.titlebar.widget.titlewidget(c)
			},
			buttons = buttons,
			layout  = wibox.layout.flex.horizontal
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal()
		},
		layout = wibox.layout.align.horizontal
	}
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Automatically start programs
awful.spawn.with_shell("$XDG_CONFIG_HOME/autostart/xautostart")
