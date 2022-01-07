using Toybox.Application as App;
using Toybox.ActivityMonitor as Act;
using Toybox.Activity as Acty;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Attention as Attention;
using Toybox.Lang;
using Toybox.Timer as Timer;
using Toybox.Sensor as Sensor;
using Toybox.Application.Storage as Storage;
using Toybox.Math as Mt;

var playerBtnDimensions;

class MatchViewFocus extends Ui.View {

    //! Vertical place in the screen where we start
    //! drawing. In round watches we should leave
    //! some initial vertical space.
    hidden var initialY;
    hidden var segmentHeight;
    hidden var currentHR;
    hidden var elapsedTime = "00:00";
    hidden const textCenter = Gfx.TEXT_JUSTIFY_CENTER;
    hidden const STATS_LABEL_FONT = Gfx.FONT_TINY;
    hidden const STATS_VALUE_FONT = Gfx.FONT_NUMBER_MILD;

    //! Array of 2 buttons containing the player 1 and player 2
    //! buttons
    hidden var playerButtons;

    function initialize() {
        View.initialize();
        Sys.println("Initialized MatchViewFocus" );

        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        Sensor.enableSensorEvents(method(:onSensor));
    }

    function onShow() {
        if ($.match.isStarted()) {
            if ($.match.getCurrentGame().getWinner()) {
                Ui.switchToView(new GameResultView(), new GameResultViewDelegate(), Ui.SLIDE_IMMEDIATE);
            }
        }
    }

    function onLayout(dc) {
        Sys.println("Onlayout");
        initialY = AppConstants.EXTRA_VERTICAL_SPACING;

        segmentHeight = (dc.getHeight() - (initialY * 2) - (AppConstants.HORIZONTAL_SPACING * 2)) / 3;

        if ($.match.isStarted()) {
            setUpPlayerButtons(dc);
        } else {
            setupStartMatchButton(dc);
        }
    }

    function setupStartMatchButton(dc) {
        var options = {
            :locx => 0,
            :locY => dc.getHeight() / 3,
            :width => dc.getWidth(),
            :height => dc.getHeight() / 3,
            :behavior => :onStartMatch,
            :stateHighlighted => Gfx.COLOR_RED,
            :stateDefault => Gfx.COLOR_WHITE
        };

        var button = new Ui.Button(options);
        setLayout([button]);
    }

    function setUpPlayerButtons(dc) {
        var widthButton = (dc.getWidth() - AppConstants.VERTICAL_SPACING) / 2;

        var options = {
            :locx => 0,
            :locY => dc.getHeight() / 3,
            :width => widthButton,
            :height => dc.getHeight() / 3,
            :behavior => :onPlayer1,
            :stateHighlighted => Gfx.COLOR_RED,
            :stateDefault => Gfx.COLOR_WHITE
        };

        playerButtons = new [2];
        playerButtons[0] = new Ui.Button(options);

        options.put(:locX, dc.getWidth() / 2 + AppConstants.VERTICAL_SPACING);
        options.put(:behavior, :onPlayer2);
        playerButtons[1] = new Ui.Button(options);

        setPlayerButtonColors();

        setLayout(playerButtons);
    }

        //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        setPlayerButtonColors();
        View.onUpdate(dc);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.setPenWidth(2);
        // Do datatracker stuff in here

        var x = dc.getWidth() / 2 - AppConstants.HORIZONTAL_SPACING;
        var y = initialY;

        // First segment
        drawHeartRate(dc, ScreenRegion.TOP_LEFT);
        dc.drawLine(dc.getWidth() / 2, 0, dc.getWidth() / 2, dc.getHeight() / 3);
        drawCalories(dc, ScreenRegion.TOP_RIGHT);
        // Second segment
        y = y + AppConstants.VERTICAL_SPACING + segmentHeight;
        if ($.match.isStarted()) {
            var serveInfo = $.match.getCurrentServerInfo();
            var game = $.match.getCurrentGame();
            elapsedTime = AppState.showGameInfo ? game.getElapsedTime() : Helpers.formatDuration($.match.getDuration());
            drawPlayerButton(dc, x, y, "YOU", game.getScore(:player_1), $.match.getGamesWon(:player_1), Gfx.TEXT_JUSTIFY_RIGHT, serveInfo[:server] == :player_1 ? serveInfo[:serve] : null);
            x = dc.getWidth() / 2 + AppConstants.HORIZONTAL_SPACING;
            drawPlayerButton(dc, x, y, "OPP", game.getScore(:player_2), $.match.getGamesWon(:player_2), Gfx.TEXT_JUSTIFY_LEFT, serveInfo[:server] == :player_2 ? serveInfo[:serve] : null);
        } else {
            elapsedTime = Helpers.formatDuration($.match.getDuration());
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, y, Gfx.FONT_SMALL, "Warming Up!!", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(x, initialY + AppConstants.VERTICAL_SPACING + (segmentHeight * 2) - dc.getFontHeight(Gfx.FONT_SMALL), Gfx.FONT_SMALL, "Press to Start!", Gfx.TEXT_JUSTIFY_CENTER);
        }

        // Third segment
        y = y + AppConstants.VERTICAL_SPACING + segmentHeight + AppConstants.HORIZONTAL_SPACING;
        //dc.drawLine(0, y, dc.getWidth(), y);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        drawBottomLeft(dc);
        dc.drawLine(dc.getWidth() / 2, dc.getHeight() / 3 * 2 - 6, dc.getWidth() / 2, dc.getHeight());
        drawBottomRight(dc);
        y = y + (AppConstants.VERTICAL_SPACING / 2);

        drawClock(dc);
        // Bottom label for Game or Match info
        if (AppState.switchBottomInfo) {
            dc.setColor(AppState.accentColor, Gfx.COLOR_BLACK);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() - Gfx.getFontHeight(Gfx.FONT_XTINY) - 3, Gfx.FONT_XTINY, AppState.showGameInfo ? "GAME" : "MATCH", Gfx.TEXT_JUSTIFY_CENTER);
        }
    }

    function setPlayerButtonColors() {
        if ($.match.isStarted()) {
            var serveInfo = $.match.getCurrentServerInfo();
            if (serveInfo[:server] == :player_1) {
                playerButtons[0].stateDefault = Gfx.COLOR_DK_GREEN;
                playerButtons[1].stateDefault = Gfx.COLOR_WHITE;
            } else {
                playerButtons[1].stateDefault = Gfx.COLOR_DK_GREEN;
                playerButtons[0].stateDefault = Gfx.COLOR_WHITE;
            }
        }
    }

    //! Draws nicely Player 1 or 2 buttons, considering if they are
    //! highlithed or not.
    //! @param dc           Where to draw it
    //! @param label        Label that indicates which player it is
    //! @param score        Score to draw in the button
    //! @param justify      Text justification (e.g. left, right)
    //! @param highlighted  True if the button is highlighted
    hidden function drawPlayerButton(dc, x, y, label, score, games, justify, serveInfo){
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);

        // Server info. Draw concurrent serves in a squashball
        if (serveInfo != null) {
            var serveX = x + (justify == Gfx.TEXT_JUSTIFY_RIGHT ? - dc.getWidth() / 4 : dc.getWidth() / 4) * 1.5;
            dc.fillCircle(serveX , y + 20, 20);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(serveX, y, Gfx.FONT_TINY, serveInfo, Gfx.TEXT_JUSTIFY_CENTER);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        }
        dc.drawText(x, y, Gfx.FONT_TINY, label, justify);
        y = y + dc.getFontHeight(Gfx.FONT_TINY) + AppConstants.VERTICAL_SPACING;
        dc.drawText(x, y, Gfx.FONT_NUMBER_MEDIUM, score, justify);
        x = dc.getWidth() / 4;
        x = justify == Gfx.TEXT_JUSTIFY_RIGHT ? x - 15 : x * 3 + 15;
        dc.drawText(x, y, Gfx.FONT_XTINY, "games", Gfx.TEXT_JUSTIFY_CENTER);
        y = y + (dc.getFontHeight(Gfx.FONT_NUMBER_MILD) - dc.getFontHeight(Gfx.FONT_SMALL)) +  AppConstants.VERTICAL_SPACING;
        dc.drawText(x, y, Gfx.FONT_SMALL, games, Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    }

    function drawClock(dc) {
        if (!AppState.showClock) {
             return;
        }
        var clockTime = Sys.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        dc.setColor(AppState.accentColor, Gfx.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 0, Gfx.FONT_XTINY, timeString, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawHeartRate(dc, position) {
        var justify = getJustifycation(position);
        var x = dc.getWidth() / 2 + (justify == Gfx.TEXT_JUSTIFY_RIGHT ? - AppConstants.HORIZONTAL_SPACING : AppConstants.HORIZONTAL_SPACING);
        var startY = getStartY(position, dc);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, startY, STATS_LABEL_FONT, "HRM", justify);
        startY = dc.getFontHeight(STATS_LABEL_FONT) + AppConstants.VERTICAL_SPACING + AppConstants.EXTRA_VERTICAL_SPACING + (AppState.showClock ? 5 : 0);
        dc.drawText(x, startY, STATS_VALUE_FONT, currentHR, justify);
    }

    function drawCalories(dc, position) {
        var data = $.dataTracker.getCurrentData();
        var justify = getJustifycation(position);
        var x = dc.getWidth() / 2 + (justify == Gfx.TEXT_JUSTIFY_RIGHT ? - AppConstants.HORIZONTAL_SPACING : AppConstants.HORIZONTAL_SPACING);
        var startY = getStartY(position, dc);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, startY, STATS_LABEL_FONT, "CAL", justify);
        startY = dc.getFontHeight(STATS_LABEL_FONT) + AppConstants.VERTICAL_SPACING + AppConstants.EXTRA_VERTICAL_SPACING + (AppState.showClock ? 5 : 0);
        dc.drawText(x, startY, STATS_VALUE_FONT, data[:caloriesBurned], justify);
    }

    function drawBottomLeft(dc) {
        var y = dc.getHeight() - getEndY(ScreenRegion.BOTTOM_LEFT, dc) - Gfx.getFontHeight(STATS_LABEL_FONT);
        var justify = getJustifycation(ScreenRegion.BOTTOM_LEFT);
        var x = dc.getWidth() / 2 - AppConstants.HORIZONTAL_SPACING;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, STATS_LABEL_FONT, "TIME", justify);
        y = y - dc.getFontHeight(STATS_VALUE_FONT) - AppConstants.VERTICAL_SPACING + (AppState.switchBottomInfo ? 15 : 5);
        dc.drawText(x, y, STATS_VALUE_FONT, elapsedTime, justify);
    }

    function drawBottomRight(dc) {
        var y = dc.getHeight() - getEndY(ScreenRegion.BOTTOM_RIGHT, dc) - Gfx.getFontHeight(STATS_LABEL_FONT);
        var justify = getJustifycation(ScreenRegion.BOTTOM_RIGHT);
        var x = dc.getWidth() / 2 + AppConstants.HORIZONTAL_SPACING;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, STATS_LABEL_FONT, "STEPS", justify);
        y = y - dc.getFontHeight(STATS_VALUE_FONT) - AppConstants.VERTICAL_SPACING  + (AppState.switchBottomInfo ? 15 : 5);
        dc.drawText(x, y, STATS_VALUE_FONT, AppState.showGameInfo ? $.match.getCurrentGame().getStepsTaken() : $.dataTracker.getCurrentData()[:stepsTaken], justify);
    }

    function getJustifycation(position) {
        switch (position) {
            case ScreenRegion.TOP_RIGHT:
            case ScreenRegion.BOTTOM_RIGHT:
                return Gfx.TEXT_JUSTIFY_LEFT;
            default:
                return Gfx.TEXT_JUSTIFY_RIGHT;
        }
        return Gfx.TEXT_JUSTIFY_CENTER;
    }

    function getStartY(position, dc) {
        var initialY = (AppState.showClock ? dc.getFontHeight(Gfx.FONT_XTINY) : AppConstants.EXTRA_VERTICAL_SPACING);
        if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND && (position == ScreenRegion.TOP_LEFT || position == ScreenRegion.TOP_RIGHT)) {
            initialY += (!AppState.showClock ? 10 : -5);
        }
        return initialY;
    }

    function getEndY(position, dc) {
        var endY = (AppState.switchBottomInfo ? dc.getFontHeight(Gfx.FONT_XTINY) : AppConstants.EXTRA_VERTICAL_SPACING);
        if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND && (position == ScreenRegion.BOTTOM_LEFT || position == ScreenRegion.BOTTOM_RIGHT)) {
            endY += (!AppState.switchBottomInfo ? 10 : - 0);
        }
        return endY;
    }

    hidden function isButtonHighlighted(button) {
        return button.getState() == :stateHighlighted;
    }

    //! Function called to read heart rate sensor value
    function onSensor(sensor_info)
    {
        if (Act has :getHeartRateHistory) {
            currentHR = Acty.getActivityInfo().currentHeartRate;
            if(currentHR==null) {
                var HRH=Act.getHeartRateHistory(1, true);
                var HRS=HRH.next();
                if(HRS!=null && HRS.heartRate!= Act.INVALID_HR_SAMPLE){
                    currentHR = HRS.heartRate;
                }
            }
            if(currentHR!=null) {
                currentHR = currentHR.toString();
            } else{
                currentHR = "--";
            }
        }
        else if(sensor_info.heartRate != null) {
            currentHR = sensor_info.heartRate.toString();
        }
        else
        {
            currentHR = "---";
        }

        //currentHR = currentHR + "/" + heartRate;

        Ui.requestUpdate();
    }
}

class MatchViewFocusDelegate extends Ui.BehaviorDelegate {
    hidden var view;
    function initialize(_view) {
        BehaviorDelegate.initialize();
        view = _view;
        $.bus.register(self);
    }

    function onPreviousPage() {
    }

    function onMenu() {
        Sys.println("onMenu happened");
        return true;
    }

    function onKey(keyEvent) {
        Sys.println("key pressed: " + keyEvent.getKey());
        if (keyEvent.getKey() == KEY_ENTER) {
            showPauseMenu();
        } else {
            Sys.println("Nothing to do here! Moving on! ");
        }
    }

    function showPauseMenu() {
        Sys.println("showPauseMenu happened");
        var menu = new Ui.Menu2({:title => Rez.Strings.pause_menu_title});
        var delegate;
        menu.addItem(
            new Ui.MenuItem(
                Rez.Strings.pause_menu_continue,
                null,
                :menu_item_continue,
                {}
            )
        );
        menu.addItem(
            new Ui.MenuItem(
                Rez.Strings.pause_menu_finish,
                null,
                :menu_item_finish,
                {}
            )
        );
        menu.addItem(
            new Ui.MenuItem(
                Rez.Strings.pause_menu_discard,
                null,
                :menu_item_discard,
                {}
            )
        );
        Ui.pushView(menu, new PauseMenuDelegate(), Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function onTap(event) {
        var tapRegion = ScreenRegion.getRegion(event.getCoordinates(), 6);
        if (tapRegion[:y] == ScreenRegion.BOTTOM) {
            if (!$.match.isStarted()) { return; }
            AppState.showGameInfo = AppState.showGameInfo ? false : true;
            Ui.requestUpdate();
        }
       //whichButtonWasPressed(event.getCoordinates());
    }

    function manageScore(player) {
        if (!$.match.isStarted()) {
            $.match.start(player);
            Ui.requestUpdate();
            return;
        }

        $.match.scorePlayer(player);
        Ui.requestUpdate();
        var winner = $.match.getCurrentGame().getWinner();
        if(winner != null) {
          Ui.switchToView(new GameResultView(), new GameResultViewDelegate(), Ui.SLIDE_IMMEDIATE);
        }
        else {
            $.bus.dispatch(new BusEvent(:vibrate, 200));
            Ui.requestUpdate();
        }
    }

    function onPlayer1() {
        Sys.println("onPlayer1 happened");
        manageScore(:player_1);
    }

    function onPlayer2() {
        Sys.println("onPlayer2 happened");
        manageScore(:player_2);
    }

    function onStartMatch() {
        Sys.println("onStartMatch happened");
        var menu = new Ui.Menu2({:title => Rez.Strings.player_menu_title});
        var delegate;
        menu.addItem(
            new Ui.MenuItem(
                Rez.Strings.player_menu_item_you,
                null,
                :player_1,
                {}
            )
        );
        menu.addItem(
            new Ui.MenuItem(
                App.getApp().getProperty("opponent_name"),
                null,
                :player_2,
                {}
            )
        );
        menu.addItem(
            new Ui.MenuItem(
                Rez.Strings.player_menu_item_random,
                null,
                :player_random,
                {}
            )
        );
        Ui.pushView(menu, new ServerSelectorDelegate(method(:selectServerAndStartMatch)), Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function selectServerAndStartMatch(server) {
        if (!$.match.isStarted()) {
            $.match.start(server);
            AppState.showGameInfo = true;
            var matchViewFocus = new MatchViewFocus();
              Ui.switchToView(matchViewFocus, new MatchViewFocusDelegate(matchViewFocus),
                              Ui.SLIDE_IMMEDIATE);
        }
    }

    function onBack() {
        $.bus.dispatch(new BusEvent(:vibrate, 200));
        if($.match.getTotalRalliesNumber() > 0) {
            //undo last rally
            $.match.undo();
            Ui.requestUpdate();
        } else {
            $.match.discard();
            var view = new InitialView();
            AppState.showGameInfo = false;
            Ui.switchToView(view, new InitialViewDelegate(view), Ui.SLIDE_IMMEDIATE);
        }
        return true;
    }
}

class ServerSelectorDelegate extends Ui.Menu2InputDelegate {
    hidden var selectServerAndStartMatch;
    function initialize(finishSelection) {
        Menu2InputDelegate.initialize();
        selectServerAndStartMatch = finishSelection;
    }

    function onSelect(item) {
        var id = item.getId();
        if (id == :player_1) {
            Toybox.System.println("Player one should be chosen here");
            selectServerAndStartMatch.invoke(:player_1);
        } else if (id == :player_random) {
            Toybox.System.println("Random player should be chosen here");
            var r;
            r = (Mt.rand() % 900 + 100) % 2; //Random number between 100 and 1000 (900+100)
            selectServerAndStartMatch.invoke(r == 0 ? :player_1 : :player_2);
        } else {
            selectServerAndStartMatch.invoke(:player_2);
        }
    }
}

class PauseMenuDelegate extends Ui.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();
        if (id == :menu_item_continue) {
            onBack();
        } else if (id == :menu_item_finish) {
            var finish_match_confirmation = new Ui.Confirmation(Ui.loadResource(Rez.Strings.pause_menu_confirmation_finish));
            Ui.pushView(finish_match_confirmation, new FinishGameConfirmationDialog(method(:onConfirm)), Ui.SLIDE_IMMEDIATE);
        } else if (id == :menu_item_discard) {
            var discard_match_confirmation = new Ui.Confirmation(Ui.loadResource(Rez.Strings.pause_menu_confirmation_discard));
            Ui.pushView(discard_match_confirmation, new DiscardMatchConfirmationDialog(), Ui.SLIDE_IMMEDIATE);
        }
        return true;
    }

    function onConfirm() {
        onBack();
    }
}

class DiscardMatchConfirmationDialog extends Ui.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(value) {
        if (value == CONFIRM_YES) {
            $.match.discard();
            System.exit();
        } else {

        }
        return true;
    }
}

class FinishGameConfirmationDialog extends Ui.ConfirmationDelegate {
    hidden var onFinishGame;
    function initialize(onFinishGame) {
        ConfirmationDelegate.initialize();
        self.onFinishGame = onFinishGame;
    }

    function onResponse(value) {
        if (value == CONFIRM_YES) {
            if ($.match.isStarted()) {
                $.match.forceGameFinish();
                onFinishGame.invoke();
            } else {
                $.match.save();
                System.exit();
            }
        } else {

        }
        return true;
    }
}