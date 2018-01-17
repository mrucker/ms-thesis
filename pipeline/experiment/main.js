$(document).ready( function () {            
    var canvas  = new Canvas(document.querySelector('#c'));

    if (!canvas.getContext2d) {
        return;//if canvas unsupported code here
    }
    
    var mouse   = new Mouse(canvas);
    var timer   = new Timer(canvas);
    var targets = new Targets(canvas, mouse);
    
    var participant = new Participant();
    var experiment  = new Experiment(participant);

    //experiment.beginExperiment();
    
    canvas.draw = function() {
        targets.draw();
        timer.draw();
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
    
    timer.stopAfter(2000, stopEverything);
    
    startEverything();
});