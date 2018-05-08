function Mouse(canvas)
{
    var moves    = 0;
    var position = { x:undefined, y:undefined};
    var self     = this;
    
    this.startTracking = function () {
        canvas.addMouseMoveListener(onMouseMove);
    };

    this.stopTracking = function () {
        canvas.removeMouseMoveListener(onMouseMove);
        position = { x:undefined, y:undefined};
    };

    this.getX = function() {
        return position.x;
    };
    
    this.getY = function() {
        return position.y;
    };
    
    this.getData = function() {
        return [self.getX(), self.getY()];
    }

    this.draw = function(canvas) {
        var context = canvas.getContext2d();
        
        context.save();
        
        context.fillStyle = 'rgba(200,0,0,1)';
        context.beginPath();;
        context.moveTo(position.x, position.y);
        context.arc(position.x+4, position.y+4, 4, 0, 2 * Math.PI);
        context.fill();
        
        context.restore();
    };
    
    function onMouseMove(x,y) {
        position = {"x":x, "y":y };
    }
}