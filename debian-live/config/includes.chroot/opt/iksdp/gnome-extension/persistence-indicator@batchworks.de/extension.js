// vim: set sw=4 sts=4 et:
// -*- mode: js; js-indent-level: 4; indent-tabs-mode: nil -*-

const Clutter = imports.gi.Clutter;
const GObject = imports.gi.GObject;
const Shell = imports.gi.Shell;
const St = imports.gi.St;

const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;

function getFileContent(filePath) {
    try {
        return Shell.get_file_contents_utf8_sync(filePath).trim();
    } catch (e) {
        log(`Error reading file '${filePath}': ${e.message}`);
        return 'File not found';
    }
}

let FileContentButton = GObject.registerClass(
class FileContentButton extends PanelMenu.Button {
    _init() {
        super._init(0.0, 'File Content Indicator');

        let content = getFileContent('/tmp/iksdp_mode');

        let label = new St.Label({
            text: content,
            y_expand: true,
            y_align: Clutter.ActorAlign.CENTER
        });
        this.add_actor(label);
    }
});

let fileContentIndicatorButton;

function enable() {
    fileContentIndicatorButton = new FileContentButton();
    Main.panel.addToStatusArea('file-content-indicator', fileContentIndicatorButton);
}

function disable() {
    fileContentIndicatorButton.destroy();
}

