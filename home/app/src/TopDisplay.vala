public class TopDisplay : Gtk.Grid {
	Gtk.Label label;
	Gtk.Grid scale_grid;
	Gtk.Label leftTime;
	Gtk.Label rightTime;
	Gtk.Scale scale;

	public TopDisplay() {
		width_request = 400;
		column_spacing = 6;

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

		var timeout = GLib.Timeout.add (1000, () => {
			if (current_status () == Mpd.State.PLAY) {
				label.set_text(current_title ());
				progress = (double)current_elapsed () / (double)current_total ();
				scale.adjustment.value = (progress);
			}
			return true;
		});
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
			timeout = GLib.Timeout.add (1000, () => {
				if (current_status () == Mpd.State.PLAY) {
					label.set_text(current_title ());
					progress = (double)current_elapsed () / (double)current_total ();
					scale.adjustment.value = (progress);
				}
				return true;
			});
			return false;
		});

		scale_grid.attach (leftTime, 0, 0, 1, 1);
		scale_grid.attach (scale, 1, 0, 1, 1);
		scale_grid.attach (rightTime, 2, 0, 1, 1);

		var info = new Gtk.Grid ();
		info.attach (label, 0, 0, 1, 1);
		info.attach (scale_grid, 0, 1, 1, 1);
		attach (info, 0, 0, 1, 1);
	}
}
