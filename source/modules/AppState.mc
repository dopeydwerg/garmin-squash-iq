using Toybox.Application as App;

module AppState {

    //! App changeable settings
    var showGameInfo = false;

    //! User changeable Settings
    var showClock = true;
    var switchBottomInfo = true;
    var accentColor = 0xFF5500;
    var opponentName = "Opp";
    var opponentId = 0;

    function fetchSettings() {
        showClock = getProperty("show_clock");
        switchBottomInfo = getProperty("switchable_bottom_info");
        accentColor = getProperty("accent_color");
    }

    function getProperty(key) {
        return App.getApp().getProperty(key);
    }

    function saveProperty(key, value) {
        App.getApp().setProperty(key, value);
    }

    function init() {
        fetchSettings();
    }
}