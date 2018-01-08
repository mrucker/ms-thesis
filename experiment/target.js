function Target(canvas)
{
    var d = 200;
    var x = (canvas.width  - d) * Math.random() + d/2; //[d/2,height-d/2]
    var y = (canvas.height - d) * Math.random() + d/2; //[d/2, width-d/2]
    var r = 0;
    var g = 200;
    var b = 0;
    var a = 1;
    
    return new TargetBase(x,y,d,r,g,b,canvas);
}

function TargetBase(x,y,d,r,g,b,canvas)
{
    var fadeInTime   = 500;
    var fadeOutTime  = 500;
    var fadeOffTime  = 500;
    var context    = canvas.getContext('2d');
    var createTime = Date.now();
    var circlePath = new Path2D();

    circlePath.moveTo(x, y);
    circlePath.arc(x, y, d/2, 0, 2 * Math.PI);

    this.getCreateTime = function() { return createTime };
    this.getX          = function() { return x; };
    this.getY          = function() { return y; };

    this.wipe = function(){
        context.save();
        context.fillStyle = 'rgb(255,255,255)';
        context.fill(circlePath);
        context.restore();
    }

    this.draw = function(){
        context.save();
        context.fillStyle = 'rgba('+r+','+g+','+b+','+this.opacity()+')';
        context.fill(circlePath);
        
        context.fillStyle = 'rgb(0,0,0)';
        context.font = '30px Arial';
        context.fillText('('+Math.floor(x)+','+Math.floor(y)+')',30+x-d/2,y);
        context.restore();
        
        
    }
    
    this.opacity = function() {
        var aliveTime = Date.now() - createTime;
        
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
    
    this.dead = function() {
        return (Date.now() - createTime) > (fadeInTime+fadeOffTime+fadeOutTime);
    }
}