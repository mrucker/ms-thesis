function Experiment(participant, mouse, targets, canvas)
{
    var id           = Id.generate();
    var self         = this;
    var startTime    = undefined;
    var stopTime     = undefined;
    var observations = [];    
    var touchedPrev  = [];
    var touchedCnt   = 0;

    var ops     = new Frequency("ops", true);
    var ops_Hz  = 60;

    var post = $.ajax({
        url   :"https://api.thesis.markrucker.net/v1/participants/" + participant.getId() + "/experiments",
        method:"POST",
        data  :id
    });
    
    this.draw = function(canvas) {
        /*var context   = canvas.getContext2d();

        context.save();
        context.fillStyle    = 'rgb(100,100,100)';
        context.font         = '48px Arial';
        context.textAlign    = 'right';
        context.textBaseline = 'top';
        context.fillText(touchedCnt, canvas.getWidth(), 0);
        context.restore();*/
    }

    this.reset = function() {
        startTime    = undefined;
        stopTime     = undefined;
        observations = [];
        touchedCnt   = 0;
    }

    this.startObserving = function() {
        
        startTime    = new Date().toUTCString();
        stopTime     = undefined;
        observations = [];
        touchedCnt   = 0;

        //Measurements to add: FPS, OPS, Feature Weights, Window Size, Window Resolution
        self.saveData({"startTime":startTime});

        ops.start();
        setTimeout(observe, 1000/ops.correctedHz(1,ops_Hz));
    }

    this.stopObserving = function () {

        stopTime = new Date().toUTCString();
        ops.stop();

        self.saveData({"stopTime":stopTime});
    }

    this.saveData = function(data) {
        post.done(function(){
            $.ajax({
                "url"   :"https://api.thesis.markrucker.net/v1/participants/" + participant.getId() + "/experiments/" + id,
                "method":"PATCH",
                "data"  :JSON.stringify(data)
            });
        });
    }
        
    this.saveObservation = function() {
        var states = observations.slice(3).map(function(observation, i) {

            var mp_0 = observations[3+i-0].mouseData.slice(0,2); //gives us [x,y];
            var mp_1 = observations[3+i-1].mouseData.slice(0,2); //gives us [x,y];
            var mp_2 = observations[3+i-2].mouseData.slice(0,2); //gives us [x,y];
            var mp_3 = observations[3+i-3].mouseData.slice(0,2); //gives us [x,y];

            return mp_0.concat(mp_1).concat(mp_2).concat(mp_3).concat(observation.targetData.toFlat());
        });

        var actions = states.map(function(state, i) {
            if(i==0) return [0,0];

            var thisState_x = states[i-0][0];
            var thisState_y = states[i-0][1];
            var prevState_x = states[i-1][0];
            var prevState_y = states[i-1][1];

            return [ thisState_x - prevState_x, thisState_y - prevState_y ];            
        });

        touchedPrev.push(touchedCnt);

        //console.log(JSON.stringify(touchedPrev).replace('[','').replace(']','').split(',').join('\r\n'));
        //console.log(JSON.stringify(states));
        //console.log(JSON.stringify(actions));
        //console.log(canvas.getWidth() + "," + canvas.getHeight());
    };

    function observe() {

        if(startTime && !stopTime) {

            ops.cycle();

            observations.push({"mouseData": mouse.getData(), "targetData": targets.getData() });

            touchedCnt += targets.touchCount();

            setTimeout(observe, 1000/ops.correctedHz(1,ops_Hz));
        }
    }
}