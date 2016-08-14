int main (string[] args) {

	Gtk.init (ref args);
	new Application ();
	//return app.run (args);
	Application.window.show_all ();
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

public class Albums : Gtk.TreeView {
	private static Gtk.TreeIter iteraa;
	private static Gtk.TreeIter iterat;
	private static Gtk.ScrolledWindow scrollTree;
	private static Gtk.TreeStore album_store;
	private static Gtk.TreeView albums;

	public static void cmd_dbalbums (string artist) {
		var conn = get_conn ();
		Mpd.Song song;
		conn.search_db_songs (false);
		conn.search_add_tag_constraint (Mpd.Operator.DEFAULT, Mpd.TagType.ARTIST, artist);
		conn.search_commit ();

		scrollTree = new Gtk.ScrolledWindow (null, null);
		scrollTree.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		scrollTree.set_hexpand (true);

		album_store = new Gtk.TreeStore (3, typeof (string), typeof (string), typeof (string));

		albums = new Gtk.TreeView.with_model (album_store);
		albums.set_vexpand (true);
		albums.set_hexpand (true);
		albums.set_grid_lines (Gtk.TreeViewGridLines.VERTICAL);

		Gtk.CellRendererText cell = new Gtk.CellRendererText ();
		cell.ellipsize = Pango.EllipsizeMode.END;
		albums.insert_column_with_attributes (-1, "#", cell, "text", 1);
		albums.insert_column_with_attributes (-1, "Title", cell, "text", 2);
		string album = null;
		while ((song = conn.recv_song ()) != null) {
			string track = song.get_tag (Mpd.TagType.TRACK);
			if (track == null || track.char_count () == 1) {
				track = "0" + track;
			} else if (track.char_count () > 2) {
				track = track.substring (0, 2);
				//track = track.substring(0, track.index_of("/", 0));
			}
			string title = song.get_tag (Mpd.TagType.TITLE);
			string file = song.get_uri ();
			if (album == null || song.get_tag (Mpd.TagType.ALBUM) != album) {
				album = song.get_tag (Mpd.TagType.ALBUM);
				string year = song.get_tag (Mpd.TagType.DATE);
				year = ((year == null ) ? "0000" : year.substring (0, 4));
				album_store.append (out iteraa, null);
				album_store.set (iteraa, 0, "album", 1, year, 2, album);
			}
			album_store.append (out iterat, iteraa);
			album_store.set (iterat, 0, file, 1, track, 2, title);
		}
		albums.expand_all ();
		albums.row_activated.connect (on_row_album);
		scrollTree.add (albums);
		Application.stack.add_titled (scrollTree, artist, artist);
	}

	private static void on_row_album (Gtk.TreeView treeview , Gtk.TreePath path, Gtk.TreeViewColumn column) {
		Gtk.TreeIter iter;
		string track;
		string title;
		string file;
		if (treeview.model.get_iter (out iter, path)) {
			treeview.model.get (iter,
							0, out file,
							1, out track,
							2, out title);
			//Mpd.Song song;
			var conn = get_conn ();
			conn.search_add_db_songs (false);
			if (file == "album") {
				conn.search_add_tag_constraint(Mpd.Operator.DEFAULT, Mpd.TagType.ALBUM, title);
			} else {
				conn.search_add_uri_constraint (Mpd.Operator.DEFAULT, file);
			}
			conn.search_commit ();
			stdout.printf ("%s\n", file);
			stdout.printf ("%s\n", title);
			//while ((song = conn.recv_song ()) != null) {
			//	stdout.printf ("%s\n", file);
			//}
			Application.cmd_playls ();
		}
	}
}

public class Application {

	public static Gtk.Window window;
	public static Gtk.Button buttonToggle;
	public static Gtk.Grid grid;
	public static Gtk.Grid gridPlay;
	public static Gtk.Image artPlay ;
	public static Gtk.ScrolledWindow scrollList;
	public static Gtk.TreeStore tree_store;
	public static Gtk.TreeView tree;
	public static Gtk.TreeIter itera;
	public static Gtk.TreeIter itert;
	public static uint currp;
	public static uint currc;
	public static Gtk.Stack stack;

	public static PlaylistEntry[] playlist = {
		new PlaylistEntry ("1", "Billeter"),
		new PlaylistEntry ("2", "Schmid"),
		new PlaylistEntry ("3", "Inca"),
		new PlaylistEntry ("4", "Jardon"),
		new PlaylistEntry ("5", "Clinton"),
		new PlaylistEntry ("6", "Hacker")
	};

	public static void cmd_toggle () {
		var conn = get_conn ();
		if (current_status () == Mpd.State.PLAY) {
			conn.run_pause (true);
			Gtk.Image image = new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);
			buttonToggle.set_image (image);
		} else {
			conn.run_play ();
			Gtk.Image image = new Gtk.Image.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.MENU);
			buttonToggle.set_image (image);
		}
	}

	public static void cmd_prev () {
		var conn = get_conn ();
		if (current_elapsed () < 3) {
			conn.run_previous ();
			cmd_art ();
			cmd_psel();
		} else {
			cmd_seek (0);
			conn.run_play ();
		}
		Gtk.Image image = new Gtk.Image.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.MENU);
		buttonToggle.set_image (image);
	}

	public static void cmd_next () {
		var conn = get_conn ();
		conn.run_next ();
		Gtk.Image image = new Gtk.Image.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.MENU);
		buttonToggle.set_image (image);
		cmd_art ();
		cmd_psel();
	}

	public static void cmd_art () {
		if (current_status () != Mpd.State.STOP) {
			var conn = get_conn ();
			Mpd.Song song = conn.run_current_song ();
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
			try {
				var albumArt = new Gdk.Pixbuf.from_file_at_size (file, 300, 300);
				artPlay.set_from_pixbuf (albumArt);
			} catch (GLib.Error e) {
				stderr.printf ("Could not load album art: %s\n", e.message);
			}
			//albumArt.scale_simple(150, 150, Gdk.InterpType.BILINEAR);
			//artPlay.set_from_file("cover.jpg");
			//artPlay.set_from_icon_name("media-optical", Gtk.IconSize.DND);
		}
	}

	public static void cmd_playls () {
		var conn = get_conn ();
		Mpd.Song song;
		conn.send_list_queue_meta ();
		tree_store.clear ();
		string album = null;
		while ((song = conn.recv_song ()) != null) {
			string track = song.get_tag (Mpd.TagType.TRACK);
			if (track == null || track.char_count () == 1) {
				track = "0" + track;
			} else {
				track = track.substring (0, 2);
			}
			//track = int.parse(trackn);
			string title = song.get_tag (Mpd.TagType.TITLE);
			uint pos = song.get_pos ();
			if (album == null || song.get_tag (Mpd.TagType.ALBUM) != album) {
				album = song.get_tag (Mpd.TagType.ALBUM);
				string year = song.get_tag (Mpd.TagType.DATE);
				year = ((year == null ) ? "0000" : year.substring (0, 4));
				tree_store.append (out itera, null);
				tree_store.set (itera, 0, pos, 1, year, 2, album);
			}
			tree_store.append (out itert, itera);
			tree_store.set (itert, 0, pos, 1, track, 2, title);
			//free(song);
		}
		cmd_psel();
		tree.row_activated.connect (on_row_activated);
		//var selection = tree.get_selection ();
		//selection.changed.connect (on_changed);
	}

	public static void cmd_psel () {
		var conn = get_conn ();
		Mpd.Song song;
		Mpd.Status status = conn.run_status ();
		conn.send_list_queue_meta ();
		string album = null;
		int parent = -1;
		int child = -1;
		currp = 0;
		currc = 0;
		while ((song = conn.recv_song ()) != null) {
			uint pos = song.get_pos ();
			if (album == null || song.get_tag (Mpd.TagType.ALBUM) != album) {
				album = song.get_tag (Mpd.TagType.ALBUM);
				parent++;
				child = -1;
			}
			child++;
			if (status.get_song_pos () == pos) {
				currp = parent;
				currc = child;
			}
		}
		var path = new Gtk.TreePath.from_indices (currp, currc);
		if (!tree.is_row_expanded (path)) {
			tree.expand_to_path (path);
		}
		tree.set_cursor (path, null, false);
		tree.scroll_to_cell (path, null, true, 0.5f, 0);
	}

	public static void on_row_activated (Gtk.TreeView treeview , Gtk.TreePath path, Gtk.TreeViewColumn column) {
		Gtk.TreeIter iter;
		uint pos;
		string track;
		string title;
		var conn = get_conn ();
		if (tree.model.get_iter (out iter, path)) {
			tree.model.get (iter,
							0, out pos,
							1, out track,
							2, out title);
			conn.send_play_pos (pos);
			Gtk.Image image = new Gtk.Image.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.MENU);
			buttonToggle.set_image (image);
			cmd_art ();
		}
	}
	//public static void on_changed (Gtk.TreeSelection selection) {
	//}

	public static void cmd_delete (Gtk.TreeSelection selection) {
		Gtk.TreeModel model;
		Gtk.TreeIter iter;
		uint pos;
		string track;
		string title;
		var conn = get_conn ();
		if (selection.get_selected (out model, out iter)) {
			model.get (iter,
						0, out pos,
						1, out track,
						2, out title);
			stdout.printf ("%s\n", track);
			if (track != null && track.char_count () > 2) {
				Mpd.Song song;
				conn.send_list_queue_meta ();
				uint pos0 = -1;
				uint pos1 = -1;
				while ((song = conn.recv_song ()) != null) {
					if (song.get_tag (Mpd.TagType.ALBUM) == title) {
						if (pos0 == -1) {
							pos0 = song.get_pos ();
						}
						pos1 = song.get_pos ();
					}
				}
				pos1++;
				conn.run_delete_range (pos0, pos1);
			} else {
				conn.run_delete (pos);
			}
			cmd_playls ();
		}
	}

	public static void cmd_dbartists () {
		var conn = get_conn ();
		Mpd.Pair pair;
		string artist;
		conn.search_db_tags (Mpd.TagType.ARTIST);
		conn.search_commit ();
		while ((pair = conn.recv_pair_tag (Mpd.TagType.ARTIST)) != null) {
			if ((artist = pair.value) != "\0") {
				Albums.cmd_dbalbums (artist);
			}
			conn.return_pair (pair);
		}
	}

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
		window = new Gtk.Window ();
		//window.set_border_width (12);
		window.set_position (Gtk.WindowPosition.CENTER);
		window.set_default_size (1000, 600);
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

		buttonToggle = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);
		if (current_status () == Mpd.State.PLAY) {
			buttonToggle = new Gtk.Button.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.MENU);
		}
		buttonToggle.clicked.connect (() => {
			cmd_toggle ();
		});

		var buttonPrev = new Gtk.Button.from_icon_name ("media-skip-backward-symbolic", Gtk.IconSize.MENU);
		buttonPrev.clicked.connect (() => {
			cmd_prev ();
		});

		var buttonNext = new Gtk.Button.from_icon_name ("media-skip-forward-symbolic", Gtk.IconSize.MENU);
		buttonNext.clicked.connect (() => {
			cmd_next ();
		});

		box.add (buttonPrev);
		box.add (buttonToggle);
		box.add (buttonNext);

		var button_menu = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.MENU);
		button_menu.clicked.connect (() => {
			var popover = new Gtk.Popover (button_menu);
			popover.set_position (Gtk.PositionType.BOTTOM);
			var box2 = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
			popover.add (box2);

			var button_db = new Gtk.Button.with_label ("Update database");
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
		grid.attach (gridPlay, 0, 0, 1, 1);

		artPlay = new Gtk.Image ();
		artPlay.set_halign (Gtk.Align.CENTER);
		cmd_art ();
		gridPlay.add (artPlay);

		gridPlay.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

		scrollList = new Gtk.ScrolledWindow (null, null);
		scrollList.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		scrollList.set_hexpand (false);
		gridPlay.add (scrollList);

		tree_store = new Gtk.TreeStore (3, typeof (uint), typeof (string), typeof (string));

		//for (int i = 0; i < playlist.length; i++) {
		//	list_store.append (out iter);
		//	list_store.set (iter, 0, playlist[i].number, 1, playlist[i].title);
		//}

		tree = new Gtk.TreeView.with_model (tree_store);
		tree.set_vexpand (true);
		tree.set_grid_lines (Gtk.TreeViewGridLines.VERTICAL);
		scrollList.add (tree);

		Gtk.CellRendererText cell = new Gtk.CellRendererText ();
		cell.ellipsize = Pango.EllipsizeMode.END;
		tree.insert_column_with_attributes (-1, "#", cell, "text", 1);
		tree.insert_column_with_attributes (-1, "Title", cell, "text", 2);

		cmd_playls ();

		var actionbar = new Gtk.ActionBar();
		//actionbar.set_hexpand (false);
		//actionbar.set_margin_top(0);
		//grid.attach(actionbar, 0, 1, 1, 1);
		gridPlay.add(actionbar);

		var plbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		plbox.get_style_context ().add_class("linked");
		actionbar.pack_start(plbox);
		var up = new Gtk.Button.from_icon_name ("go-up-symbolic", Gtk.IconSize.MENU);
		plbox.pack_start(up);
		var remove = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.MENU);
		remove.clicked.connect (() => {
			var selection = tree.get_selection ();
			cmd_delete (selection);
		});
		plbox.pack_start(remove);
		var down = new Gtk.Button.from_icon_name ("go-down-symbolic", Gtk.IconSize.MENU);
		plbox.pack_start(down);
		var clear = new Gtk.Button.from_icon_name ("list-remove-all-symbolic", Gtk.IconSize.MENU);
		clear.clicked.connect (() => {
			var conn = get_conn ();
			conn.run_clear ();
		});
		actionbar.pack_end (clear);

		grid.attach ((new Gtk.Separator (Gtk.Orientation.HORIZONTAL)), 1, 0, 1, 1);

		stack = new Gtk.Stack ();
		stack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
		cmd_dbartists ();
		grid.attach (stack, 3, 0, 1, 1);

		Gtk.StackSidebar sidebar = new Gtk.StackSidebar ();
		sidebar.set_stack (stack);
		grid.attach (sidebar, 2, 0, 1, 1);

		//Gtk.FlowBox fbox = new Gtk.FlowBox ();
		//fbox.set_hexpand (true);
		//fbox.set_vexpand (true);
		//fbox.add ((new Gtk.Label ("Library")));
		//grid.attach (fbox, 2, 0, 1, 1);
	}
}
