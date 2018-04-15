function Mouse(canvas)
{
    var moves    = 0;
    var position = { x:0, y:0};    
    
    this.startTracking = function () {
        canvas.addEventListener('mousemove', onMouseMove, false);
    };

    this.stopTracking = function () {
        canvas.removeEventListener('mousemove', onMouseMove, false);
    };

    this.getX = function() {
        return position.x;
    };
    
    this.getY = function() {
        return position.y;
    };
    
    this.getData = function() {
        return [this.getX(), this.getY()];
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
    
    function onMouseMove(e) {
        position = canvasRelativePosition(this,e);
    }

    function canvasRelativePosition(canvas, e) {
        var canvasBound = canvas.getBoundingClientRect();
        var relative_x  = (e.clientX - canvasBound.left) * canvas.getDevicePixelRatio();
        var relative_y  = (e.clientY - canvasBound.top ) * canvas.getDevicePixelRatio();
        
        return { x: relative_x, y: relative_y };
    };
}