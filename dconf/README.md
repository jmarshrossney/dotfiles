# dconf

GNOME settings: `.config/dconf/gnome.ini`.

GNOME reads its settings from dconf's binary database at `~/.config/dconf/user`, not from text files.
Linking `gnome.ini` into place therefore changes nothing on its own.
Apply it to the live database with `just dconf-load` from the repository root, on a new machine or after pulling changes.

## Editing

`gnome.ini` is maintained by hand, and there is deliberately no recipe that writes it back from the live database.
To track a new setting, or pick up a value changed through the Settings app, read the current value and paste it under the matching section:

```sh
dconf read /org/gnome/<section>/<key>
```

Sections are paths relative to `/org/gnome/`, so `[desktop/interface]` means `/org/gnome/desktop/interface`.
