using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Attention as Attention;
using Toybox.Lang;
using Toybox.Timer as Timer;
using Toybox.Sensor as Sensor;
using Toybox.Application.Storage as Storage;
using Toybox.Math as Mt;

class MatchViewFocus extends Ui.View {

    //! Vertical place in the screen where we start
    //! drawing. In round watches we should leave
    //! some initial vertical space.
    hidden var initialY;
    hidden var segmentHeight;
    hidden var currentHR;
    hidden var elapsedTime = "00:00";
    hidden const textCenter = Gfx.TEXT_JUSTIFY_CENTER;
    hidden const STATS_LABEL_FONT = Gfx.FONT_XTINY;
    hidden const STATS_VALUE_FONT = Gfx.FONT_NUMBER_MILD;

    //! Array of 2 buttons containing the player 1 and player 2
    //! buttons
    hidden var playerButtons;

    function initialize() {
        View.initialize();

        Storage.setValue("lastUsedScreen", "MatchViewFocus");

        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        Sensor.enableSensorEvents(method(:onSensor));
    }

    function onLayout(dc) {
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
            :locY => initialY + AppConstants.VERTICAL_SPACING + segmentHeight,
            :width => dc.getWidth(),
            :height => segmentHeight,
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
            :locY => initialY + AppConstants.VERTICAL_SPACING + segmentHeight,
            :width => widthButton,
            :height => segmentHeight,
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
        View.onUpdate(dc);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.setPenWidth(2);
        // Do datatracker stuff in here

        var x = dc.getWidth() / 2 - AppConstants.HORIZONTAL_SPACING;
        var y = initialY;

        // First segment
        drawHeartRate(dc);

        // Second segment
        y = y + AppConstants.VERTICAL_SPACING + segmentHeight;
        if ($.match.isStarted()) {
            var serveInfo = $.match.getCurrentServerInfo();
            var game = $.match.getCurrentGame();
            elapsedTime = game.getElapsedTime();
            drawPlayerButton(dc, x, y, "YOU", game.getScore(:player_1), $.match.getGamesWon(:player_1), Gfx.TEXT_JUSTIFY_RIGHT, serveInfo[:server] == :player_1 ? serveInfo[:serve] : null);
            x = dc.getWidth() / 2 + AppConstants.HORIZONTAL_SPACING;
            drawPlayerButton(dc, x, y, "OPP", game.getScore(:player_2), $.match.getGamesWon(:player_2), Gfx.TEXT_JUSTIFY_LEFT, serveInfo[:server] == :player_2 ? serveInfo[:serve] : null);
            setPlayerButtonColors();
        } else {
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, y, Gfx.FONT_SMALL, "Warming Up!!", Gfx.TEXT_JUSTIFY_CENTER);
            dc.drawText(x, initialY + AppConstants.VERTICAL_SPACING + (segmentHeight * 2) - dc.getFontHeight(Gfx.FONT_SMALL), Gfx.FONT_SMALL, "Press to Start!", Gfx.TEXT_JUSTIFY_CENTER);
        }

        // Third segment
        y = y + AppConstants.VERTICAL_SPACING + segmentHeight + AppConstants.HORIZONTAL_SPACING;
        //dc.drawLine(0, y, dc.getWidth(), y);
        dc.drawText(dc.getWidth() / 2, y, STATS_LABEL_FONT, "Game Stats", Gfx.TEXT_JUSTIFY_CENTER);
        y = y + dc.getFontHeight(STATS_LABEL_FONT) + AppConstants.VERTICAL_SPACING + AppConstants.EXTRA_VERTICAL_SPACING;
        dc.drawText(dc.getWidth() / 2, y, STATS_VALUE_FONT, elapsedTime, Gfx.TEXT_JUSTIFY_CENTER);
        y = y + (AppConstants.VERTICAL_SPACING / 2);
    }

    function setPlayerButtonColors() {
        var serveInfo = $.match.getCurrentServerInfo();
        if (serveInfo[:server] == :player_1) {
            playerButtons[0].stateDefault = Gfx.COLOR_DK_GREEN;
            playerButtons[1].stateDefault = Gfx.COLOR_WHITE;
        } else {
            playerButtons[1].stateDefault = Gfx.COLOR_DK_GREEN;
            playerButtons[0].stateDefault = Gfx.COLOR_WHITE;
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
        dc.drawText(x, y, Gfx.FONT_TINY, label, justify);

        // Server info. Draw concurrent serves in a squashball
        if (serveInfo != null) {
            var serveX = x + (justify == Gfx.TEXT_JUSTIFY_RIGHT ? - dc.getWidth() / 4 : dc.getWidth() / 4) * 1.5;
            dc.fillCircle(serveX , y + 20, 20);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(serveX, y, Gfx.FONT_TINY, serveInfo, Gfx.TEXT_JUSTIFY_CENTER);
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        }
        y = y + dc.getFontHeight(Gfx.FONT_TINY) + AppConstants.VERTICAL_SPACING;
        dc.drawText(x, y, Gfx.FONT_NUMBER_MEDIUM, score, justify);
        x = dc.getWidth() / 4;
        x = justify == Gfx.TEXT_JUSTIFY_RIGHT ? x - 15 : x * 3 + 15;
        dc.drawText(x, y, Gfx.FONT_XTINY, "games", Gfx.TEXT_JUSTIFY_CENTER);
        y = y + (dc.getFontHeight(Gfx.FONT_NUMBER_MILD) - dc.getFontHeight(Gfx.FONT_SMALL)) +  AppConstants.VERTICAL_SPACING;
        dc.drawText(x, y, Gfx.FONT_SMALL, games, Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    }

    function drawHeartRate(dc) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText($.device.screenWidth / 2, AppConstants.EXTRA_VERTICAL_SPACING, STATS_LABEL_FONT, "HRM", textCenter);
        var startY = dc.getFontHeight(STATS_LABEL_FONT) + AppConstants.VERTICAL_SPACING + AppConstants.EXTRA_VERTICAL_SPACING;
        dc.drawText($.device.screenWidth / 2, startY, STATS_VALUE_FONT, currentHR, textCenter);
    }

    hidden function isButtonHighlighted(button) {
        return button.getState() == :stateHighlighted;
    }

    //! Function called to read heart rate sensor value
    function onSensor(sensor_info)
    {
        if( sensor_info.heartRate != null )
        {
            currentHR = sensor_info.heartRate.toString();
        }
        else
        {
            currentHR = "---";
        }
        Ui.requestUpdate();
    }
}

class MatchViewFocusDelegate extends Ui.BehaviorDelegate {
    function initialize(_view) {
        BehaviorDelegate.initialize();
    }

    function onPreviousPage() {
        var matchView = new MatchView();
        Ui.switchToView(matchView, new MatchViewDelegate(),
                  Ui.SLIDE_IMMEDIATE);
    }

    function onKey(keyEvent) {
        if (keyEvent.getKey() == KEY_ENTER) {
            if ($.match.isStarted()) {
                manageScore($.match.getCurrentServerInfo()[:server]);
            }
        } else {
            Sys.println("Nothing to do here! Moving on!");
        }
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
        System.println(id);
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