using Toybox.System as Sys;

module MatchTest {
  (:test)
  function testServerInfo(logger) {
    var match = new Match(9, :player_1);

    match.score(:player_1);
  }
}