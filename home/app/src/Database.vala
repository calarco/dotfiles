public class Database : Gtk.Grid {
	public static Gtk.Stack stack;
	public static Gtk.StackSidebar sidebar;
	private static Gtk.TreeIter iteraa;
	private static Gtk.TreeIter iterat;
	private static Gtk.ScrolledWindow scrollTree;
	private static Gtk.TreeStore album_store;
	private static Gtk.TreeView albums;

	public static void cmd_dbartists () {
		var conn = get_conn ();
		Mpd.Pair pair;
		string artist;
		conn.search_db_tags (Mpd.TagType.ARTIST);
		conn.search_commit ();
		while ((pair = conn.recv_pair_tag (Mpd.TagType.ARTIST)) != null) {
			if ((artist = pair.value) != "\0") {
				cmd_dbalbums (artist);
			}
			conn.return_pair (pair);
		}
	}

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

		Gtk.CellRendererText celln = new Gtk.CellRendererText ();
		Gtk.CellRendererText cellt = new Gtk.CellRendererText ();
		cellt.ellipsize = Pango.EllipsizeMode.END;
		celln.xalign = 1;
		celln.xpad = 10;
		celln.ypad = 5;
		albums.insert_column_with_attributes (-1, "#", celln, "text", 1);
		albums.insert_column_with_attributes (-1, "Title", cellt, "text", 2);
		string album = null;
		while ((song = conn.recv_song ()) != null) {
			string track = song.get_tag (Mpd.TagType.TRACK);
			if (track == null) {
				track = "0";
			} else if (track.contains ("/")) {
				track = track.substring (0, track.index_of ("/", 0));
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
		stack.add_titled (scrollTree, artist, artist);
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
	}
}
