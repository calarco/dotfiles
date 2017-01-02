public class Database : Gtk.Grid {
	private static Gtk.Grid grid;
	private static Gtk.Stack stack;
	private static Gtk.StackSidebar sidebar;
	private static Gtk.ScrolledWindow scrollTree;

	private static Gtk.Grid list;

	private static int cmpfunc (ref string x, ref string y) {
		return Posix.strcoll (x, y);
	}

	public static void cmd_dbartists () {
		var conn = get_conn ();
		Mpd.Pair pair;
		var artists = new string[] {};
		string artist;
		conn.search_db_tags (Mpd.TagType.ARTIST);
		conn.search_commit ();
		while ((pair = conn.recv_pair_tag (Mpd.TagType.ARTIST)) != null) {
			if ((artist = pair.value) != "\0") {
				artists += artist;
			}
			conn.return_pair (pair);
		}
		Posix.qsort (artists, artists.length, sizeof (string), (Posix.compar_fn_t) cmpfunc);
		foreach (string item in artists) {
			var grid = new Gtk.Grid ();
			grid.orientation = Gtk.Orientation.VERTICAL;
			grid.set_hexpand (true);

			var label = new Gtk.Label (item);
			label.set_halign (Gtk.Align.START);
			label.set_margin_top (10);
			label.set_margin_bottom (10);
			label.set_margin_start (20);
			label.get_style_context ().add_class ("h1");
			grid.add (label);
			grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

			stack.add_titled (grid, item, item);

			label.realize.connect (album_realize);
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
		scrollTree.add (asgrid);

		string artist = stack.get_visible_child_name ();

		Mpd.Pair pair;
		var albums = new string[] {};
		string albuma;
		conn.search_db_tags (Mpd.TagType.ALBUM);
		conn.search_add_tag_constraint (Mpd.Operator.DEFAULT, Mpd.TagType.ARTIST, artist);
		conn.search_commit ();
		while ((pair = conn.recv_pair_tag (Mpd.TagType.ALBUM)) != null) {
			if ((albuma = pair.value) != "\0") {
				stdout.printf ("%s\n", albuma);
				albums += albuma;
			}
			conn.return_pair (pair);
		}
		foreach (string item in albums) {
			var agrid = new Gtk.Grid ();
			asgrid.add (agrid);
			asgrid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

			var argrid = new Gtk.Grid ();
			agrid.attach (argrid, 0, 0, 1, 3);
			agrid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 1, 0, 1, 3);

			Gdk.Pixbuf albumArt = null;
			var art = new Gtk.Image ();
			art.set_valign (Gtk.Align.START);
			art.set_halign (Gtk.Align.CENTER);
			argrid.attach (art, 0, 0, 2, 1);

			argrid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1, 2, 1);

			var add = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU);
			add.set_label (item);
			add.set_always_show_image (true);
			add.get_style_context ().add_class ("hide_label");
			add.set_margin_top (10);
			add.set_margin_bottom (10);
			add.set_margin_start (10);
			add.set_margin_end (10);
			add.clicked.connect (add_album);
			argrid.attach (add, 0, 2, 1, 1);

			var play = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);
			play.set_margin_top (10);
			play.set_margin_bottom (10);
			play.set_margin_start (10);
			play.set_margin_end (10);
			argrid.attach (play, 1, 2, 1, 1);

			var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
			box.set_margin_top (10);
			box.set_margin_bottom (10);
			box.set_margin_start (10);
			box.set_margin_end (10);

			string year = "year";
			var hlabel = new Gtk.Label (year + " | " + item);
			hlabel.ellipsize = Pango.EllipsizeMode.END;
			hlabel.set_valign (Gtk.Align.START);
			hlabel.set_halign (Gtk.Align.START);
			hlabel.get_style_context ().add_class ("h1");
			box.pack_start (hlabel);

			uint total = 0;
			var tlabel = new Gtk.Label ("total");
			tlabel.ellipsize = Pango.EllipsizeMode.END;
			tlabel.set_valign (Gtk.Align.START);
			tlabel.set_halign (Gtk.Align.END);
			tlabel.get_style_context ().add_class ("h1");
			box.pack_end (tlabel);
			agrid.attach (box, 2, 0, 1, 1);

			list = new Gtk.Grid ();
			list.orientation = Gtk.Orientation.VERTICAL;
			list.set_vexpand (true);
			list.set_hexpand (true);
			list.column_spacing = 10;
			list.row_spacing = 10;
			list.set_margin_top (10);
			list.set_margin_bottom (10);
			list.set_margin_start (20);
			list.set_margin_end (20);
			agrid.attach (list, 2, 2, 1, 1);

			Mpd.Song song;
			conn.search_db_songs (true);
			conn.search_add_tag_constraint (Mpd.Operator.DEFAULT, Mpd.TagType.ARTIST, artist);
			conn.search_add_tag_constraint (Mpd.Operator.DEFAULT, Mpd.TagType.ALBUM, item);
			conn.search_commit ();
			while ((song = conn.recv_song ()) != null) {
				string track = song.get_tag (Mpd.TagType.TRACK);
				if (track == null) {
					track = "0";
				} else if (track.contains ("/")) {
					track = track.substring (0, track.index_of ("/", 0));
				}
				string title = song.get_tag (Mpd.TagType.TITLE);
				string lenght = to_minutes (song.get_duration ());
				total += song.get_duration ();

				var box1 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
				box1.set_halign (Gtk.Align.START);
				box1.set_hexpand (true);
				var nlabel = new Gtk.Label (track);
				var tlabel1 = new Gtk.Label (title);
				var llabel = new Gtk.Label (lenght);
				nlabel.set_halign (Gtk.Align.START);
				tlabel1.set_halign (Gtk.Align.START);
				tlabel1.set_hexpand (true);
				tlabel1.ellipsize = Pango.EllipsizeMode.END;
				llabel.set_halign (Gtk.Align.END);
				box1.pack_start (nlabel);
				box1.set_center_widget (tlabel1);
				box1.pack_end (llabel);
				list.add (box1);
				if (albumArt == null) {
					albumArt = cmd_arts (song, 250);
					art.set_from_pixbuf (albumArt);
				}
				if (year == "year") {
					year = song.get_tag (Mpd.TagType.DATE);
					year = ((year == null ) ? "0000" : year.substring (0, 4));
					hlabel.set_label (year + " | " + item);
				}
			}
			tlabel.set_label (to_minutes (total));
		}
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

	public static void reset () {
		string current = stack.get_visible_child_name ();
		stack.destroy ();
		stack = new Gtk.Stack ();
		cmd_dbartists ();
		stack.show_all ();
		stack.set_visible_child_name (current);

		sidebar.destroy ();
		sidebar = new Gtk.StackSidebar ();
		sidebar.set_stack (stack);
		sidebar.show_all ();
		//stack.hide ();
		//stack.foreach ((element) => stack.remove (element));
		grid.add (sidebar);
		grid.add (stack);
		//sidebar.set_stack (stack);
		//Application.database.destroy ();
		//Application.database = new Database ();
		//Application.main_stack.add_titled (Application.database, "database", "Database");
	}

	public Database() {
		grid = new Gtk.Grid ();
		grid.orientation = Gtk.Orientation.HORIZONTAL;
		add (grid);

		stack = new Gtk.Stack ();
		stack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
		cmd_dbartists ();

		sidebar = new Gtk.StackSidebar ();
		sidebar.set_stack (stack);

		orientation = Gtk.Orientation.HORIZONTAL;
		grid.add (sidebar);
		grid.add (stack);

		show_all ();
	}
}
