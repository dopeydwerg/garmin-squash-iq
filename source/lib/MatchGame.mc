using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.ActivityRecording as Recording;
using Toybox.Activity as Activity;
using Toybox.FitContributor as Contributor;
using Toybox.WatchUi as Ui;

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
    if (rallies.isEmpty()) {
      return {
        :server => beginner,
        :serve => 1
      };
    }

    if (getRalliesNumber() == 2) {
      if (rallies.get(1) != rallies.get(0)) {
        return {
          :server => rallies.get(1),
          :serve => 1
        };
      }
    }

    var server = rallies.last();
    Sys.println(server == :player_1 ? "server = player 1" : "server = player 2");
    var serve = 0;
    var counter = getRalliesNumber() - 1;
    Sys.println("counter = : " + counter);
    var current = rallies.get(counter);
    Sys.println(current == :player_1 ? "current = player 1" : "current = player 2");
    if (current != server) {
      return {
        :server => server,
        :serve => 1
      };
    }

    while (current == server && counter > 0) {
      serve++;
      counter--;
      current = rallies.get(counter);
      Sys.println(current == :player_1 ? "current = player 1" : "current = player 2");
    }

    // for some reason this needs to be handled else the count is off
    if (counter == 0 && server == beginner && getRalliesNumber() <= 2) {
      serve++;
      serve++;
    }
    
    if (counter == 0 && server != beginner) {
      serve++;
    }
    
    return {
      :server => server,
      :serve => serve
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
    var minutes = elapsedTime % 60;
    Sys.println("minutes are : " + minutes);
    if (!minutes) {
      minutes = 0;
    }
    var seconds = (elapsedTime - (minutes * 60));
    return Lang.format("$1$:$2$", [minutes, seconds.format("%02d")]);
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