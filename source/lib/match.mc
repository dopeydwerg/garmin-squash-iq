class Match {
  hidden var started = false;

  function initialize()  {
    started = true;
  }

  function isInProgress() {
    return started;
  }
}