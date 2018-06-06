function Observations(participantId, experimentId, mouse, targets)
{
    var self    = this;
    var started = false;
    var stopped = false;
    var touches = 0;
    var errors  = [];

    var maxToSave    = 900;
    var minToSave    = 30;
    var obsInQueue   = [];
    var obsInMemory  = [];
    var saveRequests = [];

    var ops     = new Frequency("ops", true);
    var ops_Hz  = 60;

    this.getObservations = function() {
        return obsInMemory;
    }

    this.getTouches = function() {
        return touches;
    }

    this.startObserving = function() {

        if(started && stopped) {
            errors.push("Observations are not valid unless taken in one continuous timeframe. Please start a new experiment instead of resuing an old one.");
        }

        if(started && !stopped) {
            errors.push("Someow the observations were already started (and not stopped) before starting again. Perhaps they were never stopped from a previous experiment?");
        }

        started = true;
        ops.start();

        setTimeout(observe, 1000/ops.correctedHz(1,ops_Hz));
    }

    this.stopObserving = function() {

        if(!started) {
            errors.push("Something appears to have gone wrong. Observations were never started for the experiment.");
        }

        stopped = true;
        ops.stop();

        save();
        
        console.log(JSON.stringify(Observations.toStates(obsInMemory)));
        console.log(JSON.stringify(Observations.toActions(obsInMemory)));
    }

    function observe() {
        if(started && !stopped) {

            ops.cycle();

            var observation = {"mouseData": mouse.getData(), "targetData": targets.getData() };
            
            obsInMemory.push(observation);
            obsInQueue .push(observation);

            if(obsInQueue.length >= minToSave) {
                save(obsInQueue.slice(0, maxToSave));                
                obsInQueue = obsInQueue.slice(maxToSave);
            }

            touches += targets.touchCount();

            setTimeout(observe, 1000/ops.correctedHz(1,ops_Hz));
        }
    };
    
    function save(obsToSave, attempt) {

        attempt = attempt || 1;

        if(!obsToSave) {
            errors.push("Save command called without any data. Attempt " + attempt + ".");
        }
        else if(attempt > 3) {
            errors.push("Gave up trying to save observations after three failed attempts. " + obsToSave.length + " observations lost." );
        }
        else {
            var saveRequest = $.ajax({
                "url   ":"https://api.thesis.markrucker.net/v1/participants/" + participantId + "/experiments/" + experimentId + "/observations/",
                "method":"POST",
                "data"  : JSON.stringify(obsToSave)
            }).fail(function() {
                save(obsToSave, attempt+1);
            });
            
            saveRequests.push(saveRequest);
        }
    }
}

Observations.toStates = function(observations) {
    var states = observations.slice(3).map(function(observation, i) {

        var mp_0 = observations[3+i-0].mouseData.slice(0,2); //gives us [x,y];
        var mp_1 = observations[3+i-1].mouseData.slice(0,2); //gives us [x,y];
        var mp_2 = observations[3+i-2].mouseData.slice(0,2); //gives us [x,y];
        var mp_3 = observations[3+i-3].mouseData.slice(0,2); //gives us [x,y];

        return mp_0.concat(mp_1).concat(mp_2).concat(mp_3).concat(observation.targetData.toFlat());
    });
    
    return states;
}

Observations.toActions = function(observations) {
    var actions = observations.slice(3).map(function(obs, i) {

        var thisState_x = observations[3+i-0].mouseData[0];
        var thisState_y = observations[3+i-0].mouseData[1];
        var prevState_x = observations[3+i-1].mouseData[0];
        var prevState_y = observations[3+i-1].mouseData[1];

        return i == 0 ? [0,0] : [ thisState_x - prevState_x, thisState_y - prevState_y ];            
    });
    
    return actions;
}