function Experiment(participant, mouse, targets)
{
    var id           = Id.generate();
    var startTime    = undefined;
    var stopTime     = undefined;
    var observations = [];
    
    this.isStarted = function() { return startTime != undefined; };
    this.isStopped = function() { return stopTime  != undefined; };
    
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
        
        var states = observations.map(function(observation, i) {
            
            var mpX = observation.mouseData[0];
            var mpY = observation.mouseData[1];
            var mvX = i <= 0 ? 0 : mpX - observations[i-1].mouseData[0];
            var mvY = i <= 0 ? 0 : mpY - observations[i-1].mouseData[1];
            var maX = i <= 1 ? 0 : mvX - (observations[i-1].mouseData[0] - observations[i-2].mouseData[0]);
            var maY = i <= 1 ? 0 : mvY - (observations[i-1].mouseData[1] - observations[i-2].mouseData[1]);
            var mjX = i <= 2 ? 0 : maX - (observations[i-1].mouseData[0] - 2*observations[i-2].mouseData[0] + observations[i-3].mouseData[0]);
            var mjY = i <= 2 ? 0 : maY - (observations[i-1].mouseData[1] - 2*observations[i-2].mouseData[1] + observations[i-3].mouseData[1]);
            
            var dist = function(x1,y1,x2,y2) { return Math.sqrt(Math.pow(x1-x2,2)+Math.pow(y1-y2,2)); };
            
            var top5 = observation.targetData.sort(function (a,b) { return dist(mpX,mpY,a[0],a[1]) - dist(mpX,mpY,b[0],b[1]); }).slice(0,5);            
            
            return [mpX, mpY, mvX, mvY, maX, maY, mjX, mjY].concat(top5[0]).concat(top5[1]).concat(top5[2]).concat(top5[3]).concat(top5[4]);
        });
        
        var actions = states.map(function(state, i) {
            return i==0 ? [0,0] : state.slice(0,2).map(function(s,ii) { return s-states[i-1][ii]; });
        });
        
        
        
        console.log(JSON.stringify(states));
        console.log(JSON.stringify(actions));
    }

    this.makeObservation = function() {
        if(this.isStarted() && !this.isStopped()) {
            observations.push({"mouseData": mouse.getData(), "targetData": targets.getData() });
        }
    };

    function saveObservation() {
        
    };
}