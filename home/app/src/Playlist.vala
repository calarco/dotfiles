public class Playlist : Gtk.Grid {
	public static Gtk.Image artPlay;
	public static Gtk.Label year;
	public static Gtk.Label album;
	public static Gtk.Label artist;
	public static Gtk.Label total;
	public static Gtk.ScrolledWindow scrollList;
	public static Gtk.TreeStore tree_store;
	public static Gtk.TreeView tree;
	public static Gtk.TreeIter itera;
	public static Gtk.TreeIter itert;
	public static uint currp;
	public static uint currc;

	public static void cmd_art () {
		if (current_status () != Mpd.State.STOP) {
			var conn = get_conn ();
			Mpd.Song song = conn.run_current_song ();
			var albumArt = cmd_arts (song, 400);
			artPlay.set_from_pixbuf (albumArt);

			year.set_text (song.get_tag (Mpd.TagType.DATE));
			album.set_text (song.get_tag (Mpd.TagType.ALBUM));
			artist.set_text (song.get_tag (Mpd.TagType.ARTIST));

			Mpd.Song songs;
			conn.search_db_songs (true);
			conn.search_add_tag_constraint (Mpd.Operator.DEFAULT, Mpd.TagType.ARTIST, song.get_tag (Mpd.TagType.ARTIST));
			conn.search_add_tag_constraint (Mpd.Operator.DEFAULT, Mpd.TagType.ALBUM, song.get_tag (Mpd.TagType.ALBUM));
			conn.search_commit ();
			uint tot = 0;
			while ((songs = conn.recv_song ()) != null) {
				tot += songs.get_duration ();
			}
			total.set_text (to_minutes (tot));
		}
	}

	public static void cmd_playls () {
		var conn = get_conn ();
		Mpd.Song song;
		conn.send_list_queue_meta ();
		tree_store.clear ();
		string album = null;
		while ((song = conn.recv_song ()) != null) {
			uint pos = song.get_pos ();
			string track = song.get_tag (Mpd.TagType.TRACK);
			if (track == null) {
				track = "0";
			} else if (track.contains ("/")) {
				track = track.substring (0, track.index_of ("/", 0));
			}
			//track = int.parse(trackn);
			string title = song.get_tag (Mpd.TagType.TITLE);
			string lenght = to_minutes (song.get_duration ());
			if (album == null || song.get_tag (Mpd.TagType.ALBUM) != album) {
				album = song.get_tag (Mpd.TagType.ALBUM);
				string year = song.get_tag (Mpd.TagType.DATE);
				year = ((year == null ) ? "0000" : year.substring (0, 4));
				tree_store.append (out itera, null);
				tree_store.set (itera, 0, pos, 1, year, 2, album);
			}
			tree_store.append (out itert, itera);
			tree_store.set (itert, 0, pos, 1, track, 2, title, 3, lenght);
		}
		cmd_psel();
		tree.row_activated.connect (on_row_activated);
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
			Controls.buttonToggle.set_image (image);
			cmd_art ();
		}
	}

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

	public static void cmd_move (Gtk.TreeSelection selection) {
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
				conn.run_move_range (pos0, pos1, 0);
			} else {
				conn.run_move (pos, 0);
			}
			cmd_playls ();
		}
	}

	public static void cmd_last (Gtk.TreeSelection selection) {
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
				uint total = -1;
				while ((song = conn.recv_song ()) != null) {
					if (song.get_tag (Mpd.TagType.ALBUM) == title) {
						if (pos0 == -1) {
							pos0 = song.get_pos ();
						}
						pos1 = song.get_pos ();
					}
					total++;
				}
				total = total - (pos1 - pos0);
				pos1++;
				stdout.printf ("%s\n", total.to_string());
				conn.run_move_range (pos0, pos1, total);
			} else {
				conn.run_move (pos, 0);
			}
			cmd_playls ();
		}
	}

	public Playlist() {
		set_border_width (20);
		set_column_homogeneous (true);
		set_vexpand (true);
		set_valign (Gtk.Align.CENTER);

		var lgrid = new Gtk.Grid ();
		//grid.orientation = Gtk.Orientation.VERTICAL;
		lgrid.set_valign (Gtk.Align.CENTER);
		lgrid.set_halign (Gtk.Align.CENTER);
		lgrid.column_spacing = 20;
		lgrid.row_spacing = 10;
		lgrid.set_border_width (20);
		attach (lgrid, 0, 0, 1, 1);

		artPlay = new Gtk.Image ();
		artPlay.set_halign (Gtk.Align.CENTER);
		artPlay.get_style_context ().add_class ("art");
		lgrid.attach (artPlay, 0, 0, 3, 1);

		year = new Gtk.Label ("Year");
		year.set_valign (Gtk.Align.CENTER);
		year.set_margin_start (20);
		lgrid.attach (year, 0, 1, 1, 2);

		album = new Gtk.Label ("Album");
		album.set_hexpand (true);
		album.set_valign (Gtk.Align.CENTER);
		album.ellipsize = Pango.EllipsizeMode.END;
		album.get_style_context ().add_class ("h1");
		lgrid.attach (album, 1, 1, 1, 1);

		artist = new Gtk.Label ("Artist");
		artist.set_valign (Gtk.Align.CENTER);
		artist.ellipsize = Pango.EllipsizeMode.END;
		artist.get_style_context ().add_class ("h2");
		artist.set_opacity (0.8);
		lgrid.attach (artist, 1, 2, 1, 1);

		total = new Gtk.Label ("Total");
		total.set_valign (Gtk.Align.CENTER);
		total.set_margin_end (20);
		lgrid.attach (total, 2, 1, 1, 2);

		cmd_art ();

		//attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 1, 0, 1, 1 );

		var pgrid = new Gtk.Grid ();
		pgrid.height_request = 500;
		pgrid.width_request = 500;
		pgrid.set_valign (Gtk.Align.CENTER);
		attach (pgrid, 1, 0, 1, 1);

		pgrid.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 0, 0, 1, 4 );
		pgrid.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 2, 0, 1, 4 );

		pgrid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 1, 0, 1, 1 );

		scrollList = new Gtk.ScrolledWindow (null, null);
		scrollList.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

		tree_store = new Gtk.TreeStore (4, typeof (uint), typeof (string), typeof (string), typeof (string));

		tree = new Gtk.TreeView.with_model (tree_store);
		tree.set_vexpand (true);
		//tree.set_show_expanders (false);
		tree.set_headers_visible (false);
		scrollList.add (tree);
		pgrid.attach (scrollList, 1, 1, 1, 1);

		Gtk.CellRendererText celln = new Gtk.CellRendererText ();
		Gtk.CellRendererText cellt = new Gtk.CellRendererText ();
		celln.xalign = 1;
		celln.xpad = 10;
		celln.ypad = 5;
		cellt.ellipsize = Pango.EllipsizeMode.END;
		tree.insert_column_with_attributes (-1, "#", celln, "text", 1);
		//tree.insert_column_with_attributes (-1, "Title", cellt, "text", 2);
		var column = new Gtk.TreeViewColumn.with_attributes ("Title", cellt, "text", 2);
		column.set_expand (true);
		tree.insert_column (column, 2);
		tree.insert_column_with_attributes (-1, "Lenght", celln, "text", 3);

		cmd_playls ();

		var actionbar = new Gtk.ActionBar ();
		actionbar.set_hexpand (true);
		//actionbar.set_margin_top(0);
		pgrid.attach (actionbar, 1, 2, 1, 1);

		pgrid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 1, 3, 1, 1 );

		var plbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		plbox.get_style_context ().add_class ("linked");
		actionbar.pack_start (plbox);
		var up = new Gtk.Button.from_icon_name ("go-up-symbolic", Gtk.IconSize.MENU);
		up.clicked.connect (() => {
			var selection = tree.get_selection ();
			cmd_move (selection);
		});
		plbox.pack_start (up);
		var remove = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.MENU);
		remove.clicked.connect (() => {
			var selection = tree.get_selection ();
			cmd_delete (selection);
		});
		plbox.pack_start (remove);
		var down = new Gtk.Button.from_icon_name ("go-down-symbolic", Gtk.IconSize.MENU);
		down.clicked.connect (() => {
			var selection = tree.get_selection ();
			cmd_last (selection);
		});
		plbox.pack_start (down);
		var clear = new Gtk.Button.from_icon_name ("list-remove-all-symbolic", Gtk.IconSize.MENU);
		clear.get_style_context ().add_class ("circular");
		clear.clicked.connect (() => {
			var conn = get_conn ();
			conn.run_clear ();
		});
		actionbar.pack_end (clear);

		show_all ();
	}
}
