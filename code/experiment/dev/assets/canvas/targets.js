var _alphaStepSize  = .1;
var _colorStepSize  = .1;

var _colorStepCount = (2/_colorStepSize)+1;
var _alphaStepCount = (1/_alphaStepSize)+1;

var _canvas = document.createElement("canvas");
	_canvas.width  = 200*_colorStepCount;
	_canvas.height = 200*_alphaStepCount;

for(var r = -1; r <= 1; r+=_colorStepSize) {
    
    var xOffset = Math.round(200*(r+1)/_colorStepSize,0);
    
    for(var a = 1; a >= 0; a-=_alphaStepSize) {
    
        var yOffset = Math.round(200*(1-a)/_alphaStepSize,0);

        var context = _canvas.getContext("2d");
        
        context.fillStyle = "rgba(" + rgb(r) + "," + a + ")";
        context.beginPath();
        context.arc(100 + xOffset, 100 + yOffset, 100, 0, 2 * Math.PI);    
        context.fill();
    }
}

//var _image = new Image();
//    _image.src = _canvas.toDataURL("image/png");  
//var image2 = _canvas.toDataURL("image/png").replace("image/png", "image/octet-stream");  // here is the most important part because if you dont replace you will get a DOM 18 exception.
//window.location.href=image2; // it will save locally

function rgb(r_value) {

        var c_stop0 = [200, 0  ,  0 ];
        var c_stop1 = [ 0 , 200,  0 ];
        var c_stop2 = [ 0 , 0  , 200];

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

        color = color.map(function(c) { return Math.round(c,0); });
        
        return color.join(',');
}
    
function Targets(mouse)
{
    var targets = [];
    var process = poissonProcess.create(200, function () { targets.push(new Target(mouse))} );

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
    var originalX       = x;
    var originalY       = y;
    var originalR       = d/2;
    var originalWidth   = 0;
    var originalHeight  = 0;
    var effectiveX      = 0;
    var effectiveY      = 0;
    var effectiveR      = 0;
    var effectiveA      = 0;
    var fadeInTime      = 0;
    var fadeOffTime     = 500;
    var fadeOutTime     = 500;
    var createTime      = Date.now();
    var touchedBefore   = false;
    var self            = this;

    this.getX        = function() { return effectiveX; };
    this.getY        = function() { return effectiveY; };
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
        
        var targetX = effectiveX;
        var targetY = effectiveY;
        var mouseX = mouse.getX();
        var mouseY = mouse.getY();

        return dist(targetX,targetY,mouseX,mouseY) <= effectiveR;
    };
    
    this.getReward = function() {
        //var r_param = [-0.0153,  0.0217,  0.0064, -0.0008, 0.0001]; //crazy back and forth
        //var r_param = [-0.1921, -0.0462, -0.0107, -0.0009, 0.0790]; //controlled and targeted
        var r_param   = [0      ,0       ,0       ,0       ,1      ]; //the default color scheme
        var f_value   = self.getFeatures();
        var r_value   = f_value[0]*r_param[0] + f_value[1]*r_param[1] + f_value[2]*r_param[2] + f_value[3]*r_param[3] + f_value[4]*r_param[4];

        r_value = r_value * 1/r_param[4];
        r_value = Math.max(r_value,-1);
        r_value = Math.min(r_value, 1);

        return r_value;
    };
    
    this.getFeatures = function () {
        var maxD = 3526;

        var mouseHistPos = mouse.getHistoryPos();
        var mouseHistDot = mouse.getHistoryDot();

        var targetLoc    = [x,y];
        var targetLocDot = Math.pow(x,2) + Math.pow(y,2);

        var d3 = targetLocDot + mouseHistDot[0] - 2*(targetLoc[0]*mouseHistPos[0][0] + targetLoc[1]*mouseHistPos[0][1]);
        var d2 = targetLocDot + mouseHistDot[1] - 2*(targetLoc[0]*mouseHistPos[1][0] + targetLoc[1]*mouseHistPos[1][1]);
        var d1 = targetLocDot + mouseHistDot[2] - 2*(targetLoc[0]*mouseHistPos[2][0] + targetLoc[1]*mouseHistPos[2][1]);
        var d0 = targetLocDot + mouseHistDot[3] - 2*(targetLoc[0]*mouseHistPos[3][0] + targetLoc[1]*mouseHistPos[3][1]);

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
    };
    
    this.draw = function(canvas) {
        self.drawImage(canvas);
    }

    this.drawCircle = function(canvas){

        effectiveA = (canvas.getResolution(1)/1500) * (canvas.getResolution(0)/3000) * (Math.PI * originalR * originalR);
        effectiveR = Math.round(Math.sqrt(effectiveA/Math.PI),0);

        originalWidth   = originalWidth  || canvas.getResolution(0);
        originalHeight  = originalHeight || canvas.getResolution(1);
        originalX       = originalX      || (canvas.getResolution(0) - effectiveR*2) * Math.random() + effectiveR;
        originalY       = originalY      || (canvas.getResolution(1) - effectiveR*2) * Math.random() + effectiveR;
        
        effectiveX = Math.round((originalX/originalWidth ) * canvas.getResolution(0) ,0);
        effectiveY = Math.round((originalY/originalHeight) * canvas.getResolution(1),0);

        var context   = canvas.getContext2d();

        context.fillStyle = fillStyle();
        context.beginPath();
        context.arc(effectiveX, effectiveY, effectiveR, 0, 2 * Math.PI);
        context.fill(); 
    }
    
    this.drawSquare = function(canvas){

        effectiveA = (canvas.getResolution(1)/1500) * (canvas.getResolution(0)/3000) * (Math.PI * originalR * originalR);
        effectiveL = Math.round(Math.sqrt(effectiveA),0);
        effectiveR = effectiveL/2;

        originalWidth   = originalWidth  || canvas.getResolution(0);
        originalHeight  = originalHeight || canvas.getResolution(1);
        originalX       = originalX      || (canvas.getResolution(0) - effectiveR*2) * Math.random() + effectiveR;
        originalY       = originalY      || (canvas.getResolution(1) - effectiveR*2) * Math.random() + effectiveR;
        
        effectiveX = Math.round((originalX/originalWidth ) * canvas.getResolution(0) ,0);
        effectiveY = Math.round((originalY/originalHeight) * canvas.getResolution(1),0);
        
        var context = canvas.getContext2d();

        context.fillStyle = fillStyle();
        context.fillRect(effectiveX-effectiveL/2, effectiveY-effectiveL/2, effectiveL, effectiveL); 
    }
    
    this.drawImage = function(canvas){
        
        effectiveA = (canvas.getResolution(1)/1500) * (canvas.getResolution(0)/3000) * (Math.PI * originalR * originalR);
        effectiveR = Math.round(Math.sqrt(effectiveA/Math.PI),0);
    
        originalWidth   = originalWidth  || canvas.getResolution(0);
        originalHeight  = originalHeight || canvas.getResolution(1);
        originalX       = originalX      || (canvas.getResolution(0) - effectiveR*2) * Math.random() + effectiveR;
        originalY       = originalY      || (canvas.getResolution(1) - effectiveR*2) * Math.random() + effectiveR;
        
        effectiveX = Math.round((originalX/originalWidth ) * canvas.getResolution(0) ,0);
        effectiveY = Math.round((originalY/originalHeight) * canvas.getResolution(1),0);
                
        var context = canvas.getContext2d();
        
        var xOffset = 200*Math.round((self.getReward()+1)/_colorStepSize,0);
        var yOffset = 200*Math.round((1-opacity())/_alphaStepSize, 0);
        
        context.drawImage(_canvas,xOffset,yOffset, 200, 200, effectiveX-effectiveR, effectiveY-effectiveR, 2*effectiveR, 2*effectiveR);
        //context.drawImage(_image, effectiveX, effectiveY);
    }
    
    function dist(x1,y1,x2,y2) {
        return Math.sqrt(Math.pow(x1-x2,2)+Math.pow(y1-y2,2));
    }

    function fillStyle() {
        
        var r_value = self.getReward()
        
        return 'rgba('+ rgb(r_value) +','+ opacity(r_value) +')';
    }
    
    function opacity(r_value) {
        var o_value   = 0;
        var aliveTime = self.getAge();

        if (aliveTime <= fadeInTime){
            o_value = aliveTime/fadeInTime;
        }

        if (fadeInTime <= aliveTime && aliveTime <= fadeInTime+fadeOffTime){
            o_value = 1;
        }

        if (fadeInTime+fadeOffTime <= aliveTime && aliveTime <= fadeInTime+fadeOffTime+fadeOutTime){
            o_value = (fadeInTime+fadeOffTime+fadeOutTime-aliveTime) / fadeOutTime;
        }

        if (aliveTime >= fadeInTime+fadeOffTime+fadeOutTime) {
            o_value = 0;
        }

        return o_value;

        //return Math.min(1,(r_value+1));
    }

    function rgb(r_value) {

        var c_stop0 = [200, 0  ,  0 ];
        var c_stop1 = [ 0 , 200,  0 ];
        var c_stop2 = [ 0 , 0  , 200];

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
}