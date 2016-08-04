public class FixedBin : Gtk.EventBox {
	// Size constraints. Use a negative value to mean "unset".
	public int max_width  { get; private set; default = -1; }
	public int max_height { get; private set; default = -1; }
	public int min_width  { get; private set; default = -1; }
	public int min_height { get; private set; default = -1; }

	public FixedBin (int min_width = -1, int min_height = -1,
					int max_width = -1, int max_height = -1,
					bool visible_window = false) {
		set_min_dimensions (min_width, min_height);
		set_max_dimensions (max_width, max_height);

		this.visible_window = visible_window;

		halign = Gtk.Align.CENTER;
		valign = Gtk.Align.CENTER;
	}

	/**
	* PUBLIC API
	*/
	public void set_widget (Gtk.Widget widget, bool hexpand = true,
							bool vexpand = true) {
		widget.hexpand = hexpand;
		widget.vexpand = vexpand;

		var child = get_child ();
		if (child != null)
			remove (child);

		add (widget);
	}

	public void set_min_dimensions (int min_width, int min_height) {
		this.min_width = min_width;
		this.min_height = min_height;
		queue_resize ();
	}

	public void set_max_dimensions (int max_width, int max_height) {
		this.max_width = max_width;
		this.max_height = max_height;
		queue_resize ();
	}

	/**
	* INTERNAL GEOMETRY MANAGEMENT
	*/

	public override Gtk.SizeRequestMode get_request_mode () {
		return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
	}

	public override void get_preferred_width (out int minimum_width, out int natural_width) {
		base.get_preferred_width (out minimum_width, out natural_width);

		// We have minimum width set, use it
		if (this.min_width > 0)
			minimum_width = this.min_width;
		// We have maximum width set, use it
		if (this.max_width > 0)
			natural_width = this.max_width;
	}

	public override void get_preferred_height_for_width (int width, out int minimum_height,
														out int natural_height) {
		base.get_preferred_height_for_width (width, out minimum_height, out natural_height);

		// We have minimum height set, use it
		if (this.min_height > 0)
			minimum_height = this.min_height;
		// We have maximum height set, use it
		if (this.max_height > 0)
			natural_height = this.max_height;
	}
}
