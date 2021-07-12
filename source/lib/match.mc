using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.ActivityRecording as Recording;
using Toybox.Activity as Activity;
using Toybox.FitContributor as Contributor;
using Toybox.WatchUi as Ui;

var dataTracker;

class Match {

    const FIT_GAME_SCORE_PLAYER_1_ID = 0;
    const FIT_GAME_SCORE_PLAYER_2_ID = 1;
    const FIT_GAME_TIME_ID = 2;
    const FIT_STATS_STEPS_FIELD_ID = 3;

    hidden var started = false;
    hidden var manually_finished = false;
    hidden var type; //type of the match, :friendly or :competition
    hidden var games; //array of all Games containing -1 for a Game not played

    hidden var server; //in double, true if the player 1 (watch carrier) is currently the server
    hidden var currentServe;
    hidden var winner; //store the winner of the match, :player_1 or :player_2
    hidden var opponent_name;
    hidden var opponent_id;

    hidden var session;
    hidden var session_field_game_score_player_1;
    hidden var session_field_game_score_player_2;
    hidden var session_field_game_time;
    hidden var session_field_stats_calories;
    hidden var session_field_stats_steps;

  function initialize(games_to_play, name, id)  {
    // prepare the Games
    games = new List();
    // for (var i = 0; i < games_to_play; i++) {
    //   games.get(i) = -1;
    // }

    opponent_name = name;
    opponent_id = id;

    session = Recording.createSession({:sport => Recording.SPORT_TENNIS, :subSport => Recording.SUB_SPORT_MATCH, :name => Ui.loadResource(Rez.Strings.fit_activity_name)});

    session_field_game_score_player_1 = session.createField("score_you", FIT_GAME_SCORE_PLAYER_1_ID, Contributor.DATA_TYPE_SINT8, {:mesgType => Contributor.MESG_TYPE_LAP, :units => Ui.loadResource(Rez.Strings.fit_score_unit_label)});
    session_field_game_score_player_2 = session.createField("score_opponent", FIT_GAME_SCORE_PLAYER_2_ID, Contributor.DATA_TYPE_SINT8, {:mesgType => Contributor.MESG_TYPE_LAP, :units => Ui.loadResource(Rez.Strings.fit_score_unit_label)});
    session_field_game_time = session.createField("game_time", FIT_GAME_TIME_ID, Contributor.DATA_TYPE_DOUBLE, {:mesgType => Contributor.MESG_TYPE_LAP, :units => Ui.loadResource(Rez.Strings.fit_game_time_unit)});
    session_field_stats_steps = session.createField("steps", FIT_STATS_STEPS_FIELD_ID, Contributor.DATA_TYPE_SINT32, {:mesgType => Contributor.MESG_TYPE_SESSION, :units => Ui.loadResource(Rez.Strings.fit_steps_unit)});

    session.start();
    // Also initialize the datatracker here so it won't get reset every time
    dataTracker = new DataTracker();
  }

  function start(match_beginner) {
    // Start new lap first lap was for warming up//manage activity session
        session_field_game_score_player_1.setData(0);
        session_field_game_score_player_2.setData(0);
    session_field_game_time.setData(0.0);
    session.addLap();

    started = true;
    games.push(new MatchGame(match_beginner));
    server = match_beginner;
    currentServe = 1;
  }

  function nextGame(_beginner) {
        //manage activity session
        session.addLap();

        //alternate beginner
        var i = getCurrentGameIndex();

        //create next set
        games.push(new MatchGame(_beginner));
    }

  function isStarted() {
    return started;
  }

  hidden function end(winner_player) {
        winner = winner_player;

    // Implement this event stuff later
        // $.bus.dispatch(new BusEvent(:onMatchEnd, winner));
    }

  function getGamesNumber() {
        return games.size();
    }

    function getCurrentGameIndex() {
        return games.size() - 1;
    }

  function getCurrentServerInfo() {
    return getCurrentGame().getCurrentServerInfo();
  }

    function getCurrentGame() {
        return games.last();
    }

  function scorePlayer(scorer) {
    if (!hasEnded()) {
      var game = getCurrentGame();
            var previous_rally = game.getRallies().last();
            game.score(scorer);

      var game_winner = isGameWon(game);
      if (game_winner != null)  {
        Sys.println(game_winner == :player_1 ? "game won by player 1" : "game won by player 2");
        game.end(game_winner);

        //manage activity session
                session_field_game_score_player_1.setData(game.getScore(:player_1));
                session_field_game_score_player_2.setData(game.getScore(:player_2));
        session_field_game_time.setData(game.getElapsedTime().toDouble());

        var match_winner = isMatchWon();
        if (match_winner != null) {
          Sys.println(game_winner == :player_1 ? "match won by player 1" : "match won by player 2");

            // Do the match ending awesomeness
        }
      }
    }
  }

  function undo() {
        winner = null;

        var game = getCurrentGame();
        var undone_rally = game.getRallies().last();
        game.undo();
  }

  function isGameWon(game) {
    var scorePlayer1 = game.getScore(:player_1);
    var scorePlayer2 = game.getScore(:player_2);
    if  (scorePlayer1 >= 11 && (scorePlayer1 - scorePlayer2) > 1) {
      return :player_1;
    }
    if  (scorePlayer2 >= 11 && (scorePlayer2 - scorePlayer1) > 1) {
      return :player_2;
    }
    return null;
  }

  function isMatchWon() {
    var winning_games = games.size();
    var player1_games_won = getGamesWon(:player_1);
    if (player1_games_won > winning_games) {
      return :player_1;
    }
    var player2_games_won = getGamesWon(:player_2);
    if (player2_games_won > winning_games) {
      return :player_2;
    }
    return null;
  }

  function getGamesWon(player) {
    var won = 0;
    for (var i = 0; i <= getCurrentGameIndex(); i++) {
      if (games.get(i).getWinner() == player) {
        won++;
      }
    }
    return won;
  }

  function finish() {
    var player_1_games_won = getGamesWon(:player_1);
    var player_2_games_won = getGamesWon(:player_2);

    manually_finished = true;

    if (player_1_games_won > player_2_games_won) {
      winner = :player_1;
      return;
    }
    if (player_2_games_won > player_1_games_won) {
      winner = :player_2;
      return;
    }
    winner = :both;
  }

  function getWinner() {
    return winner;
  }

  function getTotalRalliesNumber() {
        var i = 0;
        var number = 0;
        while(i < games.size() && games.get(i) != -1) {
            number += games.get(i).getRalliesNumber();
            i++;
        }
        return number;
    }

    function getTotalScore(player) {
        var score = 0;
        for(var i = 0; i <= getCurrentGameIndex(); i++) {
            score = score + games.get(i).getScore(player);
        }
        return score;
    }

  function getDuration() {
        var time = getActivity().elapsedTime;
        var seconds = time != null ? time / 1000 : 0;
        return new Time.Duration(seconds);
    }

  function getActivity() {
        return Activity.getActivityInfo();
    }

  function discard() {
        session.discard();
    }

  function save() {
        //session can only be save once
    var stats = $.dataTracker.getCurrentData();
    Sys.println(stats);
    session_field_stats_steps.setData(stats[:stepsTaken]);
        session.save();
    }

    function getMatchStats() {
    var gameStats = new [getGamesNumber()];
    var i = 0;
    while(i < games.size() && games.get(i) != -1) {
      gameStats[i] = games.get(i).getGameStats();
            i++;
        }
    var stats = {
      SquashItConstants.KEY_MATCH_WON => winner == :player_1,
      SquashItConstants.KEY_MATCH_OPPONENT_NAME => opponent_name,
      SquashItConstants.KEY_MATCH_OPPONENT_ID => opponent_id,
      SquashItConstants.KEY_MATCH_GAMES => gameStats
    };
        return stats;
    }

  function hasEnded() {
    return false;
  }
}