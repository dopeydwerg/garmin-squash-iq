using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Communications as Comm;

class PauseView extends Ui.View {

    //! Constuctor
    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {

    }
}

class pauseViewDelegate extends Ui.BehaviorDelegate {

    //! Constructor
    function initialize() {
        BehaviorDelegate.initialize();
    }
}