public class Controls : Gtk.ActionBar {
	public static Gtk.Button buttonToggle;
	public static Gtk.Label label;
	public static Gtk.Grid scale_grid;
	public static Gtk.Label leftTime;
	public static Gtk.Label rightTime;
	public static Gtk.Scale scale;
	public static double progress;
	public static string album;
	public static string title;

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

	private static bool update_scale () {
		if (current_status () == Mpd.State.PLAY) {
			progress = (double)current_elapsed () / (double)current_total ();
			scale.adjustment.value = (progress);
			var conn = get_conn ();
			Mpd.Song song = conn.run_current_song ();
			if (song.get_tag (Mpd.TagType.TITLE) != title) {
				label.set_text(current_title ());
				Playlist.cmd_psel ();
				title = song.get_tag (Mpd.TagType.TITLE);
				if (song.get_tag (Mpd.TagType.ALBUM) != album) {
					Playlist.cmd_art();
					album = song.get_tag (Mpd.TagType.ALBUM);
				}
			}
		}
		return true;
	}

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
			Playlist.cmd_art ();
			Playlist.cmd_psel();
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
		Playlist.cmd_art ();
		Playlist.cmd_psel();
	}

	public Controls() {
		var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		box.get_style_context ().add_class("linked");
		box.set_margin_top (2);
		box.set_margin_bottom (2);
		box.set_margin_start (10);
		box.set_margin_end (10);
		pack_start (box);

		buttonToggle = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);
		buttonToggle.get_style_context ().add_class ("toggle");
		if (current_status () == Mpd.State.PLAY) {
			Gtk.Image image = new Gtk.Image.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.MENU);
			buttonToggle.set_image (image);
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

		var grid = new Gtk.Grid ();
		grid.width_request = 600;
		grid.column_spacing = 6;
		grid.margin_start = 30;
		grid.margin_end = 30;

		label = new Gtk.Label (current_title ());
		label.hexpand = true;
		label.set_justify (Gtk.Justification.CENTER);
		label.set_single_line_mode (false);
		label.ellipsize = Pango.EllipsizeMode.END;

		scale_grid = new Gtk.Grid ();

		leftTime = new Gtk.Label (to_minutes (current_elapsed ()));
		rightTime = new Gtk.Label (to_minutes (current_total ()));
		leftTime.margin_end = rightTime.margin_start = 3;

		scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 1, 0.01);
		scale.set_draw_value (false);
		scale.can_focus = false;
		scale.hexpand = true;
		double progress = (double)current_elapsed () / (double)current_total ();
		scale.adjustment.value = (progress);

		var timeout = GLib.Timeout.add (1000, (GLib.SourceFunc)update_scale);

		scale.value_changed.connect (() => {
			leftTime.set_text (to_minutes (current_elapsed ()));
			rightTime.set_text (to_minutes (current_total ()));
		});
		scale.button_press_event.connect (() => {
			GLib.Source.remove(timeout);
			return false;
		});
		scale.button_release_event.connect (() => {
			double pos = (double)current_total () * scale.adjustment.value;
			cmd_seek ((uint)pos);
			progress = (double)current_elapsed () / (double)current_total ();
			scale.adjustment.value = (progress);
			timeout = GLib.Timeout.add (1000, (GLib.SourceFunc)update_scale);
			return false;
		});

		scale_grid.attach (leftTime, 0, 0, 1, 1);
		scale_grid.attach (scale, 1, 0, 1, 1);
		scale_grid.attach (rightTime, 2, 0, 1, 1);

		var info = new Gtk.Grid ();
		info.attach (label, 0, 0, 1, 1);
		info.attach (scale_grid, 0, 1, 1, 1);
		grid.attach (info, 0, 0, 1, 1);

		var topDisplayBin = new FixedBin (700, -1, 800, -1);
		topDisplayBin.set_widget (grid, true, false);
		topDisplayBin.show_all ();
		if (current_status () == Mpd.State.PLAY || current_status () == Mpd.State.PAUSE) {
			//headerbar.set_custom_title (topDisplayBin);
			set_center_widget (topDisplayBin);
		}
		//actionbar.set_hexpand (false);
		//actionbar.set_margin_top(0);

		show_all ();
	}
}
