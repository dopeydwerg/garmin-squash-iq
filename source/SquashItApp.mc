using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Attention as Attention;
using Toybox.Timer as Timer;

var bus;
var match;
var device = Sys.getDeviceSettings();

class SquashItApp extends App.AppBase {
  function initialize() { 
    AppBase.initialize();

    //create bus for the whole application
		$.bus = new Bus();
		$.bus.register(self);
  }

  function vibrate(duration){
		var vibrateData = [ new Attention.VibeProfile(  80, duration ) ];
		Attention.vibrate( vibrateData );
	}

  // onStart() is called on application start up
  function onStart(state) {}

  // onStop() is called when your application is exiting
  function onStop(state) {}

  // Return the initial view of your application here
  function getInitialView() {
    var view = new InitialView();
    return [ view, new InitialViewDelegate(view) ];
  }
}
