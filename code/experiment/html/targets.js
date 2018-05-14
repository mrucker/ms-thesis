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
    var g = 100;
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
        
        var f = features();
        
        return self.isTouched() ? [200,0,0].join(',') : [r,g,b].join(',');

        //return [r,g,b].join(',');
    }

    function features() {
        var mouseHist    = new ma.dl.matrix(mouse.getHistory());
        var targetLoc    = new ma.dl.vector([x,y]);
        var mouseHistDot = new ma.dl.vector(mouse.getHistoryDot());        
        var targetLocDot = Math.pow(x,2) + Math.pow(y,2);
        
        var x1   = new ma.dl.scalar(targetLocDot);
        var x2   = mouseHistDot;
        var x1x2 = mouseHist.mul(targetLoc);
        
        var distances = x1.add(x2).sub(x1x2.mul(new ma.dl.scalar(2))).sqrt();
        
        return distances.concat(new ma.dl.vector([self.isTouched()*1]));
    }
    
    function opacity() {
        var aliveTime = self.getAge();

        if( aliveTime <= fadeInTime){
            return aliveTime/fadeInTime;
        }

        if( fadeInTime <= aliveTime && aliveTime <= fadeInTime+fadeOffTime){
            return 1;
        }

        if( fadeInTime+fadeOffTime <= aliveTime && aliveTime <= fadeInTime+fadeOffTime+fadeOutTime){
            return (fadeInTime+fadeOffTime+fadeOutTime - aliveTime) / fadeOutTime;
        }

        return 0;
    }
}