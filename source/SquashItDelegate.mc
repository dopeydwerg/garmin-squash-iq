using Toybox.WatchUi;

class SquashItDelegate extends WatchUi.BehaviorDelegate {
  function initialize() { BehaviorDelegate.initialize(); }

  function onMenu() {
    WatchUi.pushView(new Rez.Menus.PauseMenu(), new SquashItMenuDelegate(),
                     WatchUi.SLIDE_UP);
    return true;
  }

  function onNextPage() { }

  function onPreviousPage() { }

  function onBack() {
    return false;
  }

  function onStart(state) {

  }
}