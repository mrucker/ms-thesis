$(document).ready( function () {
    var canvas  = new Canvas(document.querySelector('#c'));

    if (!canvas.getContext2d) {
        return;//if canvas unsupported code here
    } else {
        canvas.resize($(window).width() - 10, $(window).height() - 10);
    
        window.addEventListener('resize', function() {
            canvas.resize($(window).width() - 10, $(window).height() - 10);
        });
    }
    
    //Unload events are very inconsistent from browser to browser
    //window.addEventListener('unload', function() { return "abcd"; });
    //window.addEventListener('beforeunload', function() { return "Dude, are you sure you want to refresh? Think of the kittens!"; });
    
    var timer   = new Timer(15000, true);
    var counter = new Counter(3, 3000, true);
    var mouse   = new Mouse(canvas);
    var targets = new Targets(mouse);

    var participant = new Participant();
    var experiment  = new Experiment(participant, mouse, targets, canvas);

    canvas.draw = function(canvas) {
        
        mouse     .draw(canvas);
        targets   .draw(canvas);
        counter   .draw(canvas);
        timer     .draw(canvas);
        experiment.draw(canvas);
    };

    var startAnimation = function(contentId) {
        
        counter.onElapsed(startObserving);
        timer  .onElapsed(function () { stopEverything(); showModalContent(contentId); });

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

    var startObserving = function () {
        timer     .startTiming();
        experiment.startObserving();
    }

    var stopObserving = function() {
        timer     .stopTiming();
        experiment.stopObserving();
    };

    var stopEverything = function() {
        stopAnimation();
        stopObserving();
    };

    var resetEverything = function() {
        experiment.reset();
        timer     .reset();
        counter   .reset();
    };

    $("#modal").on('hidden.bs.modal', function (e) {
        var contentId = $(this).data("contentId");
        
        if(contentId == "dialog0") { showModalContent("dialog1"); }
        if(contentId == "dialog1") { showModalContent("dialog2"); }
        if(contentId == "dialog2") { showModalContent("dialog3"); }
        if(contentId == "dialog3") { showModalContent("dialog4"); }
        if(contentId == "dialog4") { 
            participant.saveData(getDemographics());
            showModalContent("dialog5"); 
        }
        if(contentId == "dialog5") { resetEverything(); startAnimation("dialog6"); }
        if(contentId == "dialog6") { resetEverything(); startAnimation("dialog7"); }
        if(contentId == "dialog7") { resetEverything(); startAnimation("dialog6"); }
    })
    
    showModalContent("dialog0");
        
    function getDemographics() {
        return "{" + $("#modal form").serializeArray().map(function(o) { return '"' + o.name +'":"' + o.value + '"' }).join(",") + "}";
    }
    
    function showModalContent(contentId) {
        $("#modal").data("contentId", contentId);

            $("#modalTitle" ).html($("#" + contentId).data('title'));
            $("#modalBody"  ).html($("#" + contentId).html());
            $("#modalButton").html($("#" + contentId).data('btnTxt'));

        $("#modal").removeClass("fade").addClass($("#"+ contentId).data("fadeIn"));
        $('#modal').modal('show');
        $("#modal").removeClass("fade").addClass($("#"+ contentId).data("fadeOut"));
    }
});