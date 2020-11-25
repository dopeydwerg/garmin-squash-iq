using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Attention as Attention;
using Toybox.Lang;
using Toybox.Timer as Timer;
using Toybox.Sensor as Sensor;

var boundaries; 

class MatchView extends Ui.View {
  
  // Variables
  hidden var  timer;
  hidden var currentHeartRate;

  // Font settings
  hidden const textVCenter = Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER;
  hidden const textCenter = Gfx.TEXT_JUSTIFY_CENTER;
  hidden const VERTICAL_SPACING = 2;
  hidden const EXTRA_VERTICAL_SPACING = 10;
  hidden const HORIZONTAL_SPACING = 6;
  hidden const STATS_LABEL_FONT = Gfx.FONT_XTINY;
  hidden const STATS_VALUE_FONT = Gfx.FONT_NUMBER_MILD;

  function initialize() { 
    View.initialize(); 

    timer = new Timer.Timer();
    $.boundaries = getBoundaries();

    Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
    Sensor.enableSensorEvents(method(:onSensor));
  }

  function onLayout(dc) { 
    setLayout(Rez.Layouts.MainLayout(dc)); 
  }

  function testJe(player) {
    Sys.println("Message triggered from the delegate" + player);
  }

  function getBoundaries () {
    var player_1_btn_bounds = {
      :x1 => 0,
      :x2 => $.device.screenWidth * 0.33,
      :y1 => $.device.screenHeight * 0.66,
      :y2 => $.device.screenHeight
    };
    var player_2_btn_bounds = {
      :x1 => $.device.screenWidth * 0.66,
      :x2 => $.device.screenWidth,
      :y1 => $.device.screenHeight * 0.66,
      :y2 => $.device.screenHeight
    };

    return {
      :player_1_btn => player_1_btn_bounds,
      :player_2_btn => player_2_btn_bounds
    };
  }

  function onUpdate(dc) {
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    dc.clear();

    var myRaster = new Rez.Drawables.screenDivider();
    myRaster.draw(dc);

    drawHeartRate(dc);

    drawSteps(dc);

    drawCalories(dc);

    drawClock(dc);

    // :player_1
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.fillRectangle(0, $.device.screenHeight * 0.66, $.device.screenWidth * 0.33, $.device.screenHeight * 0.33);
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
    dc.drawText($.device.screenWidth * 0.33 / 2 + 20, $.device.screenHeight * 0.825 - 20, Gfx.FONT_MEDIUM, "You", textVCenter);

    
    
    // :player_2
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.fillRectangle($.device.screenWidth * 0.66, $.device.screenHeight * 0.66, $.device.screenWidth * 0.33, $.device.screenHeight * 0.33);
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
    dc.drawText($.device.screenWidth * 0.825 - 20, $.device.screenHeight * 0.825 - 20, Gfx.FONT_MEDIUM, "Opp", textVCenter);

    // Game stats
    drawGameStats(dc);
  }

  function drawGameStats(dc) {
    dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
    if ($.match.isStarted()) {
      var serveInfo = $.match.getCurrentServerInfo();

      var game = $.match.getCurrentGame();
      var y = $.device.screenHeight * 0.66 + EXTRA_VERTICAL_SPACING;
      var x = $.device.screenWidth / 2;

      dc.drawText(x, y, STATS_LABEL_FONT, "game", textVCenter);
      y = y + VERTICAL_SPACING + dc.getFontHeight(STATS_LABEL_FONT);

      dc.drawText(x, y, Gfx.FONT_TINY, Lang.format("$1$ / $2$", [game.getScore(:player_1), game.getScore(:player_2)]), textVCenter);
      y = y + VERTICAL_SPACING + dc.getFontHeight(Gfx.FONT_TINY) - EXTRA_VERTICAL_SPACING;

      dc.drawText(x, y, STATS_LABEL_FONT, "match", textVCenter);
      if (serveInfo[:server] == :player_1) {
        dc.drawText($.device.screenWidth * 0.33 / 2 + 40, y + 5, Gfx.FONT_TINY, serveInfo[:serve], textVCenter);
      } else {
        dc.drawText($.device.screenWidth * 0.825 - 40, y + 5, Gfx.FONT_TINY, serveInfo[:serve], textVCenter);
      }
      y = y + VERTICAL_SPACING + dc.getFontHeight(STATS_LABEL_FONT);

      dc.drawText(x, y, Gfx.FONT_TINY, Lang.format("$1$ / $2$", [$.match.getGamesWon(:player_1), $.match.getGamesWon(:player_2)]), textVCenter);
    } else {
      var statsText = "Select Server To Start";
      var textArea = View.findDrawableById("BlockOfText");
      textArea.setText(statsText);
      textArea.draw(dc);
    }
  }

  function drawClock(dc) {
    var clockTime = Sys.getClockTime();
    var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText($.device.screenWidth / 2, $.device.screenHeight / 2, Gfx.FONT_SMALL, timeString, textVCenter);
  }

  function drawHeartRate(dc) {
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText($.device.screenWidth / 2, EXTRA_VERTICAL_SPACING, STATS_LABEL_FONT, "HRM", textCenter);
    var startY = dc.getFontHeight(STATS_LABEL_FONT) + VERTICAL_SPACING + EXTRA_VERTICAL_SPACING;
    dc.drawText($.device.screenWidth / 2, startY, STATS_VALUE_FONT, currentHeartRate, textCenter);
  }

  function drawSteps(dc) {
    var data = $.dataTracker.getCurrentData();
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText($.device.screenWidth * 0.33 / 2, $.device.screenHeight * 0.33 + EXTRA_VERTICAL_SPACING, STATS_LABEL_FONT, "STEPS", textCenter);
    var startY = dc.getFontHeight(STATS_LABEL_FONT) + VERTICAL_SPACING + EXTRA_VERTICAL_SPACING + ($.device.screenHeight * 0.33 );
    dc.drawText($.device.screenWidth * 0.33 / 2, startY, STATS_VALUE_FONT, data[:stepsTaken], textCenter);
  }

  function drawCalories(dc) {
    var data = $.dataTracker.getCurrentData();
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText($.device.screenWidth * 0.825, $.device.screenHeight * 0.33 + EXTRA_VERTICAL_SPACING, STATS_LABEL_FONT, "CALS", textCenter);
    var startY = dc.getFontHeight(STATS_LABEL_FONT) + VERTICAL_SPACING + EXTRA_VERTICAL_SPACING + ($.device.screenHeight * 0.33 );
    dc.drawText($.device.screenWidth * 0.825, startY, STATS_VALUE_FONT, data[:caloriesBurned], textCenter);
  }

  function onSensor(sensor_info) {
    if( sensor_info.heartRate != null )
    {
        currentHeartRate = sensor_info.heartRate.toString();
    }
    else
    {
        currentHeartRate = "---";
    }
    Ui.requestUpdate();
  }
}

class MatchViewDelegate extends Ui.BehaviorDelegate {
  hidden var view;

  function initialize(_view) { 
    view = _view;
    BehaviorDelegate.initialize(); 
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

  function manageScore(player) {
    if (!$.match.isStarted()) {
      $.match.start(player);
      Ui.requestUpdate();
      return;
    }
    
    $.match.scorePlayer(player);
		var winner = $.match.getCurrentGame().getWinner();
		if(winner != null) {
			Ui.switchToView(new GameResultView(), new GameResultViewDelegate(), Ui.SLIDE_IMMEDIATE);
		}
		else {
      $.bus.dispatch(new BusEvent(:vibrate, 200));
			Ui.requestUpdate();
		}
  }

  function whichButtonWasPressed(coords) {
    var x = coords[0];
    var y = coords[1];
    var p1_btn = $.boundaries.get(:player_1_btn);
    var p2_btn = $.boundaries.get(:player_2_btn);
    if (x >= p1_btn[:x1] && x <= p1_btn[:x2] && y >= p1_btn[:y1] && y <= p1_btn[:y2]) {
      Sys.println("it was player one");
      manageScore(:player_1);
    } else if (x >= p2_btn[:x1] && x <= p2_btn[:x2] && y >= p2_btn[:y1] && y <= p2_btn[:y2]) {
      Sys.println("it was player two");
      manageScore(:player_2);
    } else {
      Sys.println("It was noting");
    }
  }

  function onTap(event) {
    whichButtonWasPressed(event.getCoordinates());
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

  function onRelax() {
    Sys.println("Hello is this working");
    view.testJe(:player_1);
  }
}