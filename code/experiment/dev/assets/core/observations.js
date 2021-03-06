function Observations(participantId, experimentId, mouse, targets, canvas)
{
    var self    = this;
    var started = false;
    var stopped = false;    
    var errors  = [];
    
	var touchCount = 0;
	var rewardEarned = 0;
	
    var payloadSize  = 30;
    var obsInQueue   = [];
    var obsInMemory  = [];
    var saveRequests = [];

    var ops     = new Frequency("ops", false);
    var ops_Hz  = 30;
    
    var maxAttempts     = 2;
    var maxObservations = 15*ops_Hz; //to protect myself from a bug writing a crazy amount of data.

    this.getObservationCount = function() {
        return obsInMemory.length;
    }

    this.getTouchCount = function() {
        return touchCount;
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
        if(started && !stopped && obsInMemory.length < maxObservations) {

            ops.cycle();

            //25% reduction in data transmission if I send observation as array of arrays rather than key/values
            var observation = mouse.getData().concat(canvas.getData()).concat(targets.getData());
            
			touchCount   += targets.touchCount();
			rewardEarned += targets.rewardEarned();
			
            obsInMemory.push(observation);
            obsInQueue .push(observation);

            if(obsInQueue.length >= payloadSize) {
                save(obsInQueue.slice(0, payloadSize));
                obsInQueue = obsInQueue.slice(payloadSize);
            }

            setTimeout(observe, 1000/ops.correctedHz(1,ops_Hz));
        }
    };
    
    function save(obsToSave, attempt) {

        if(obsToSave.length == 0) {
            return;
        }

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
                "data"  : JSON.stringify([saveRequests.length + 1, obsToSave])
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