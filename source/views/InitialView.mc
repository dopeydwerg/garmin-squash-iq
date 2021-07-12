using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Attention as Attention;
using Toybox.Lang;
using Toybox.Timer as Timer;
using Toybox.Communications as Comm;
using Toybox.Application.Storage as Storage;

var config;

class InitialView extends Ui.View {
    hidden var refreshTimer = new Timer.Timer();
    hidden var ticks = 0;
    hidden var dots = ".";
    hidden var mTransferSuccessMessage, mTransferFailedMessage;

  function initialize() {
    // Comm.setMailboxListener(method(:onMail));
    Comm.registerForPhoneAppMessages(method( :onPhoneMessageCallback));
    View.initialize();
  }

  function onShow() {
    Sys.println("Showing InitialView");
    // App.getApp().setProperty("opponent_name", "value");
    var message = "test";
    refreshTimer.start(method( :refresh), 1000, true);
  }

  function onHide() {
    Sys.println("Stopping the timer");
    refreshTimer.stop();
    ticks = 0;
  }

  function refresh() {
    ticks++;
    dots = "";
    var counter = 0;
    do {
      dots += ".";
      counter++;
    } while (counter <= ticks % 3);
    //Sys.println("refreshing this thing " + ticks + " " + dots);
    Ui.requestUpdate();
  }

  hidden var typeLabel = "";

  function onUpdate(dc) {
    var width = dc.getWidth();
    var height = dc.getHeight();
    var textCenter = Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER;
    var backgroundColor = Gfx.COLOR_BLACK;
    dc.setColor(backgroundColor, Gfx.COLOR_TRANSPARENT);
    // Set background color
    dc.fillRectangle(0, 0, width, height);

    // Top App title
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.fillRectangle(0, 0, width, height * 0.25);
    dc.fillRectangle(0, height - (height * 0.25), width, height * 0.25);
    dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT);
    var appName = Ui.loadResource(Rez.Strings.application_name);
    dc.drawText(width / 2, (height * 0.25) / 2 / 2, Gfx.FONT_LARGE, appName,
                Gfx.TEXT_JUSTIFY_CENTER);
    if ($.match == null) {
      typeLabel = Ui.loadResource(Rez.Strings.press_start_label);
    } else {
      typeLabel = Ui.loadResource(Rez.Strings.press_continue_label);
    }
    dc.drawText(width / 2, height - ((height * 0.25)), Gfx.FONT_TINY,
                dots + typeLabel + dots, Gfx.TEXT_JUSTIFY_CENTER);

    // Center opponent part
    dc.setColor((backgroundColor == Gfx.COLOR_BLACK) ? Gfx.COLOR_WHITE
                                                     : Gfx.COLOR_BLACK,
                Graphics.COLOR_TRANSPARENT);
    dc.drawText(width / 2, height / 2 - 60, Gfx.FONT_TINY,
                Ui.loadResource(Rez.Strings.next_opponent_label) + ':',
                Gfx.TEXT_JUSTIFY_CENTER);
    dc.drawText(width / 2, height / 2, Gfx.FONT_MEDIUM,
                App.getApp().getProperty("opponent_name"),
                Gfx.TEXT_JUSTIFY_CENTER);
  }

  // #region companion stuff
  function onMail(mailIter) {
    var mail;
    mail = mailIter.next();
    Comm.emptyMailbox();
    if (mail != null) {
      App.getApp().setProperty("opponent_name", "Received mail");
    }

    Ui.requestUpdate();
  }
  var message = new Comm.PhoneAppMessage();
  function onPhoneMessageCallback(msg) {
    message = msg.data;
    var type = message.get(SquashItConstants.KEY_MESSAGE_TYPE);
    var payload = message.get(SquashItConstants.KEY_MESSAGE_PAYLOAD);

    if (type == SquashItConstants.MESSAGE_TYPE_PLAYER_INFO) {
        App.getApp().setProperty("opponent_name", message);
        App.getApp().setProperty("opponent_id", message);
    }

    Ui.requestUpdate();
    return true;
  }
}

class InitialViewDelegate extends Ui.BehaviorDelegate {
    hidden var lastUsedScreen;

    function initialize(view) {
        BehaviorDelegate.initialize();
        lastUsedScreen = Storage.getValue("lastUsedScreen");
        Sys.println(lastUsedScreen);
    }

    function onBack() {
        Ui.pushView(new Ui.Confirmation(Ui.loadResource(Rez.Strings.confirm_exit)),
            new ExitConfirmationDelegate(), Ui.SLIDE_IMMEDIATE);
        return true;
    }

  function onTap(event) {
    var center = $.device.screenHeight / 2;
    Sys.println(center);
    Sys.println(event.getCoordinates());
  }

  function onKey(keyEvent) {
    if (keyEvent.getKey() == KEY_ENTER) {
      Sys.println("Starting the game!!");
      $.bus.dispatch(new BusEvent( :vibrate, 200));
      var num_games = App.getApp().getProperty("games_to_play");
      $.match = new Match(num_games, App.getApp().getProperty("opponent_name"), 0);
      if (lastUsedScreen == "MatchView") {
            var matchView = new MatchView();
            Ui.switchToView(matchView, new MatchViewDelegate(),
                              Ui.SLIDE_IMMEDIATE);
        } else {
            var matchViewFocus = new MatchViewFocus();
            Ui.switchToView(matchViewFocus, new MatchViewFocusDelegate(matchViewFocus),
                              Ui.SLIDE_IMMEDIATE);
        }
    } else {
      Sys.println("Nothing to do here! Moving on!");
    }
  }

  function onEnter() { Sys.println("testing on onEnter"); }

  function onStart(state) { Sys.println("doing this thingy"); }

  function onMenu() { Sys.println("Opening the settings view"); }
}

//! Delegate that handles the event from the Confirmation dialog
//! that appears before quitting the App.
class ExitConfirmationDelegate extends Ui.ConfirmationDelegate {

    function initialize() {
        ConfirmationDelegate.initialize();
    }

    //! Event that happens on response of the user.
    //! When the user replies YES, then the App exits.
    function onResponse(response) {
        if (response == CONFIRM_YES) {
            System.exit();
        }
    }
}