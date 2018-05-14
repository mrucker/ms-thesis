function Targets(mouse)
{
    var targets = [];
    var process = poissonProcess.create(50, function () { targets.push(new Target(mouse))} );

    this.startAppearing = function() {
        process.start();
    }

    this.stopAppearing = function() {
        process.stop();
    }

    this.draw = function(canvas){
        targets.forEach(function(target){ target.draw(canvas); });

        targets = targets.filter(function(target) {return !target.isDead();} );
    }

    this.getData = function() {
        //this is a little janky, but because the targets are positioned relative to the canvas they don't have a position until 
        //the next time the canvas is redrawn. Therefore it is possible for the target to exist and not have a position so we ignore it until it does.
        return targets.filter(function(target) { return target.getX() != null && target.getY() != null;  }).map(function(target) { return target.getData().map(Math.round); });
    }
    
    this.touchCount = function() {
        return targets.filter(function(target) { return target.isNewTouch(); }).length;
    }
}

function Target(mouse)
{
    var d = 300;
    var x = null;
    var y = null;
    var r = 0;
    var g = 0;
    var b = 0;

    return new TargetBase(x,y,d,r,g,b, mouse);
}

function TargetBase(x,y,d,r,g,b, mouse)
{
    var fadeInTime    = 0;
    var fadeOffTime   = 500;
    var fadeOutTime   = 500;
    var createTime    = Date.now();
    var touchedBefore = false;
    var self          = this;
    

    this.getX        = function() { return x; };
    this.getY        = function() { return y; };
    this.getAge      = function() { return Date.now() - createTime; };
    this.getData     = function() { return [self.getX(), self.getY(), self.getAge()]; };
    this.getLifeSpan = function() { return fadeInTime + fadeOffTime + fadeOutTime; }; 
    this.isDead      = function() { return self.getAge() > self.getLifeSpan() };

    this.isNewTouch = function() {
        
        if (self.isTouched() && !touchedBefore) {
            touchedBefore = true;
            return true;
        }
        
        return false;
    }
    
    this.isTouched  = function() {
        var targetX = x;
        var targetY = y;
        var mouseX = mouse.getX();
        var mouseY = mouse.getY();

        return Math.abs(mouseX-targetX) <= d/2 && Math.abs(mouseY - targetY) <= d/2 && dist(x,y,mouse.getX(),mouse.getY()) <= d/2;
    };

    this.draw = function(canvas){

        var circleArea   = (canvas.getWidth()*canvas.getHeight()) * (Math.PI*Math.pow(d/2,2)/(1500*3000));
        var circleRadius = Math.sqrt((circleArea/Math.PI))
    
        x = x || (canvas.getWidth()  - circleRadius*2) * Math.random() + circleRadius; //[d/2, height-d/2]
        y = y || (canvas.getHeight() - circleRadius*2) * Math.random() + circleRadius; //[d/2, width -d/2]

        var context   = canvas.getContext2d();

        context.save();

        context.fillStyle = fillStyle();
        context.beginPath();
        context.moveTo(x,y);
        context.arc(x, y, circleRadius, 0, 2 * Math.PI);
        context.fill();

        context.restore();
    }

    function dist(x1,y1,x2,y2) {
        return Math.sqrt(Math.pow(x1-x2,2)+Math.pow(y1-y2,2));
    }

    function fillStyle() {
        return 'rgba('+ rgb() +','+ opacity() +')';
    }
    
    function rgb() {
        
        var r_value = reward();
        
        var c_stop0 = [200,  0 ,  0 ];
        var c_stop1 = [ 0 , 200,  0 ];
        var c_stop2 = [ 0 ,  0 , 200];

        var c_val0 = -1;
        var c_val1 =  0;
        var c_val2 =  1;

        var c_wgt0 = Math.max(0,1-Math.abs(r_value - c_val0));
        var c_wgt1 = Math.max(0,1-Math.abs(r_value - c_val1));
        var c_wgt2 = Math.max(0,1-Math.abs(r_value - c_val2));

        var color = [
            c_wgt0*c_stop0[0]+c_wgt1*c_stop1[0]+c_wgt2*c_stop2[0], 
            c_wgt0*c_stop0[1]+c_wgt1*c_stop1[1]+c_wgt2*c_stop2[1],
            c_wgt0*c_stop0[2]+c_wgt1*c_stop1[2]+c_wgt2*c_stop2[2]
        ];

        return color.join(',');
    }
    
    function reward() {
        
        //var r_param = [-0.0153,  0.0217,  0.0064, -0.0008, 0.0001]; //crazy back and forth
        var r_param = [-0.1921, -0.0462, -0.0107, -0.0009, 0.0790]; //controlled and targeted
        var f_value = features();        
        var r_value = f_value[0]*r_param[0] + f_value[1]*r_param[1] + f_value[2]*r_param[2] + f_value[3]*r_param[3] + f_value[4]*r_param[4];

        r_value = r_value * 1/r_param[4];        
        r_value = Math.max(r_value,-1);
        r_value = Math.min(r_value, 1);
        
        return r_value;
    }

    function features() {

        var maxD = 3526;

        var mouseHist    = mouse.getHistory();
        var mouseHistDot = mouse.getHistoryDot();

        var targetLoc    = [x,y];
        var targetLocDot = Math.pow(x,2) + Math.pow(y,2);

        var d3 = targetLocDot + mouseHistDot[3] - 2*(targetLoc[0]*mouseHist[3][0] + targetLoc[1]*mouseHist[3][1]);
        var d2 = targetLocDot + mouseHistDot[2] - 2*(targetLoc[0]*mouseHist[2][0] + targetLoc[1]*mouseHist[2][1]);
        var d1 = targetLocDot + mouseHistDot[1] - 2*(targetLoc[0]*mouseHist[1][0] + targetLoc[1]*mouseHist[1][1]);
        var d0 = targetLocDot + mouseHistDot[0] - 2*(targetLoc[0]*mouseHist[0][0] + targetLoc[1]*mouseHist[0][1]);

        d3 = d3/Math.pow(maxD,2);
        d2 = d2/Math.pow(maxD,2);
        d1 = d1/Math.pow(maxD,2);
        d0 = d0/Math.pow(maxD,2);

        d3 = Math.sqrt(d3);
        d2 = Math.sqrt(d2);
        d1 = Math.sqrt(d1);
        d0 = Math.sqrt(d0);        
        
        var d = d3;
        var v = d3-d2;
        var a = d3/2-d2+d1/2;
        var j = d3/4-3*d2/4+3*d1/4-d0/4;

        return [d, v, a, j, self.isTouched()*1];
    }

    function opacity() {
        var r_value   = reward();
        var o_value   = 1;
        var aliveTime = self.getAge();        
        
        if( aliveTime <= fadeInTime){
            o_value = (aliveTime/fadeInTime) * r_value;
        }

        if( fadeInTime <= aliveTime && aliveTime <= fadeInTime+fadeOffTime){
            o_value = 1;
        }

        if( fadeInTime+fadeOffTime <= aliveTime && aliveTime <= fadeInTime+fadeOffTime+fadeOutTime){
            o_value = (fadeInTime+fadeOffTime+fadeOutTime - aliveTime) / fadeOutTime;
        }

        return Math.min(1,(r_value+1));
    }
}