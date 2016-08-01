using Mpd;

int main (string[] args) {

	Gtk.init (ref args);
	var app = new Application ();
	//return app.run (args);
	app.window.show_all ();
	Gtk.main ();
	return 0;

}

public static Connection get_conn () {
	Mpd.Connection conn = new Connection ("localhost", 6600, 0);
	if (conn.get_error () != Mpd.Error.SUCCESS) {
		stdout.printf ("Could not connect to mpd: %s\n", conn.get_error_message());
	}
	return conn;
}

public static State current_status () {
	var conn = get_conn ();
	Mpd.Status status = conn.run_status ();
	var state = status.get_state ();
	return state;
}

public static uint current_elapsed () {
	var conn = get_conn ();
	Mpd.Status status = conn.run_status ();
	var elapsed = status.get_elapsed_time ();
	return elapsed;
}

public static uint current_total () {
	var conn = get_conn ();
	Mpd.Status status = conn.run_status ();
	var total = status.get_total_time ();
	return total;
}

public static string to_minutes (uint seconds) {
	uint minutes = seconds / 60;
	seconds -= minutes * 60;
	return "%s:%s".printf (@"$minutes", ((seconds < 10 ) ? @"0$seconds" : @"$seconds"));
}

public static string current_title () {
	var conn = get_conn ();
	Mpd.Song song = conn.run_current_song ();
	var curr = "Title";
	if (current_status () == Mpd.State.PLAY || current_status () == Mpd.State.PAUSE) {
		curr = song.get_tag (Mpd.TagType.TITLE);
	}
	return curr;
}

public static string current_artist () {
	var conn = get_conn ();
	Mpd.Song song = conn.run_current_song ();
	var curr = "Artist";
	if (current_status () == Mpd.State.PLAY || current_status () == Mpd.State.PAUSE) {
		curr = song.get_tag (Mpd.TagType.ARTIST);
	}
	return curr;
}

public static void cmd_toggle () {
	var conn = get_conn ();
	if (current_status () == Mpd.State.PLAY) {
		conn.run_pause (true);
	} else {
		conn.run_play ();
	}
}

public static void cmd_prev () {
	var conn = get_conn ();
	if (current_elapsed () < 3) {
		conn.run_previous ();
	} else {
		cmd_seek (0);
	}
}

public static void cmd_next () {
	var conn = get_conn ();
	conn.run_next ();
}

public static void cmd_seek (uint pos) {
	var conn = get_conn ();
	Mpd.Status status = conn.run_status ();
	conn.run_seek_pos (status.get_song_pos (), pos);
}

public class PlaylistEntry {
	public string number;
	public string title;

	public PlaylistEntry (string n, string t) {
		this.number = n;
		this.title = t;
	}
}

public class Application {

	public static Gtk.Window window;
	public static Gtk.Grid grid;
	public static Gtk.Grid gridPlay;
	public static Gtk.ScrolledWindow scrollList;
	public static Gtk.TreeStore tree_store;
	public static Gtk.TreeView tree;
	public static Gtk.TreePath *path;
	public static Gtk.TreeIter itera;
	public static Gtk.TreeIter itert;

	public static PlaylistEntry[] playlist = {
		new PlaylistEntry ("1", "Billeter"),
		new PlaylistEntry ("2", "Schmid"),
		new PlaylistEntry ("3", "Inca"),
		new PlaylistEntry ("4", "Jardon"),
		new PlaylistEntry ("5", "Clinton"),
		new PlaylistEntry ("6", "Hacker")
	};

	public static void cmd_playls () {
		var conn = get_conn ();
		Mpd.Song song;
		Mpd.Status status = conn.run_status ();
		conn.send_list_queue_meta();
		tree_store.clear();
		string album = null;
		int parent = -1;
		int child = -1;
		uint currp = parent;
		uint currc = child;
		while ((song = conn.recv_song ()) != null) {
			string track = song.get_tag (Mpd.TagType.TRACK);
			track = ((track == null ) ? "00" : track.substring (0, 2));
			//track = int.parse(trackn);
			string title = song.get_tag (Mpd.TagType.TITLE);
			uint pos = song.get_pos ();
			if (album == null || song.get_tag (Mpd.TagType.ALBUM) != album) {
				album = song.get_tag (Mpd.TagType.ALBUM);
				string year = song.get_tag (Mpd.TagType.DATE);
				parent++;
				child = -1;
				tree_store.append (out itera, null);
				tree_store.set (itera, 0, year, 1, album, 2, 0);
			}
			child++;
			if (status.get_song_pos () == pos) {
				currp = parent;
				currc = child;
			}
			tree_store.append (out itert, itera);
			tree_store.set (itert, 0, track, 1, title, 2, pos);
			//free(song);
		}
		string curr = parent.to_string() + ":" + child.to_string();
		stdout.printf ("%s\n", curr);
		//tree.expand_all();
		var path = new Gtk.TreePath.from_indices (currp, currc);
		//var path = new Gtk.TreePath.from_string ("3:5");
		if (!tree.is_row_expanded (path)) {
			tree.expand_to_path (path);
		}
		tree.set_cursor(path, null, false);
		tree.scroll_to_cell(path, null, true, 0, 0);
		tree.row_activated.connect (on_row_activated);
		//var selection = tree.get_selection ();
		//selection.changed.connect (on_changed);
	}
	public static void on_row_activated (Gtk.TreeView treeview , Gtk.TreePath path, Gtk.TreeViewColumn column) {
		Gtk.TreeIter iter;
		string track;
		string title;
		uint pos;
		var conn = get_conn ();
		if (tree.model.get_iter (out iter, path)) {
			tree.model.get (iter,
							0, out track,
							1, out title,
							2, out pos);
			conn.send_play_pos (pos);
		}
	}
	//public static void on_changed (Gtk.TreeSelection selection) {
	//	Gtk.TreeModel model;
	//	Gtk.TreeIter iter;
	//	string track;
	//	string title;
	//	uint pos;
	//	var conn = get_conn ();

	//	if (selection.get_selected (out model, out iter)) {
	//		model.get (iter,
	//						 0, out track,
	//						 1, out title,
	//						 2, out pos);
	//		conn.send_play_pos (pos);
	//	}
	//}

	public static void cmd_updb () {
		var conn = get_conn ();
		Mpd.Status status = conn.run_status ();
		conn.run_update ();
		//stdout.printf ("%s\n", (string)status.get_update_id ());
		var timeout = GLib.Timeout.add (500, () => {
			string upd = (string)status.get_update_id ();
			stdout.printf ("%s\n", upd);
			return true;
		});
	}

	public Application () {
		window = new Gtk.Window ();
		//window.set_border_width (12);
		window.set_position (Gtk.WindowPosition.CENTER);
		window.set_default_size (800, 500);
		window.destroy.connect (Gtk.main_quit);
		try {
			//window.icon = new Gdk.Pixbuf.from_file ("my-app.png");
			window.icon = Gtk.IconTheme.get_default ().load_icon ("multimedia-audio-player", 48, 0);
		} catch (GLib.Error e) {
			stderr.printf ("Could not load application icon: %s\n", e.message);
		}

		var headerbar = new Gtk.HeaderBar ();
		headerbar.title = "Music";
		//headerbar.subtitle = current_artist ();
		headerbar.show_close_button = true;
		//headerbar.get_style_context ().add_class ("titlebar");
		window.set_titlebar (headerbar);

		var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		box.get_style_context ().add_class("linked");
		headerbar.pack_start (box);

		var buttonToggle = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);
		if (current_status () == Mpd.State.PLAY) {
			buttonToggle = new Gtk.Button.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.MENU);
		}
		buttonToggle.clicked.connect (() => {
			cmd_toggle ();
			if (current_status() == Mpd.State.PLAY) {
				Gtk.Image image = new Gtk.Image.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.MENU);
				buttonToggle.set_image (image);
			} else {
				Gtk.Image image = new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);
				buttonToggle.set_image (image);
			}
		});

		var buttonPrev = new Gtk.Button.from_icon_name ("media-skip-backward-symbolic", Gtk.IconSize.MENU);
		buttonPrev.clicked.connect (() => {
			cmd_prev ();
			Gtk.Image image = new Gtk.Image.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.MENU);
			buttonToggle.set_image (image);
		});

		var buttonNext = new Gtk.Button.from_icon_name ("media-skip-forward-symbolic", Gtk.IconSize.MENU);
		buttonNext.clicked.connect (() => {
			cmd_next ();
			Gtk.Image image = new Gtk.Image.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.MENU);
			buttonToggle.set_image (image);
		});

		box.add (buttonPrev);
		box.add (buttonToggle);
		box.add (buttonNext);

		var button_menu = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.MENU);
		button_menu.clicked.connect (() => {
			var popover = new Gtk.Popover (button_menu);
			popover.set_position(Gtk.PositionType.BOTTOM);
			var box2 = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
			popover.add(box2);

			var button_db = new Gtk.Button.with_label ("Update database");
			button_db.clicked.connect (() => {
				button_db.label = "Updating database...";
				cmd_updb ();
			});
			box2.add(button_db);

			var label = new Gtk.Label("A Label Widget");
			box2.add(label);
			var checkbutton = new Gtk.CheckButton.with_label("A CheckButton Widget");
			box2.add(checkbutton);
			var radiobutton = new Gtk.RadioButton.with_label(null, "A RadioButton Widget");
			box2.add(radiobutton);
			popover.show_all ();
		});
		headerbar.pack_end (button_menu);

		var buttonSearch = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
		buttonSearch.clicked.connect (() => {
			cmd_playls ();
		});
		headerbar.pack_end (buttonSearch);

		var topDisplay = new TopDisplay ();
		var topDisplayBin = new FixedBin (200, -1, 600, -1);
		topDisplay.margin_start = 30;
		topDisplay.margin_end = 30;
		topDisplayBin.set_widget (topDisplay, true, false);
		topDisplayBin.show_all ();
		if (current_status () == Mpd.State.PLAY || current_status () == Mpd.State.PAUSE) {
			headerbar.set_custom_title (topDisplayBin);
		}

		GLib.Timeout.add (1000, () => {
			if (current_status () == Mpd.State.PLAY || current_status () == Mpd.State.PAUSE) {
				headerbar.set_custom_title (topDisplayBin);
			} else {
				headerbar.set_custom_title (null);
			}
			return true;
		});

		grid = new Gtk.Grid ();
		//grid.orientation = Gtk.Orientation.VERTICAL;
		grid.column_spacing = 0;
		grid.row_spacing = 0;
		window.add (grid);

	//	Gtk.Paned pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
	//	pane.set_vexpand(true);
	//	Gtk.WidgetSetSizeRequest (pane, 200, -1);
	//	grid.attach(pane, 0, 0, 1, 1);

		gridPlay = new Gtk.Grid ();
		gridPlay.orientation = Gtk.Orientation.VERTICAL;
		gridPlay.column_spacing = 0;
		gridPlay.row_spacing = 0;
		grid.attach(gridPlay, 0, 0, 1, 1);

		var artPlay = new Gtk.Image();
		var albumArt = new Gdk.Pixbuf.from_file_at_size("cover.jpg", 300, 300);
	//	albumArt.scale_simple(150, 150, Gdk.InterpType.BILINEAR);
		artPlay.set_from_pixbuf(albumArt);
	//	artPlay.set_from_file("cover.jpg");
	//	artPlay.set_from_icon_name("media-optical", Gtk.IconSize.DND);
		gridPlay.add (artPlay);

		gridPlay.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

		scrollList = new Gtk.ScrolledWindow (null, null);
		gridPlay.add (scrollList);

		tree_store = new Gtk.TreeStore (3, typeof (string), typeof (string), typeof (uint));

		//for (int i = 0; i < playlist.length; i++) {
		//	list_store.append (out iter);
		//	list_store.set (iter, 0, playlist[i].number, 1, playlist[i].title);
		//}

		tree = new Gtk.TreeView.with_model (tree_store);
		tree.set_vexpand(true);
		tree.set_grid_lines(Gtk.TreeViewGridLines.VERTICAL);
		scrollList.add (tree);

		Gtk.CellRendererText cell = new Gtk.CellRendererText ();
		tree.insert_column_with_attributes (-1, "#", cell, "text", 0);
		tree.insert_column_with_attributes (-1, "Title", cell, "text", 1);

		cmd_playls ();

		//var list = new Gtk.ListBox ();
		//list.set_vexpand(true);
		//list.insert (new Gtk.Label ("04. Chrysalis"), -1);
		//for (var i = 1; i < 3; i++)
		//{
		//	string text = @"$i. SongTitle";
		//	var label = new Gtk.Label(text);
		//	list.add(label);
		//}
		//scrollList.add (list);

		grid.attach((new Gtk.Separator (Gtk.Orientation.HORIZONTAL)), 1, 0, 1, 1);

		Gtk.FlowBox fbox = new Gtk.FlowBox ();
		fbox.set_hexpand(true);
		fbox.set_vexpand(true);
		fbox.add((new Gtk.Label ("Library")));
		grid.attach(fbox, 2, 0, 1, 1);

		var actionbar = new Gtk.ActionBar();
		actionbar.set_hexpand(true);
		//actionbar.set_margin_top(0);
		//grid.attach(actionbar, 0, 1, 1, 1);
		//gridPlay.add(actionbar);

		var button1 = new Gtk.Button.with_label("Cut");
		actionbar.pack_start(button1);
		var button2 = new Gtk.Button.with_label("Copy");
		actionbar.pack_start(button2);
		var button3 = new Gtk.Button.with_label("Paste");
		actionbar.pack_end(button3);
	}
}
