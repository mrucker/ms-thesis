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
    };
    
    function onMouseMove(e) {
        position = canvasRelativePosition(this,e);
    }

    function canvasRelativePosition(canvas, e) {
        var canvasBound = canvas.getBoundingClientRect();
        var relative_x  = (e.clientX - canvasBound.left) * canvas.getDevicePixelRatio();
        var relative_y  = (e.clientY - canvasBound.top ) * canvas.getDevicePixelRatio();
        
        console.log(canvasBound.left);
        console.log(e.clientX);
        
        return { x: relative_x, y: relative_y };
    };
}