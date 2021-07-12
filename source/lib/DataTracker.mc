using Toybox.ActivityMonitor as Monitor;
using Toybox.System as Sys;

class DataTracker {
  hidden var numberOfStepsTaken;
  hidden var numberOfCaloriesBurned;
  hidden var initialSteps;
  hidden var initialCalories;

  function initialize() {
    Sys.println("Doing this tracker initialize thing");
    restart();
  }

  function restart() {
    numberOfStepsTaken = 0;
    numberOfCaloriesBurned = 0;
    var activityInfo = Monitor.getInfo();
    initialSteps = activityInfo.steps;
    initialCalories = activityInfo.calories;
  }

  function update() {
      var activityInfo = Monitor.getInfo();
      numberOfStepsTaken = activityInfo.steps - initialSteps;
      numberOfCaloriesBurned = activityInfo.calories - initialCalories;
  }

  function getCurrentData() {
    update();
    var activityInfo = Monitor.getInfo();
    return {
      :stepsTaken => activityInfo.steps - initialSteps,
      :caloriesBurned => numberOfCaloriesBurned
    };
  }
}