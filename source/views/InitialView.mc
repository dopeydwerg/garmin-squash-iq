using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Attention as Attention;
using Toybox.Lang;
using Toybox.Timer as Timer;

var config;

class InitialView extends Ui.View {
  hidden var refreshTimer = new Timer.Timer();
  hidden var ticks = 0;
  hidden var dots = ".";

  function initialize() { View.initialize(); }

  function onShow() {
    Sys.println("Showing InitialView");
    // App.getApp().setProperty("opponent_name", "value");
    refreshTimer.start(method(:refresh), 1000, true);
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
    } 
    while (counter <= ticks % 3);
    Sys.println("refreshing this thing " + ticks + " " + dots);
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
    dc.drawText(width / 2, height - ((height * 0.25)), Gfx.FONT_TINY, dots + typeLabel + dots, Gfx.TEXT_JUSTIFY_CENTER);

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
}

class InitialViewDelegate extends Ui.BehaviorDelegate {
  function initialize(view) { BehaviorDelegate.initialize(); }

  function vibrate(duration){
		var vibrateData = [ new Attention.VibeProfile(  100, duration ) ];
		Attention.vibrate( vibrateData );
	}

  function onBack() {
    // pop the main view to close the application
    Sys.println("We're definitely not doing this right now");
    Ui.requestUpdate();
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
      vibrate(1500);
      $.match = new Match();
      var matchView = new MatchView();
      Ui.switchToView(matchView, new MatchViewDelegate(matchView), Ui.SLIDE_IMMEDIATE);
    } else {
      Sys.println("Nothing to do here! Moving on!");
    }
  }

  function onEnter() { Sys.println("testing on onEnter"); }

  function onStart(state) { Sys.println("doing this thingy"); }

  function onMenu() { Sys.println("Opening the settings view"); }

}
