using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

class GameResultView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.game_result(dc));
    }

  function onShow() {
    $.bus.dispatch(new BusEvent(:vibrate, 200));
    var game = $.match.getCurrentGame();
    var game_winner = game.getWinner();

    var won_text = Ui.loadResource(game_winner == :player_1 ? Rez.Strings.game_end_you_won : Rez.Strings.game_end_opponent_won);
        findDrawableById("game_result_won_text").setText(won_text);
        //draw set score
        var score_text = game.getScore(:player_1).toString() + " - " + game.getScore(:player_2).toString();
        findDrawableById("game_result_score").setText(score_text);
    //draw elapsed time
    var elapsed_time_text = Ui.loadResource(Rez.Strings.game_end_elpased);
    findDrawableById("game_result_lapsed_time").setText(Helpers.formatString(elapsed_time_text, {"elapsed_time" => game.getElapsedTime().toString()}));

        findDrawableById("game_result_what_next").setText(Ui.loadResource(Rez.Strings.game_end_what_next));

    findDrawableById("game_result_next_server_you").setText(Ui.loadResource(Rez.Strings.game_end_you_label));

    findDrawableById("game_result_finish_match").setText(Ui.loadResource(Rez.Strings.game_end_finish_match));

    findDrawableById("game_result_next_server_opponent").setText(Ui.loadResource(Rez.Strings.game_end_opponent_label));
  }
}

class GameResultViewDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onBack() {
        //undo last point
        $.match.undo();
        returnToCorrectView();
        return true;
    }

    function handleNextGame(player) {
        $.match.nextGame(player);
        returnToCorrectView();
    }

    function returnToCorrectView() {
        if (Storage.getValue("lastUsedScreen") == "MatchView") {
            var matchView = new MatchView();
            Ui.switchToView(matchView, new MatchViewDelegate(),
                              Ui.SLIDE_IMMEDIATE);
        } else {
            var matchViewFocus = new MatchViewFocus();
            Ui.switchToView(matchViewFocus, new MatchViewFocusDelegate(matchViewFocus),
                              Ui.SLIDE_IMMEDIATE);
        }
    }

  function onSelect() {
    Sys.println("in this on select thingy");
    return true;
  }

  function onYouServing() {
    Sys.println("You are serving next");
    handleNextGame(:player_1);

    return true;
  }

  function onOpponentServing() {
    Sys.println("Opponent is serving");
    handleNextGame(:player_2);
    return true;
  }

  function onFinish() {
    Sys.println("You are finished");
    $.match.finish();
        Ui.switchToView(new ResultView(), new ResultViewDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }
}