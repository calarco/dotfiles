int main (string[] args) {
	Gtk.init (ref args);
	new Application ();
	Gtk.main ();
	return 0;
}

public static Mpd.Connection get_conn () {
	Mpd.Connection conn = new Mpd.Connection ("localhost", 6600, 0);
	if (conn.get_error () != Mpd.Error.SUCCESS) {
		stdout.printf ("Could not connect to mpd: %s\n", conn.get_error_message());
	}
	return conn;
}

public static Mpd.State current_status () {
	var conn = get_conn ();
	Mpd.Status status = conn.run_status ();
	var state = status.get_state ();
	return state;
}

public static string to_minutes (uint seconds) {
	uint minutes = seconds / 60;
	seconds -= minutes * 60;
	return "%s:%s".printf (@"$minutes", ((seconds < 10 ) ? @"0$seconds" : @"$seconds"));
}

public static void cmd_updb () {
	var conn = get_conn ();
	conn.run_update ();
	Mpd.Status status = conn.run_status ();
	GLib.Timeout.add (500, () => {
		if (status.get_update_id () > 0) {
			stdout.printf ("%s\n", "updating");
			status = null;
			status = conn.run_status ();
			return true;
		} else {
			return false;
		}
	});
}

public static Gdk.Pixbuf cmd_arts (Mpd.Song song, int size) {
	string folder = GLib.Environment.get_user_special_dir(GLib.UserDirectory.MUSIC) + "/" + Path.get_dirname (song.get_uri ());
	string file = null;
	try {
		Dir dir = Dir.open (folder, 0);
		string? name = null;
		while ((name = dir.read_name ()) != null) {
			string path = Path.build_filename (folder, name);
			var files = File.new_for_path (path);
			try {
				var file_info = files.query_info ("*", FileQueryInfoFlags.NONE);
				if (file_info.get_content_type ().substring (0, file_info.get_content_type().index_of("/", 0)) == "image" && FileUtils.test (path, FileTest.IS_REGULAR)) {
					file = path;
					stdout.printf ("File size: %lld bytes\n", file_info.get_size ());
				}
			} catch (GLib.Error e) {
				stderr.printf ("Could not query album art info: %s\n", e.message);
			}
		}
	} catch (FileError err) {
		stderr.printf (err.message);
	}
	var albumArt = new Gdk.Pixbuf (Gdk.Colorspace.RGB, false, 8, size, size);
	try {
		albumArt = new Gdk.Pixbuf.from_file_at_size (file, size, size);
	} catch (GLib.Error e) {
		stderr.printf ("Could not load album art: %s\n", e.message);
	}
	return albumArt;
	//albumArt.scale_simple(150, 150, Gdk.InterpType.BILINEAR);
	//artPlay.set_from_file("cover.jpg");
	//artPlay.set_from_icon_name("media-optical", Gtk.IconSize.DND);
}

public class Application : Gtk.Window {
	public static Gtk.Grid main_grid;
	public static Gtk.Stack main_stack;
	public static Gtk.StackSwitcher switcher;
	public static Gtk.Grid playlist;
	public static Gtk.Grid database;
	public static Gtk.ActionBar controls;

	public Application () {
		set_position (Gtk.WindowPosition.CENTER);
		set_default_size (1000, 600);
		destroy.connect (Gtk.main_quit);
		try {
			//icon = new Gdk.Pixbuf.from_file ("my-app.png");
			icon = Gtk.IconTheme.get_default ().load_icon ("multimedia-audio-player", 48, 0);
		} catch (GLib.Error e) {
			stderr.printf ("Could not load application icon: %s\n", e.message);
		}
		try {
			var provider = new Gtk.CssProvider ();
			provider.load_from_path ("main.css");
			Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
		} catch (GLib.Error e) {
			stderr.printf ("Could not load css: %s\n", e.message);
		}

		var headerbar = new Gtk.HeaderBar ();
		headerbar.title = "Music";
		//headerbar.subtitle = current_artist ();
		headerbar.show_close_button = true;
		set_titlebar (headerbar);

		var button_menu = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.MENU);
		button_menu.clicked.connect (() => {
			var popover = new Gtk.Popover (button_menu);
			popover.set_position (Gtk.PositionType.BOTTOM);
			var box2 = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
			popover.add (box2);

			var button_db = new Gtk.Button.with_label ("Update database");
			button_db.get_style_context ().add_class ("flat");
			button_db.clicked.connect (() => {
				button_db.label = "Updating database...";
				cmd_updb ();
			});
			box2.add (button_db);

			popover.show_all ();
		});
		headerbar.pack_end (button_menu);

		var buttonSearch = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
		buttonSearch.clicked.connect (() => {
			Playlist.cmd_playls ();
		});
		headerbar.pack_end (buttonSearch);

		main_grid = new Gtk.Grid ();
		main_grid.orientation = Gtk.Orientation.VERTICAL;
		add (main_grid);

		main_stack = new Gtk.Stack ();
		main_stack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
		main_grid.attach (main_stack, 0, 0, 1, 1);

		switcher = new Gtk.StackSwitcher ();
		switcher.set_stack (main_stack);
		headerbar.set_custom_title (switcher);

		playlist = new Playlist ();
		main_stack.add_titled (playlist, "playlist", "Playlist");

		database = new Database ();
		main_stack.add_titled (database, "database", "Database");

		controls = new Controls ();
		main_grid.attach (controls, 0, 1, 1, 1);

		//Gtk.Paned pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
		//pane.set_vexpand(true);
		//Gtk.WidgetSetSizeRequest (pane, 200, -1);
		//grid.attach(pane, 0, 0, 1, 1);

		//Gtk.FlowBox fbox = new Gtk.FlowBox ();
		//fbox.set_hexpand (true);
		//fbox.set_vexpand (true);
		//fbox.add ((new Gtk.Label ("Library")));
		//grid.attach (fbox, 2, 0, 1, 1);

		show_all ();
	}
}
