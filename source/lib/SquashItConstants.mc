module SquashItConstants {
  //! Message type values received or sent to the partner app
  enum {
    MESSAGE_TYPE_SAVE_MATCH = 1,
    MESSAGE_TYPE_PLAYER_LIST = 2,
    MESSAGE_TYPE_PLAYER_INFO = 3,
    MESSAGE_TYPE_PLAYER_DATA = 4
  }

  //! Match type values
  enum {
    KEY_MESSAGE_TYPE = -1,
    KEY_MESSAGE_PAYLOAD = -2,

    KEY_MATCH_OPPONENT_NAME = 0,
    KEY_MATCH_OPPONENT_ID = 1,
    KEY_MATCH_WON = 2,
    KEY_MATCH_GAMES = 3,

    KEY_GAME_DURATION = 4,
    KEY_GAME_RALLIES = 5,
    KEY_GAME_BEGINNER = 6,
    KEY_GAME_WINNER = 7,
    KEY_GAME_STEPS = 8
  }

  //! Game type values
  enum {
    YOU,
    OPP
  }
}