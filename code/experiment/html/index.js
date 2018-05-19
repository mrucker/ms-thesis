$(document).ready( function () {
    var canvas  = new Canvas(document.querySelector('#c'));

    if (!canvas.getContext2d) {
        return;//if canvas unsupported code here
    }
    
    //Too unreliable. Works very inconsistently from browser to browser.
    //window.addEventListener('unload', function() { return "abcd"; });
    //window.addEventListener('beforeunload', function() { return "Dude, are you sure you want to refresh? Think of the kittens!"; });
    
    var timer   = new Timer(true);
    var counter = new Counter(3, true);
    var mouse   = new Mouse(canvas);
    var targets = new Targets(mouse);

    var participant = new Participant();
    var experiment  = new Experiment(participant, mouse, targets, canvas);
    
    var dialog1 = $( "#dialog1" );
    var dialog2 = $( "#dialog2" );
    var dialog3 = $( "#dialog3" );   
    
    canvas.draw = function(canvas) {
        experiment.makeObservation();
        
        targets   .draw(canvas);
        counter   .draw(canvas);
        timer     .draw(canvas);
        experiment.draw(canvas);
    };
    
    //canvas .startAnimating();
    //targets.startAppearing();
    //mouse  .startTracking();
    
    var startAnimation = function() {
        canvas .startAnimating();
        counter.startCounting();
        targets.startAppearing();
        mouse.startTracking();
    };
    
    var startExperiment = function () {
        timer.startTiming();
        experiment.beginExperiment();
    }
    
    var stopEverything = function() {        
        timer.stopTiming();        
        mouse.stopTracking();
        canvas.stopAnimating();
        counter.stopCounting();
        targets.stopAppearing();
        experiment.endExperiment();
        experiment.saveObservation(canvas.getWidth(), canvas.getHeight());
        dialog3.dialog("open");
    };
    
    counter.stopAfter( 3000, startExperiment);
    timer  .stopAfter(15000, stopEverything);
    
    dialog1.dialog({ 
        autoOpen   : false , 
        modal      : true  ,
        draggable  : false ,
        dialogClass: "no-x",
        buttons    : [
            { text: "Next", click: function() { dialog1.dialog( "close" ); dialog2.dialog("open");} }
        ]
    });
    
    dialog2.dialog({ 
        autoOpen   : false , 
        modal      : true  ,
        draggable  : false ,
        dialogClass: "no-x",
        buttons    : [
            { text: "Begin", click: function() { dialog2.dialog("close"); startAnimation(); } }
        ]
    });
    
    dialog3.dialog({
        autoOpen   : false ,
        modal      : true  ,
        draggable  : false ,
        dialogClass: "no-x",
        buttons    : [
            { text: "Repeat" , click: function() { 
                dialog3.dialog("close"); 
                
                experiment.reset();
                timer     .reset();
                counter   .reset();
                
                startAnimation(); 
            } },
            //{ text: "Updates", click: function() {  } }
        ],
    });
    
    dialog1.dialog("open");
    
    $(window).resize(function() {
        $("#dialog1").dialog("option", "position", {my: "center", at: "center", of: window});
        $("#dialog2").dialog("option", "position", {my: "center", at: "center", of: window});
        $("#dialog3").dialog("option", "position", {my: "center", at: "center", of: window});
    });
});