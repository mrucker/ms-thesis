function Experiment(participant, mouse, targets, canvas)
{
    var id           = Id.generate();
    var self         = this;
    var startTime    = undefined;
    var stopTime     = undefined;
    var observations = [];    
    var touchedPrev  = [];
    var touchedCnt   = 0;
    
    var ops     = new Frequency();
    var ops_Hz  = 60;
    
    var post = $.ajax({
        url   :"https://api.thesis.markrucker.net/v1/participants/" + participant.getId() + "/experiments",
        method:"POST",
        data  :id
    });
        
    this.getOPS = function() {
        return ops.getHz();
    }
    
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
    
    this.beginExperiment = function() {
        startTime = new Date().toUTCString();
        stopTime  = undefined;
        
        self.saveData({"startTime":startTime});
        
        //FPS
        //OPS
        //MPS
        //Feature Weights
        //Window Size
        //Window Resolution
        ops.start();
        setTimeout(observe, 1000/ops.correctedHz(1,ops_Hz));
    }

    this.endExperiment = function () {

        ops.stop();
        stopTime = new Date().toUTCString();

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
        
    this.saveObservation = function(width, height) {
        var states = observations.slice(3).map(function(observation, i) {

            var mp_0 = observations[3+i-0].mouseData.slice(0,2); //gives us [x,y];
            var mp_1 = observations[3+i-1].mouseData.slice(0,2); //gives us [x,y];
            var mp_2 = observations[3+i-2].mouseData.slice(0,2); //gives us [x,y];
            var mp_3 = observations[3+i-3].mouseData.slice(0,2); //gives us [x,y];
            //var mvX = i <= 0 ? 0 : mpX - observations[i-1].mouseData[0];
            //var mvY = i <= 0 ? 0 : mpY - observations[i-1].mouseData[1];
            //var maX = i <= 1 ? 0 : mvX - (observations[i-1].mouseData[0] - observations[i-2].mouseData[0]);
            //var maY = i <= 1 ? 0 : mvY - (observations[i-1].mouseData[1] - observations[i-2].mouseData[1]);
            //var mjX = i <= 2 ? 0 : maX - (observations[i-1].mouseData[0] - 2*observations[i-2].mouseData[0] + observations[i-3].mouseData[0]);
            //var mjY = i <= 2 ? 0 : maY - (observations[i-1].mouseData[1] - 2*observations[i-2].mouseData[1] + observations[i-3].mouseData[1]);

            //var dist = function(x1,y1,x2,y2) { return Math.sqrt(Math.pow(x1-x2,2)+Math.pow(y1-y2,2)); };
            //var top5 = observation.targetData.sort(function (a,b) { return dist(mpX,mpY,a[0],a[1]) - dist(mpX,mpY,b[0],b[1]); }).slice(0,5);            

            //return [mpX, mpY, mvX, mvY, maX, maY, mjX, mjY].concat(top5[0]).concat(top5[1]).concat(top5[2]).concat(top5[3]).concat(top5[4]);
            
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
    
        console.log(states.length);
        
        //console.log(JSON.stringify(touchedPrev).replace('[','').replace(']','').split(',').join('\r\n'));
        //console.log(JSON.stringify(states));
        //console.log(JSON.stringify(actions));
        //console.log(canvas.getWidth() + "," + canvas.getHeight());
    };
    
    function observe() {
        
        if(startTime && !stopTime) {

            ops.cycle();
            
            if(ops.cycleCount() % 100 == 0) {
                console.log(ops.getHz());
            }
            
            observations.push({"mouseData": mouse.getData(), "targetData": targets.getData() });
            
            touchedCnt += targets.touchCount();
            
            setTimeout(observe, 1000/ops.correctedHz(1,ops_Hz));
        }        
    }
}