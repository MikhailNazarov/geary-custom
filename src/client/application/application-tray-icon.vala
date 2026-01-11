/*
 * Copyright 2025 Mikhail Nazarov
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later). See the COPYING file in this distribution.
 */

#if HAVE_APPINDICATOR

/**
 * System tray icon using AppIndicator.
 */
public class Application.TrayIcon : GLib.Object {

    private AppIndicator.Indicator indicator;
    private Gtk.Menu menu;
    private Gtk.MenuItem show_item;
    private Gtk.MenuItem compose_item;
    private Gtk.MenuItem quit_item;

    private weak Application.Client application;
    private int unread_count = 0;

    public TrayIcon(Application.Client app) {
        this.application = app;

        // Create indicator
        this.indicator = new AppIndicator.Indicator(
            "geary-mail",
            "mail-unread",
            AppIndicator.IndicatorCategory.COMMUNICATIONS
        );

        // Build menu
        this.menu = new Gtk.Menu();

        this.show_item = new Gtk.MenuItem.with_label(_("Show Geary"));
        this.show_item.activate.connect(on_show_activate);
        this.menu.append(this.show_item);

        this.compose_item = new Gtk.MenuItem.with_label(_("Compose New Message"));
        this.compose_item.activate.connect(on_compose_activate);
        this.menu.append(this.compose_item);

        this.menu.append(new Gtk.SeparatorMenuItem());

        this.quit_item = new Gtk.MenuItem.with_label(_("Quit"));
        this.quit_item.activate.connect(on_quit_activate);
        this.menu.append(this.quit_item);

        this.menu.show_all();
        this.indicator.set_menu(this.menu);

        // Set initial state
        update_icon();
        this.indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE);
    }

    public void set_unread_count(int count) {
        if (this.unread_count != count) {
            this.unread_count = count;
            update_icon();
        }
    }

    public void show() {
        this.indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE);
    }

    public void hide() {
        this.indicator.set_status(AppIndicator.IndicatorStatus.PASSIVE);
    }

    private void update_icon() {
        if (this.unread_count > 0) {
            this.indicator.set_icon("mail-unread");
            this.indicator.set_label(this.unread_count.to_string(), "");
        } else {
            this.indicator.set_icon("mail-read");
            this.indicator.set_label("", "");
        }
    }

    private void on_show_activate() {
        this.application.activate();
    }

    private void on_compose_activate() {
        this.application.activate_action("compose", null);
    }

    private void on_quit_activate() {
        this.application.quit();
    }
}

#endif
