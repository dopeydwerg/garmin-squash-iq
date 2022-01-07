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
    var pointsToPlay = 11;
    var gamesToPlay = 5;
    var matchType = 0;

    function fetchSettings() {
        showClock = getProperty("show_clock");
        switchBottomInfo = getProperty("switchable_bottom_info");
        accentColor = getProperty("accent_color");
        pointsToPlay = getProperty("points_to_play");
        gamesToPlay = getProperty("games_to_play");
        matchType = getProperty("match_type");
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