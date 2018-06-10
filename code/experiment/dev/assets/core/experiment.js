function Experiment(participantId, canvas, mouse, targets)
{
    var id     = Id.generate();
    var self   = this;
    var errors = [];
    var post   = undefined;
    var obs    = new Observations(participantId, id, mouse, targets);
    var fps    = new Frequency("fps", false);

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
        
        self.saveData({"stopTime":new Date().toUTCString(), "fps": fps.getHz(), "ops": obs.getHz(), "errors" : errors.concat(obs.getErrors()).toDistinct()});
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