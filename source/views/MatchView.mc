using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Attention as Attention;
using Toybox.Lang;
using Toybox.Timer as Timer;

var boundaries; 

class MatchView extends Ui.View {
  
  // Variables
  hidden var  timer;

  function initialize() { 
    View.initialize(); 

    timer = new Timer.Timer();
    $.boundaries = getBoundaries();

    Sys.println($.boundaries);
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

    // :player_1
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.fillRectangle(0, $.device.screenHeight * 0.66, $.device.screenWidth * 0.33, $.device.screenHeight * 0.33);
    
    // :player_2
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.fillRectangle($.device.screenWidth * 0.66, $.device.screenHeight * 0.66, $.device.screenWidth * 0.33, $.device.screenHeight * 0.33);
  }
}

class MatchViewDelegate extends Ui.BehaviorDelegate {
  hidden var view;

  function initialize(_view) { 
    view = _view;
    BehaviorDelegate.initialize(); 
  }

  function onBack() {
    var view = new InitialView();
    Ui.switchToView(view, new InitialViewDelegate(view), Ui.SLIDE_IMMEDIATE);

    return true;
  }

  function whichButtonWasPressed(coords) {
    var x = coords[0];
    var y = coords[1];
    var p1_btn = $.boundaries.get(:player_1_btn);
    var p2_btn = $.boundaries.get(:player_2_btn);
    if (x >= p1_btn[:x1] && x <= p1_btn[:x2] && y >= p1_btn[:y1] && y <= p1_btn[:y2]) {
      Sys.println("it was player one");
    } else if (x >= p2_btn[:x1] && x <= p2_btn[:x2] && y >= p2_btn[:y1] && y <= p2_btn[:y2]) {
      Sys.println("it was player two");
    } else {
      Sys.println("It was noting");
    }
  }

  function onTap(event) {
    whichButtonWasPressed(event.getCoordinates());
  }

  function onRelax() {
    Sys.println("Hello is this working");
    view.testJe(:player_1);
  }
}