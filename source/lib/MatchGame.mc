using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.ActivityRecording as Recording;
using Toybox.Activity as Activity;
using Toybox.FitContributor as Contributor;
using Toybox.WatchUi as Ui;
using Toybox.Math as Math;

class MatchGame {

	hidden var beginner; //store the beginner of the Game, :player_1 or :player_2

	hidden var rallies; //list of all rallies

	hidden var scores; //dictionnary containing players current scores
	hidden var winner; //store the winner of the match, :player_1 or :player_2

  hidden var startTime;
  hidden var finishTime;

	function initialize(player) {
		beginner = player;
		rallies = new List();
		scores = {:player_1 => 0, :player_2 => 0};
    startTime = Time.now();
	}

  function score(player) {
    if (!hasEnded()) {
      rallies.push(player);
      scores[player]++;
      Sys.println(scores);
    }
  }

  function undo() {
		if(rallies.size() > 0) {
			winner = null;
			var rally = rallies.pop();
			scores[rally]--;
		}
	}

  function end(player) {
    winner = player;
    finishTime = Time.now();
  }

  function getCurrentServerInfo() {
    if (getRalliesNumber() == getScore(beginner)) {
      return {
        :server => beginner,
        :serve => getRalliesNumber() + 1
      };
    }

    var current = rallies.last();
    var count = 1;
    Sys.println("totalrallies = " + getRalliesNumber());
    for (var i = getRalliesNumber() - 2; i >= 0; i--) {
      var previous = rallies.get(i);
      Sys.println(Lang.format("current = $1$ previous $2$ i = $3$", [current == :player_1 ? "p_1" : "p_2", previous == :player_1 ? "p_1" : "p_2", i]));
      if (current != previous) {
        return {
          :server => current,
          :serve => count
        };
      }
      count++;
    }

    return {
      :server => current,
      :serve => count
    };
  }

  function getElapsedTime() {
    var endTime = Time.now();   
    Sys.println(endTime);
    if (finishTime) {
      endTime = finishTime;
    }
    var elapsedTime = endTime.subtract(startTime).value();
    Sys.println("elapsed seconds : " + elapsedTime);
    var minutes = Math.floor(elapsedTime / 60);
    Sys.println("minutes are : " + minutes);
    var secondsLeft = elapsedTime - (minutes * 60);
    Sys.println("secondsLeft = " + secondsLeft);
    return Lang.format("$1$.$2$", [minutes.format("%2d"), secondsLeft.format("%02d")]);
  }

  function getScore(player) {
    return scores[player];
  }

  function getRalliesNumber() {
    return rallies.size();
  }

  function getWinner() {
    return winner;
  }

  function getBeginner() {
    return beginner;
  }

  function hasEnded() {
    return false;
  }

  function getRallies() {
    return rallies;
  }
}