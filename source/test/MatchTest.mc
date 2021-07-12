using Toybox.System as Sys;
using Toybox.Math as Math;
using Toybox.WatchUi as Ui;
using Toybox.Lang as Lang;

module MatchTest {
  (:test)
  function testServerInfo(logger) {
    var currentServeInfo;
    var match = new Match(5, :player_1, 0);
    match.start(:player_1);

    currentServeInfo = match.getCurrentServerInfo();
    Sys.println(currentServeInfo);
    Sys.println(:player_1);
    Sys.println(currentServeInfo[:server] == :player_1);
    BetterTest.assertSame(currentServeInfo[:server], :player_1, "Player 1 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 1, "Player one should be on serve 1");

    match.scorePlayer(:player_1);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_1, "Player 1 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 2, "Player one should be on serve 2");

    match.scorePlayer(:player_1);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_1, "Player 1 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 3, "Player one should be on serve 3");

    match.scorePlayer(:player_1);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_1, "Player 1 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 4, "Player one should be on serve 4 but is on serve2: " + currentServeInfo[:serve]);

    return true;
  }
  
  (:test)
  function testServerInfoWithP2TakingFirstPoint(logger) {
    var currentServeInfo;
    var match = new Match(5, :player_1, 0);
    match.start(:player_1);

    currentServeInfo = match.getCurrentServerInfo();
    Sys.println(currentServeInfo);
    Sys.println(:player_1);
    Sys.println(currentServeInfo[:server] == :player_1);
    BetterTest.assertSame(currentServeInfo[:server], :player_1, "Player 1 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 1, "Player one should be on serve 1");

    match.scorePlayer(:player_2);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_2, "Player 2 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 1, "Player 2 should be on serve 1 but is on serve: " + currentServeInfo[:serve]);

    match.scorePlayer(:player_2);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_2, "Player 2 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 2, "Player one should be on serve 2 but is on serve: " + currentServeInfo[:serve]); 

    match.scorePlayer(:player_2);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_2, "Player 2 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 3, "Player one should be on serve 2 but is on serve: " + currentServeInfo[:serve]); 

    return true;
  }

  (:test)
  function testServerInfoWithP2TakingFirstPointAndP1TakingSecondPoint(logger) {
    var currentServeInfo;
    var match = new Match(5, :player_1, 0);
    match.start(:player_1);

    currentServeInfo = match.getCurrentServerInfo();
    Sys.println(currentServeInfo);
    Sys.println(:player_1);
    Sys.println(currentServeInfo[:server] == :player_1);
    BetterTest.assertSame(currentServeInfo[:server], :player_1, "Player 1 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 1, "Player one should be on serve 1");

    match.scorePlayer(:player_2);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_2, "Player 2 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 1, "Player 2 should be on serve 1 but is on serve: " + currentServeInfo[:serve]);

    match.scorePlayer(:player_1);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_1, "Player 1 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 1, "Player 1 should be on serve 1 but is on serve: " + currentServeInfo[:serve]); 

    match.scorePlayer(:player_1);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_1, "Player 1 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 2, "Player one should be on serve 2 but is on serve: " + currentServeInfo[:serve]); 

    match.scorePlayer(:player_1);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_1, "Player 1 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 3, "Player one should be on serve 3 but is on serve: " + currentServeInfo[:serve]); 

    match.scorePlayer(:player_1);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_1, "Player 1 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 4, "Player one should be on serve 4 but is on serve: " + currentServeInfo[:serve]); 

    match.scorePlayer(:player_2);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_2, "Player 2 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 1, "Player 2 should be on serve 1 but is on serve: " + currentServeInfo[:serve]); 

    match.scorePlayer(:player_2);
    currentServeInfo = match.getCurrentServerInfo();
    BetterTest.assertSame(currentServeInfo[:server], :player_2, "Player 2 should be the current server");
    BetterTest.assertEqual(currentServeInfo[:serve], 2, "Player 2 should be on serve 2 but is on serve: " + currentServeInfo[:serve]); 

    return true;
  }
  
  (:test)
  function testMatchWinner(logger) {
    var match = new Match(5, :player_1, 0);
    match.start(:player_1);
    
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_1);
    
    match.nextGame(:player_2);
    
    match.scorePlayer(:player_2);
    match.scorePlayer(:player_2);
    match.scorePlayer(:player_2);
    match.scorePlayer(:player_2);
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_1);
    match.scorePlayer(:player_2);
    match.scorePlayer(:player_2);
    match.scorePlayer(:player_2);
    match.scorePlayer(:player_2);
    match.scorePlayer(:player_2);
    match.scorePlayer(:player_2);
    match.scorePlayer(:player_2);
    
    match.finish();
    
    var winner = match.getWinner();
    Sys.println("winner = " + winner);
    
    var stats = match.getMatchStats();
    Sys.println(stats);
  }

  (:test)
  function testMatchDuration(logger) {
    var elapsedTime = 359;

    var minutes = Math.floor(elapsedTime / 60);
    BetterTest.assertEqual(minutes, 5, "Minutes should be 5 instead got " +  minutes);
    Sys.println("minutes = " + minutes);

    var secondsLeft = elapsedTime - (minutes * 60);
    BetterTest.assertEqual(secondsLeft, 59, "SecondsLeft should be 59 instead got " + secondsLeft);
    Sys.println("seconds = " + secondsLeft);

    var finalTime = Lang.format("$1$:$2$", [minutes, secondsLeft.format("%02d")]);
    BetterTest.assertEqual(finalTime, "5:59", "finalTime should be 5:59 instead got " + finalTime);
    Sys.println("finalTime = " + finalTime);

    return true;
  }
}