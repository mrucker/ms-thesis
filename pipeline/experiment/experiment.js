function Experiment(participant)
{
    var id        = Id.generate();
    var startTime = undefined;
    var stopTime  = undefined;

    var post = $.ajax({
        url   :"https://api.thesis.markrucker.net/v1/participants/" + participant.getId() + "/experiments",
        method:"POST",
        data  :id
    });

    this.beginExperiment = function() {

        startTime = new Date().toUTCString();        
        
        post.done(function(data){
            $.ajax({
                url   :"https://api.thesis.markrucker.net/v1/participants/" + participant.getId() + "/experiments/" + id,
                method:"PATCH",
                data  :JSON.stringify({"startTime":startTime})
            });
        });
    }

    this.endExperiment = function () {

        stopTime = new Date().toUTCString();

        post.done(function(data){
            $.ajax({
                url   :"https://api.thesis.markrucker.net/v1/participants/" + participant.getId() + "/experiments/" + id,
                method:"PATCH",
                data  :JSON.stringify({"stopTime":stopTime})
            });
        });
    }

    function makeObservation() {

    };

    function saveObservation() {

    };
}