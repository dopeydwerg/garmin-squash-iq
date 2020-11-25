using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.ActivityRecording as Recording;
using Toybox.Activity as Activity;
using Toybox.FitContributor as Contributor;
using Toybox.WatchUi as Ui;

class MatchGame {

	hidden var beginner; //store the beginner of the set, :player_1 or :player_2

	hidden var rallies; //list of all rallies

	hidden var scores; //dictionnary containing players current scores
	hidden var winner; //store the winner of the match, :player_1 or :player_2

	function initialize(player) {
		beginner = player;
		rallies = new List();
		scores = {:player_1 => 0, :player_2 => 0};
	}

  function score(player) {
    if (!hasEnded()) {
      rallies.push(player);
      scores[player]++;
    }
  }

  function hasEnded() {
    return false;
  }

  function getRallies() {
    return rallies;
  }
}