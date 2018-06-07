function Experiment(participantId, canvas, mouse, targets)
{
    var id     = Id.generate();
    var self   = this;
    var obs    = new Observations(participantId, id, mouse, targets);    
    var put    = undefined;
    var errors = [];
    var fps    = new Frequency("fps", true);
    
    this.draw = function(canvas) {
        fps.cycle();
    }

    this.startExperiment = function() {
        fps.start();
        obs.startObserving();        

        //Measurements to add: Feature Weights
        self.saveData({"startTime":new Date().toUTCString(), "dimensions": canvas.getDimensions(), "resolution": canvas.getResolution()});
    }

    this.stopExperiment = function () {
        fps.stop();
        obs.stopObserving();        
        
        self.saveData({"stopTime":new Date().toUTCString(), "fps": fps.getHz(), "ops": obs.getHz(), "errors" : errors.concat(obs.getErrors()) });
    }

    this.saveData = function(data) {
        if(!put) {
            put = $.ajax({
                "url   ":"https://api.thesis.markrucker.net/v1/participants/" + participantId + "/experiments/" + id,
                "method":"PUT",
                "data"  : JSON.stringify(data)
            });
        }
        else {
            put.done(function(){
                $.ajax({
                    "url"   :"https://api.thesis.markrucker.net/v1/participants/" + participantId + "/experiments/" + id,
                    "method":"PATCH",
                    "data"  :JSON.stringify(data)
                });
            });
        }
    }
}