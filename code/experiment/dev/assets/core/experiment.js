function Experiment(canvas, participantId, rewardId)
{
    var id     = Id.generate();
    var self   = this;
    var errors = [];
    var post   = undefined;

    var mouse   = new Mouse(canvas);
    var targets = new Targets(mouse, rewardId);
    var counter = new Counter(3, 3000, true);
    var timer   = new Timer(15000, true);

    var obs = new Observations(participantId, id, mouse, targets, canvas);
    var fps = new Frequency("fps", false);

    this.run = function() {
        if(!canvas.getContext2d()) {
            return $.Deferred.reject("HTML5 Canvas is not supported on this device");
        }
        else {
			var deferred = $.Deferred();
			
			canvas.draw = function() {
				targets.draw(canvas);
				counter.draw(canvas);
				timer  .draw(canvas);
				mouse  .draw(canvas);
				self   .draw(canvas);
			};
			
			//runCountdown()
			canvas .startAnimating();
			counter.startCounting();
			mouse  .startTracking();

			counter.onElapsed(function() { 
				//runTask()
				startExperiment();
        
				targets.startAppearing();
				timer  .startTiming();
				timer  .onElapsed(function() { 
					//runCleanup()
					mouse  .stopTracking();
					targets.stopAppearing();
					counter.stopCounting();
					canvas .stopAnimating();
					timer  .stopTiming();

					stopExperiment();
					
					deferred.resolve();
				})
			});
			
			return deferred;
        }
    }

    this.draw = function(canvas) {
        fps.cycle();
    }
    
    function startExperiment() {
        fps.start();
        obs.startObserving();

        //not knowing how I may or may not want to modify opacity and color rules in the future I'm not going to guess and store
        //I do likely want to store feature weights still though. Perhaps I need to make a comprehensive list of features and use these.
        
		console.log('rewardId: ' + rewardId);
		
        //Measurements to add: feature weights
        saveData({
			"startTime" :new Date().toUTCString()
			, "dimensions": canvas.getDimensions()
			, "resolution": canvas.getResolution()
			, "rewardId"  : rewardId
		});
    }

    function stopExperiment() {
        fps.stop();
        obs.stopObserving();
        
		var touchCount = obs.getTouchCount();
		var observationCount = obs.getObservationCount();
		
        //Measurements to add: touch count, observation count,
        saveData({
			"stopTime" :new Date().toUTCString()
			, "fps"    : fps.getHz()
			, "ops"    : obs.getHz()
			, "errors" : errors.concat(obs.getErrors()).toDistinct()
			, "o_n"    : observationCount
			, "t_n"    : touchCount
		});
    }
	
    function saveData(data) {        
        if(!post) {
            post = $.ajax({
                "url"   :"https://api.thesis.markrucker.net/v1/participants/" + participantId + "/experiments/" + id,
                "method":"POST",
                "data"  : JSON.stringify(data)
            });
        }
        else {
            post.done(function() {
                $.ajax({
                    "url"   :"https://api.thesis.markrucker.net/v1/participants/" + participantId + "/experiments/" + id,
                    "method":"PATCH",
                    "data"  : JSON.stringify(data)
                });
            });
        }
    }
}