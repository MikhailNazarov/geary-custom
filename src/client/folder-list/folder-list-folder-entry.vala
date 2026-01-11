/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

// A folder of any type in the folder list.
public class FolderList.FolderEntry :
    FolderList.AbstractFolderEntry,
    Sidebar.InternalDropTargetEntry,
    Sidebar.EmphasizableEntry,
    Sidebar.Contextable {


    private Application.FolderContext context;
    private bool has_new;
    private Gtk.Menu? context_menu = null;


    public FolderEntry(Application.FolderContext context) {
        base(context.folder);
        this.context = context;
        this.context.notify.connect(on_context_changed);
        this.has_new = false;
        this.folder.properties.notify[Geary.FolderProperties.PROP_NAME_EMAIL_TOTAL].connect(on_counts_changed);
        this.folder.properties.notify[Geary.FolderProperties.PROP_NAME_EMAIL_UNREAD].connect(on_counts_changed);
    }

    ~FolderEntry() {
        this.context.notify.disconnect(on_context_changed);
        this.folder.properties.notify[Geary.FolderProperties.PROP_NAME_EMAIL_TOTAL].disconnect(on_counts_changed);
        this.folder.properties.notify[Geary.FolderProperties.PROP_NAME_EMAIL_UNREAD].disconnect(on_counts_changed);
    }

    public override string get_sidebar_name() {
        return this.context.display_name;
    }

    public override string? get_sidebar_tooltip() {
        // Translators: Label displaying total number of email
        // messages in a folder. String substitution is the actual
        // number.
        string total_msg = ngettext(
            "%d message", "%d messages", folder.properties.email_total
        ).printf(folder.properties.email_total);

        if (folder.properties.email_unread == 0)
            return total_msg;

        // Translators: Label displaying number of unread email
        // messages in a folder. String substitution is the actual
        // number.
        string unread_msg = ngettext(
            "%d unread", "%d unread", folder.properties.email_unread
        ).printf(folder.properties.email_unread);

        // Translators: This string represents the divider between two
        // messages: "n messages" and "n unread", shown in the folder
        // list as a tooltip.  Please use your languages conventions
        // for combining the two, i.e. a comma (",") for English; "6
        // messages, 3 unread"
        return _("%s, %s").printf(total_msg, unread_msg);
    }

    public override string? get_sidebar_icon() {
        return this.context.icon_name;
    }

    public override string to_string() {
        return "FolderEntry: " + get_sidebar_name();
    }

    public bool is_emphasized() {
        return has_new;
    }

    public void set_has_new(bool has_new) {
        if (this.has_new == has_new)
            return;

        this.has_new = has_new;
        entry_changed();
    }

    public bool internal_drop_received(Sidebar.Tree parent,
                                       Gdk.DragContext context,
                                       Gtk.SelectionData data) {
        var handled = false;
        var folders = parent as FolderList.Tree;
        if (folders != null) {
            switch (context.get_selected_action()) {
            case MOVE:
                folders.move_conversation(folder);
                handled = true;
                break;

            case COPY:
                folders.copy_conversation(folder);
                handled = true;
                break;

            default:
                // noop
                break;
            }
        }
        return handled;
    }

    public override int get_count() {
        switch (this.context.displayed_count) {
        case TOTAL:
            return folder.properties.email_total;

        case UNREAD:
            return folder.properties.email_unread;

        default:
            return 0;
        }
    }

    private void on_counts_changed() {
        entry_changed();
    }

    private void on_context_changed() {
        entry_changed();
    }

    public Gtk.Menu? get_sidebar_context_menu(Gdk.EventButton event) {
        if (this.context_menu == null) {
            this.context_menu = new Gtk.Menu();

            var mark_read_item = new Gtk.MenuItem.with_label(_("Mark All as Read"));
            mark_read_item.activate.connect(on_mark_all_read);
            this.context_menu.append(mark_read_item);

            this.context_menu.show_all();
        }
        return this.context_menu;
    }

    private void on_mark_all_read() {
        var dominated_folder = this.folder as Geary.FolderSupport.Mark;
        if (dominated_folder == null) {
            return;
        }

        var app = GLib.Application.get_default() as Application.Client;
        if (app != null && app.controller != null) {
            app.controller.mark_folder_read.begin(this.folder, (obj, res) => {
                try {
                    app.controller.mark_folder_read.end(res);
                } catch (GLib.Error err) {
                    warning("Failed to mark folder as read: %s", err.message);
                }
            });
        }
    }

}
