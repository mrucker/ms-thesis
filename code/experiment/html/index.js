$(document).ready( function () {
    var canvas  = new Canvas(document.querySelector('#c'));

    if (!canvas.getContext2d) {
        return;//if canvas unsupported code here
    }
    
    //Unload events are very inconsistent from browser to browser
    //window.addEventListener('unload', function() { return "abcd"; });
    //window.addEventListener('beforeunload', function() { return "Dude, are you sure you want to refresh? Think of the kittens!"; });
    
    var timer   = new Timer(true);
    var counter = new Counter(3, true);
    var mouse   = new Mouse(canvas);
    var targets = new Targets(mouse);

    var participant = new Participant();
    var experiment  = new Experiment(participant, mouse, targets, canvas);
        
    canvas.draw = function(canvas) {
        experiment.makeObservation();
        
        mouse     .draw(canvas);
        targets   .draw(canvas);
        counter   .draw(canvas);
        timer     .draw(canvas);
        experiment.draw(canvas);
    };

    var startAnimation = function(dialogHandle) {
        timer  .stopAfter(15000, function () { stopEverything(); dialogHandle.dialog("open"); });
        canvas .startAnimating();
        counter.startCounting();
        targets.startAppearing();
        mouse  .startTracking();
    };

    var stopAnimation = function() {
        mouse  .stopTracking();
        targets.stopAppearing();
        counter.stopCounting();
        canvas .stopAnimating();
    };

    var startExperiment = function () {
        timer.startTiming();
        experiment.beginExperiment();
    }

    var stopExperiment = function() {
        timer     .stopTiming();
        experiment.endExperiment();
        experiment.saveObservation(canvas.getWidth(), canvas.getHeight());
    };

    var stopEverything = function() {
        stopAnimation();
        stopExperiment();
    };

    var resetEverything = function() {
        experiment.reset();
        timer     .reset();
        counter   .reset();
    };
    
    counter.stopAfter( 3000, startExperiment);

    dialogSetup($("#dialog0"), "Next"  , function() { $("#dialog1").dialog("open");       });
    dialogSetup($("#dialog1"), "Next"  , function() { $("#dialog2").dialog("open");       });
    dialogSetup($("#dialog2"), "Next"  , function() { $("#dialog3").dialog("open");       });
    dialogSetup($("#dialog3"), "Agree" , function() { $("#dialog4").dialog("open");       });
    dialogSetup($("#dialog4"), "Next"  , function() { $("#dialog5").dialog("open");       });
    dialogSetup($("#dialog5"), "Begin" , function() { resetEverything(); startAnimation($("#dialog6"));});
    dialogSetup($("#dialog6"), "Begin" , function() { resetEverything(); startAnimation($("#dialog7"));});
    dialogSetup($("#dialog7"), "Repeat", function() { resetEverything(); startAnimation($("#dialog6"));});
    
    $("#dialog0").dialog("open");
    
    $(window).resize(function() {
        $(".dialog").dialog("option", "position", {my: "center", at: "center", of: window});
    });
});


function dialogSetup(dialogHandle, buttonText, clickAction) {
    dialogHandle.dialog({ 
        
        autoOpen   : false , 
        modal      : true  ,
        draggable  : false ,
        dialogClass: "no-x",
        buttons    : [
            { text: buttonText, click: function() { dialogHandle.dialog("close"); clickAction(); } }
        ],
        width      : "90%",
        create     : function( event, ui ) { $(this).parent().css("maxWidth", "400px"); }
    });
}