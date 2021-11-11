using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Communications as Comm;

class SaveMatchConfirmationDelegate extends Ui.ConfirmationDelegate {
  hidden var mTransferSuccessMessage, mTransferFailedMessage;

  function initialize() {
    mTransferSuccessMessage = Ui.loadResource(Rez.Strings.text_transfer_success);
    mTransferFailedMessage = Ui.loadResource(Rez.Strings.text_transfer_failure);
    ConfirmationDelegate.initialize();
  }

  function onResponse(value) {
    if (value == CONFIRM_YES) {
      $.match.save();
      var message = {
        SquashItConstants.KEY_MESSAGE_TYPE => SquashItConstants.MESSAGE_TYPE_SAVE_MATCH,
        SquashItConstants.KEY_MESSAGE_PAYLOAD => $.match.getMatchStats()
      };
      Comm.transmit(message, null, new TransmitCommListener(method(:onTransmitComplete)));
    } else {
      $.match.discard();
    }
    // remove confirmation from view stack before going to back to type screen
    Sys.exit();
    //var view = new InitialView();
    //Ui.switchToView(view, new InitialViewDelegate(view), Ui.SLIDE_IMMEDIATE);
  }

  //! Called when a Comm.transmit() has completed.
  //! @param status The status of the message, either
  //! InitalViewCommListener.SUCCESS
  //!               or InitalViewCommListener.FAILURE
  function onTransmitComplete(status) {
    if (status == TransmitCommListener.SUCCESS) {
      App.getApp().setProperty("opponent_name", mTransferSuccessMessage);
    } else {
      App.getApp().setProperty("opponent_name", mTransferFailedMessage);
    }
    // mProgressBarTimer.start(method(:hideProgressBar), 2000, false);
  }
}

//! Handles communication feedback for the RoundView
class TransmitCommListener extends Comm.ConnectionListener {
  static var SUCCESS = 0;
  static var FAILURE = 1;

  hidden var mCallback;

  //! Constructor
  //! @param callback The method to call on a result
  function initialize(callback) {
    Comm.ConnectionListener.initialize();
    mCallback = callback;
  }

  //! Call the callback with a result of TransmitCommListener.SUCCESS
  function onComplete() { mCallback.invoke(SUCCESS); }

  //! Call the callback with a result of InitalViewCommListener.FAILURE
  function onError() { mCallback.invoke(FAILURE); }
}

class ResultView extends Ui.View {
  function initialize() { View.initialize(); }

  function onLayout(dc) { setLayout(Rez.Layouts.result(dc)); }

  function onShow() {
    // draw end of match text
    var winner = $.match.getWinner();
    var won_text;
    if (winner == : player_1) {
      won_text = Ui.loadResource(Rez.Strings.end_you_won);
    } else {
      var opponent_name = App.getApp().getProperty("opponent_name");
      won_text = Helpers.formatString(Ui.loadResource(Rez.Strings.end_opponent_won), {"opponent" => opponent_name});
    }

    findDrawableById("result_won_text").setText(won_text);
    // draw match score or last set score
    var score_text = $.match.getGamesWon(:player_1).toString() + " - " + $.match.getGamesWon(:player_2).toString();
    findDrawableById("result_score").setText(score_text);
    // draw match time
    findDrawableById("result_time").setText(Helpers.formatDuration($.match.getDuration()));
    // draw rallies
    var rallies_text = Ui.loadResource(Rez.Strings.end_total_rallies);
    findDrawableById("result_rallies").setText(Helpers.formatString(rallies_text, {"rallies" => $.match.getTotalRalliesNumber().toString()}));
  }
}

class ResultViewDelegate extends Ui.BehaviorDelegate {
  function initialize() { BehaviorDelegate.initialize(); }

  function onSelect() {
    var save_match_confirmation = new Ui.Confirmation(
        Ui.loadResource(Rez.Strings.end_save_garmin_connect));
    Ui.pushView(save_match_confirmation, new SaveMatchConfirmationDelegate(),
                Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onBack() {
    Ui.switchToView(new GameResultView(), new GameResultViewDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onPreviousPage() { return onNextPage(); }

  function onNextPage() {
    Ui.switchToView(new StatsView(), new StatsViewDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }
}
