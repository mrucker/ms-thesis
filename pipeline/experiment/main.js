$(document).ready( function () {            
    var canvas  = new Canvas(document.querySelector('#c'));

    if (!canvas.getContext2d) {
        return;//if canvas unsupported code here
    }
    
    var timer   = new Timer(true);
    var mouse   = new Mouse(canvas);    
    var targets = new Targets(mouse);
    
    var participant = new Participant();
    var experiment  = new Experiment(participant);
    
    canvas.draw = function(canvas) {
        targets.draw(canvas);
        timer.draw(canvas);
    };
    
    var startEverything = function() {
        timer.startTiming();
        mouse.startTracking();
        canvas.startAnimating();
        targets.startAppearing();
        experiment.beginExperiment();
    };
    
    var stopEverything = function() {
        timer.stopTiming();
        mouse.stopTracking();
        canvas.stopAnimating();
        targets.stopAppearing();
        experiment.endExperiment();
    };
    
    timer.stopAfter(10000, stopEverything);
    
    startEverything();
});