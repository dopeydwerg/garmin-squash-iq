using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.ActivityRecording as Recording;
using Toybox.Activity as Activity;
using Toybox.FitContributor as Contributor;
using Toybox.WatchUi as Ui;

class Match {
  hidden var started = false;
  hidden var type; //type of the match, :friendly or :competition
	hidden var games; //array of all sets containing -1 for a set not played

	hidden var server; //in double, true if the player 1 (watch carrier) is currently the server
	hidden var winner; //store the winner of the match, :player_1 or :player_2

  function initialize(games_to_play,  match_beginner)  {
    started = true;

    // prepare the sets
    games = new [games_to_play];
    games[0] = new MatchGame(match_beginner);
    for (var i = 1; i < games_to_play; i++) {
      games[i] = -1;
    }
  }

  function isInProgress() {
    return started;
  }

  function getSetsNumber() {
		return games.size();
	}

	function getCurrentSetIndex() {
		var i = 0;
		while(i < games.size() && games[i] != -1) {
			i++;
		}
		return i - 1;
	}

	function getCurrentSet() {
		return games[getCurrentSetIndex()];
	}

  function scorePlayer(scorer) {
    if (!hasEnded()) {
      var game = getCurrentSet();
			var previous_rally = game.getRallies().last();
			game.score(scorer);
    }
  }

  function hasEnded() {
    return false;
  }
}