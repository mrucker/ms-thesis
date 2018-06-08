function Observations(participantId, experimentId, mouse, targets, maxPerSession)
{
    var self    = this;
    var started = false;
    var stopped = false;
    var touches = 0;
    var errors  = [];

    var maxAttempts  = 1;
    var maxPerSave   = 900;
    var minPerSave   = 60;
    var obsInQueue   = [];
    var obsInMemory  = [];
    var saveRequests = [];

    var ops     = new Frequency("ops", false);
    var ops_Hz  = 60;

    this.getObservations = function() {
        return obsInMemory;
    }

    this.getTouches = function() {
        return touches;
    }
    
    this.getHz = function () {
        return ops.getHz();
    }
    
    this.getErrors =function () {
        return errors;
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

        save(obsInQueue);
        obsInQueue = [];
        
        //console.log(JSON.stringify(Observations.toStates(obsInMemory)));
        //console.log(JSON.stringify(Observations.toActions(obsInMemory)));
    }

    function observe() {
        if(started && !stopped && obsInMemory.length < maxPerSession) {

            ops.cycle();

            //25% reduction in data transmission if I send observation as array of arrays rather than key/values
            var observation = [obsInMemory.length+1, mouse.getData().concat(targets.getData().toFlat())];
            //var observation = mouse.getData().concat(targets.getData().toFlat());
            
            obsInMemory.push(observation);
            obsInQueue .push(observation);

            if(obsInQueue.length >= minPerSave) {
                save(obsInQueue.slice(0, maxPerSave));
                obsInQueue = obsInQueue.slice(maxPerSave);
            }

            touches += targets.touchCount();

            setTimeout(observe, 1000/ops.correctedHz(1,ops_Hz));
        }
    };
    
    function save(obsToSave, attempt) {

        attempt = attempt || 1;

        if(!obsToSave) {
            errors.push("Save command called without any data on attempt " + attempt + ".");
        }
        else if(attempt > maxAttempts) {
            errors.push("Gave up trying to save observations after three failed attempts. " + obsToSave.length + " observations lost." );
        }
        else {
            var saveRequest = $.ajax({
                "url"   :"https://api.thesis.markrucker.net/v1/participants/" + participantId + "/experiments/" + experimentId + "/observations/",
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