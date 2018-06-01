function Mouse(canvas)
{
    var moves      = 0;
    var position   = { x:undefined, y:undefined};
    var self       = this;
    var history    = [[0,0],[0,0],[0,0],[0,0]];
    var historyDot = [0,0,0,0]
    var prevDrawX  = 0;
    var prevDrawY  = 0;
    
    this.startTracking = function () {
        canvas.addDeviceMoveListener(onMouseMove);
    };

    this.stopTracking = function () {
        canvas.removeDeviceMoveListener(onMouseMove);
        position = { x:undefined, y:undefined};
    };

    this.getX = function() {
        return position.x;
    };
    
    this.getY = function() {
        return position.y;
    };
    
    this.getHistory = function() {
        return history;
    }
    
    this.getHistoryDot = function() {
        return historyDot;
    }
    
    this.getData = function() {
        return [self.getX(), self.getY()];
    }

    this.draw = function(canvas) {
        
        var effectiveX = Math.round(position.x,0);
        var effectiveY = Math.round(position.y,0);
                
        var context = canvas.getContext2d();
        
        context.fillStyle = "rgb(200,0,0)";
        context.fillRect(effectiveX - 2, effectiveY - 2, 4, 4);

        // if(prevDrawX != effectiveX || prevDrawY != effectiveY) {
            // context.fillStyle = 'rgb(255,255,255)';
            // context.beginPath();
            // context.moveTo(prevDrawX, prevDrawY);
            // context.arc(prevDrawX, prevDrawY, 5, 0, 2 * Math.PI);
            // context.fill();
            
            // prevDrawX = effectiveX;
            // prevDrawY = effectiveY;

        // }
        
        // context.fillStyle = 'rgb(200,0,0)';
        // context.beginPath();
        // context.moveTo(effectiveX, effectiveY);
        // context.arc(effectiveX, effectiveY, 4, 0, 2 * Math.PI);
        // context.fill();
        
        // context.save();
        // context.fillStyle    = 'rgb(100,100,100)';
        // context.font         = '48px Arial';
        // context.textBaseline = 'bottom';
        // context.textAlign    = 'right';
        // context.fillText(position.x + "," + position.y,canvas.getWidth(),canvas.getHeight()/2);
        // context.restore();
        
    };
    
    function onMouseMove(x,y) {
        position = {"x":x, "y":y };
        
        history.push([x,y]);
        historyDot.push(Math.pow(x,2) + Math.pow(y,2));
        
        if(history.length > 4) {
            history.shift();
            historyDot.shift();
        }
    }
}