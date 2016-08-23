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

public class PlaylistEntry {
	public string number;
	public string title;

	public PlaylistEntry (string n, string t) {
		this.number = n;
		this.title = t;
	}
}

public class Application : Gtk.Window {
	public static Gtk.Grid grid;

	public static PlaylistEntry[] playlist = {
		new PlaylistEntry ("1", "Billeter"),
		new PlaylistEntry ("2", "Schmid"),
		new PlaylistEntry ("3", "Inca"),
		new PlaylistEntry ("4", "Jardon"),
		new PlaylistEntry ("5", "Clinton"),
		new PlaylistEntry ("6", "Hacker")
	};

	public static void cmd_updb () {
		var conn = get_conn ();
		conn.run_update ();
		Mpd.Status status = conn.run_status ();
		//stdout.printf ("%s\n", (string)status.get_update_id ());
		var timeout = GLib.Timeout.add (500, () => {
			if (status.get_update_id () > 0) {
				stdout.printf ("%s\n", "asd");
				status = null;
				status = conn.run_status ();
			}
			return true;
		});
	}

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

			var label = new Gtk.Label ("A Label Widget");
			box2.add (label);
			var checkbutton = new Gtk.CheckButton.with_label ("A CheckButton Widget");
			box2.add (checkbutton);
			var radiobutton = new Gtk.RadioButton.with_label (null, "A RadioButton Widget");
			box2.add (radiobutton);
			popover.show_all ();
		});
		headerbar.pack_end (button_menu);

		var buttonSearch = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
		buttonSearch.clicked.connect (() => {
			Playlist.cmd_playls ();
		});
		headerbar.pack_end (buttonSearch);

		GLib.Timeout.add (1000, () => {
			if (current_status () == Mpd.State.PLAY || current_status () == Mpd.State.PAUSE) {
				//headerbar.set_custom_title (topDisplayBin);
			} else {
				//headerbar.set_custom_title (null);
			}
			return true;
		});

		grid = new Gtk.Grid ();
		//grid.orientation = Gtk.Orientation.VERTICAL;
		grid.column_spacing = 0;
		grid.row_spacing = 0;
		add (grid);

		var mainstack = new Gtk.Stack ();
		mainstack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);

		var controls = new Controls ();
		controls.show_all ();
		grid.attach (controls, 0, 1, 2, 1);

	//	Gtk.Paned pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
	//	pane.set_vexpand(true);
	//	Gtk.WidgetSetSizeRequest (pane, 200, -1);
	//	grid.attach(pane, 0, 0, 1, 1);

		//grid.attach ((new Gtk.Separator (Gtk.Orientation.HORIZONTAL)), 1, 0, 1, 1);
		var playlist = new Playlist ();
		playlist.show_all ();

		var database = new Database ();
		database.show_all ();

		mainstack.add_titled (playlist, "playlist", "Playlist");
		mainstack.add_titled (database, "database", "Database");
		grid.attach (mainstack, 1, 0, 1, 1);

		Gtk.StackSwitcher switcher = new Gtk.StackSwitcher ();
		switcher.set_stack (mainstack);
		headerbar.set_custom_title (switcher);

		//Gtk.FlowBox fbox = new Gtk.FlowBox ();
		//fbox.set_hexpand (true);
		//fbox.set_vexpand (true);
		//fbox.add ((new Gtk.Label ("Library")));
		//grid.attach (fbox, 2, 0, 1, 1);
		show_all ();
	}
}
