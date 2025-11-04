import St from 'gi://St';
import Gio from 'gi://Gio';
import Clutter from 'gi://Clutter';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as ExtensionUtils from 'resource:///org/gnome/shell/misc/extensionUtils.js';

const FILE_PATH = '/tmp/iksdp_mode';

export default class PersistenceIndicatorExtension {
    constructor() {
        this._indicator = null;
    }

    enable() {
        this._indicator = new PanelMenu.Button(0.0, 'PersistenceIndicator', false);

        const label = new St.Label({
            text: this._readFileContent(FILE_PATH),
            y_align: Clutter.ActorAlign.CENTER,
        });

        this._indicator.add_child(label);
        Main.panel.addToStatusArea('PersistenceIndicator', this._indicator);
    }

    disable() {
        if (this._indicator) {
            this._indicator.destroy();
            this._indicator = null;
        }
    }

    _readFileContent(path) {
        try {
            const file = Gio.File.new_for_path(path);
            const [, contents] = file.load_contents(null);
            return new TextDecoder().decode(contents).trim();
        } catch (e) {
            return 'File not found';
        }
    }
}
