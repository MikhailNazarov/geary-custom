/*
 * Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

private class Geary.ImapEngine.MarkAllAsRead : Geary.ImapEngine.SendReplayOperation {
    private MinimalFolder engine;
    private Cancellable? cancellable;

    public MarkAllAsRead(MinimalFolder engine,
                         GLib.Cancellable? cancellable = null) {
        base("MarkAllAsRead", OnError.RETRY);

        this.engine = engine;
        this.cancellable = cancellable;
    }

    public override async ReplayOperation.Status replay_local_async() throws Error {
        yield engine.local_folder.mark_all_as_read_async(cancellable);
        return ReplayOperation.Status.CONTINUE;
    }

    public override async void replay_remote_async(Imap.FolderSession remote)
        throws GLib.Error {
        // Remove UNREAD flag from all messages (= mark as read)
        Geary.EmailFlags flags_to_remove = new Geary.EmailFlags();
        flags_to_remove.add(Geary.EmailFlags.UNREAD);

        Gee.List<Imap.MessageSet> msg_sets = new Gee.ArrayList<Imap.MessageSet>();
        msg_sets.add(new Imap.MessageSet.uid_range(
            new Imap.UID(Imap.UID.MIN), new Imap.UID(Imap.UID.MAX)
        ));
        yield remote.mark_email_async(
            msg_sets, null, flags_to_remove, cancellable
        );
    }

    public override async void backout_local_async() throws Error {
        // Cannot easily backout mark-all-as-read
    }

    public override string describe_state() {
        return "mark_all_as_read";
    }
}
