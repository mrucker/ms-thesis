function Experiment(participantId, mouse, targets)
{
    var id           = Id.generate();
    var self         = this;
    var startTime    = undefined;
    var stopTime     = undefined;
    var observations = new Observations(participantId, id, mouse, targets);
    var errors       = [];
    var putRequest   = undefined;
    
    this.draw = function(canvas) {
    }

    this.startExperiment = function() {

        observations.startObserving();        

        //Measurements to add: Feature Weights, Window Size, Window Resolution
        self.saveData({"startTime":new Date().toUTCString()});
    }

    this.stopExperiment = function () {
        observations.stopObserving();        

        //Measurements to add: FPS, OPS, errorMessages
        self.saveData({"stopTime":new Date().toUTCString()});
    }

    this.saveData = function(data) {
        if(!putRequest) {
            putRequest = $.ajax({
                "url   ":"https://api.thesis.markrucker.net/v1/participants/" + participantId + "/experiments/" + id,
                "method":"PUT",
                "data"  : JSON.stringify(data)
            });
        }
        else {
            putRequest.done(function(){
                $.ajax({
                    "url"   :"https://api.thesis.markrucker.net/v1/participants/" + participantId + "/experiments/" + id,
                    "method":"PATCH",
                    "data"  :JSON.stringify(data)
                });
            });
        }
    }
}