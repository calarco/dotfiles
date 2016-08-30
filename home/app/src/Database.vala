public class Database : Gtk.Grid {
	public static Gtk.Stack stack;
	public static Gtk.StackSidebar sidebar;
	private static Gtk.TreeIter iteraa;
	private static Gtk.TreeIter iterat;
	private static Gtk.ScrolledWindow scrollTree;
	private static Gtk.TreeStore album_store;
	private static Gtk.TreeView albums;

	private static Gtk.Grid list;

	public static void cmd_dbartists () {
		var conn = get_conn ();
		Mpd.Pair pair;
		string artist;
		conn.search_db_tags (Mpd.TagType.ARTIST);
		conn.search_commit ();
		while ((pair = conn.recv_pair_tag (Mpd.TagType.ARTIST)) != null) {
			if ((artist = pair.value) != "\0") {
				var grid = new Gtk.Grid ();
				grid.orientation = Gtk.Orientation.VERTICAL;
				grid.set_hexpand (true);

				var label = new Gtk.Label (artist);
				label.set_halign (Gtk.Align.START);
				label.set_margin_top (10);
				label.set_margin_bottom (10);
				label.set_margin_start (20);
				label.get_style_context ().add_class ("h1");
				grid.add (label);
				grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

				stack.add_titled (grid, artist, artist);

				label.realize.connect (album_realize);
			}
			conn.return_pair (pair);
		}
	}

	private static void album_realize (Gtk.Widget widget) {
		var conn = get_conn ();

		scrollTree = new Gtk.ScrolledWindow (null, null);
		scrollTree.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		scrollTree.set_hexpand (true);
		scrollTree.set_vexpand (true);

		var asgrid = new Gtk.Grid ();
		asgrid.orientation = Gtk.Orientation.VERTICAL;
		asgrid.column_spacing = 20;
		asgrid.row_spacing = 20;
		scrollTree.add (asgrid);

		album_store = new Gtk.TreeStore (3, typeof (string), typeof (string), typeof (string));

		albums = new Gtk.TreeView.with_model (album_store);
		albums.set_vexpand (true);
		albums.set_hexpand (true);
		albums.set_grid_lines (Gtk.TreeViewGridLines.VERTICAL);

		Gtk.CellRendererText celln = new Gtk.CellRendererText ();
		Gtk.CellRendererText cellt = new Gtk.CellRendererText ();
		cellt.ellipsize = Pango.EllipsizeMode.END;
		celln.xalign = 1;
		celln.xpad = 10;
		celln.ypad = 5;
		albums.insert_column_with_attributes (-1, "#", celln, "text", 1);
		albums.insert_column_with_attributes (-1, "Title", cellt, "text", 2);

		string artist = stack.get_visible_child_name ();
		Mpd.Song song;
		conn.search_db_songs (true);
		conn.search_add_tag_constraint (Mpd.Operator.DEFAULT, Mpd.TagType.ARTIST, artist);
		conn.search_commit ();
		string album = null;
		while ((song = conn.recv_song ()) != null) {
			string track = song.get_tag (Mpd.TagType.TRACK);
			if (track == null) {
				track = "0";
			} else if (track.contains ("/")) {
				track = track.substring (0, track.index_of ("/", 0));
			}
			string title = song.get_tag (Mpd.TagType.TITLE);
			string lenght = to_minutes (song.get_duration ());
			string file = song.get_uri ();

			if (album == null || song.get_tag (Mpd.TagType.ALBUM) != album) {
				album = song.get_tag (Mpd.TagType.ALBUM);
				string year = song.get_tag (Mpd.TagType.DATE);
				year = ((year == null ) ? "0000" : year.substring (0, 4));

				var agrid = new Gtk.Grid ();
				agrid.row_spacing = 10;
				agrid.column_spacing = 20;
				agrid.set_border_width (20);
				asgrid.add (agrid);
				asgrid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

				var argrid = new Gtk.Grid ();
				agrid.attach (argrid, 0, 0, 1, 3);

				var albumArt = cmd_arts (song, 250);
				var art = new Gtk.Image ();
				art.set_from_pixbuf (albumArt);
				art.set_valign (Gtk.Align.START);
				art.set_halign (Gtk.Align.CENTER);
				art.get_style_context ().add_class ("art");
				argrid.attach (art, 0, 0, 2, 1);

				var add = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU);
				add.set_label (album);
				add.set_always_show_image (true);
				add.get_style_context ().add_class ("hide_label");
				add.set_margin_start (10);
				add.set_margin_end (10);
				add.clicked.connect (add_album);
				argrid.attach (add, 0, 1, 1, 1);

				var play = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);
				play.set_margin_start (10);
				play.set_margin_end (10);
				argrid.attach (play, 1, 1, 1, 1);

				string head = year + " | " + album;
				var label = new Gtk.Label (head);
				label.ellipsize = Pango.EllipsizeMode.END;
				label.set_valign (Gtk.Align.START);
				label.set_halign (Gtk.Align.START);
				label.get_style_context ().add_class ("h1");
				agrid.attach (label, 1, 0, 1, 1);

				list = new Gtk.Grid ();
				list.orientation = Gtk.Orientation.VERTICAL;
				list.set_vexpand (true);
				list.set_hexpand (true);
				list.column_spacing = 10;
				list.row_spacing = 10;
				agrid.attach (list, 1, 2, 1, 1);

				album_store.append (out iteraa, null);
				album_store.set (iteraa, 0, "album", 1, year, 2, album);
			}
			var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
			box.set_halign (Gtk.Align.START);
			box.set_hexpand (true);
			var nlabel = new Gtk.Label (track);
			var tlabel = new Gtk.Label (title);
			var llabel = new Gtk.Label (lenght);
			nlabel.set_halign (Gtk.Align.START);
			tlabel.set_halign (Gtk.Align.START);
			tlabel.set_hexpand (true);
			llabel.set_halign (Gtk.Align.END);
			box.pack_start (nlabel);
			box.set_center_widget (tlabel);
			box.pack_end (llabel);
			list.add (box);

			album_store.append (out iterat, iteraa);
			album_store.set (iterat, 0, file, 1, track, 2, title);
		}
		albums.expand_all ();
		albums.row_activated.connect (on_row_album);
		widget.get_parent ().add (scrollTree);
		scrollTree.show_all ();
	}

	private static void add_album (Gtk.Button button) {
		var conn = get_conn ();
		string artist = stack.get_visible_child_name ();
		string album = button.get_label ();
		conn.search_add_db_songs (true);
		conn.search_add_tag_constraint(Mpd.Operator.DEFAULT, Mpd.TagType.ARTIST, artist);
		conn.search_add_tag_constraint(Mpd.Operator.DEFAULT, Mpd.TagType.ALBUM, album);
		conn.search_commit ();
		Playlist.cmd_playls ();
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
			conn.search_add_db_songs (true);
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
			Playlist.cmd_playls ();
		}
	}

	public Database() {
		stack = new Gtk.Stack ();
		stack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
		cmd_dbartists ();

		sidebar = new Gtk.StackSidebar ();
		sidebar.set_stack (stack);

		orientation = Gtk.Orientation.HORIZONTAL;
		add (sidebar);
		add (stack);

		show_all ();
	}
}
