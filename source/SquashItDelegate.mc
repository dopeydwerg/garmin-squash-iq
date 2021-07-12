using Toybox.WatchUi;

class SquashItDelegate extends WatchUi.BehaviorDelegate {
  function initialize() { BehaviorDelegate.initialize(); }

  function onMenu() {
    WatchUi.pushView(new Rez.Menus.PauseMenu(), new SquashItMenuDelegate(),
                     WatchUi.SLIDE_UP);
    return true;
  }

  function onNextPage() { System.println("onNextPage happened"); }

  function onPreviousPage() { System.println("onPreviousPage happened"); }

  function onBack() {
    System.println("onBack happened");
    return false;
  }

  function onStart(state) {
    System.println(state);
  }
}