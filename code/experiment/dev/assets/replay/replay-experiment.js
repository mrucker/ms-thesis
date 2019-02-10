function ReplayExperiment(canvas, observations, rewardId, frameRate)
{
    var self   = this;

    var mouse   = new ReplayMouse(observations);
    var targets = new ReplayTargets(observations, mouse, rewardId);

    var fps    = new Frequency("fps", false);
	var fps_Hz = frameRate;

	var currentObservation = 0;

    this.run = function() {
        if(!canvas.getContext2d()) {
            return $.Deferred.reject("HTML5 Canvas is not supported on this device");
        }
        else {
			var deferred = $.Deferred();

			canvas.draw = function() {
				targets.draw(canvas);
				mouse  .draw(canvas);
				self   .draw(canvas);
			};

			canvas.startAnimating();

			play(deferred);

			return deferred;
		}
    }

	this.showObservation = function(i) {

		currentObservation = i;

		mouse.showObservation(i);
		targets.showObservation(i);

	}
	
    this.draw = function(canvas) {
        fps.cycle();
    }

	function play(deferred) {				
		
		self.showObservation(currentObservation);
		
		currentObservation++;
		
		if(currentObservation < 450) {
			setTimeout(function() { play(deferred) }, 1000/fps.correctedHz(1,fps_Hz));
		}
		else {
			deferred.resolve();
		}
	}
}