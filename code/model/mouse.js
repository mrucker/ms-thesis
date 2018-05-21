function Mouse(canvas)
{
    var moves    = 0;
    var position = { x:0, y:0};

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
        return [this.getX(), this.getY()];
    }

    this.draw = function(canvas) {
    };

    function onMouseMove(x,y) {
        position = {"x":x, "y":y };
    }
}