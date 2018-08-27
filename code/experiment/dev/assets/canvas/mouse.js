function Mouse(canvas)
{
    var self       = this;
    var position   = {x:undefined, y:undefined};
    var historyPos = [[0,0],[0,0],[0,0],[0,0]];
    var historyDot = [0,0,0,0];
    
    //chrome: 60  mps
    //IE    : 120 mps
    var mps        = new Frequency("mps", false);

    this.startTracking = function () {
        
		mps.start();
        
        canvas.addOnDeviceMove(onDeviceMove);
    };

    this.stopTracking = function () {

        canvas.removeOnDeviceMove(onDeviceMove);

        mps.stop();

        position = { x:undefined, y:undefined};
    };

    this.getX = function() {
        return position.x || canvas.getResolution(0)/2;
    };

    this.getY = function() {
        return position.y || canvas.getResolution(1)/2;
    };

    this.getHistoryPos = function() {
        return historyPos.slice(0,4);
    }

    this.getHistoryDot = function() {
        return historyDot.slice(0,4);
    }

    this.getData = function() {
        return [
            Math.round(self.getX(), 0),
            Math.round(self.getY(), 0)
        ];
    }

    this.draw = function(canvas) {

        var effectiveX = Math.round(position.x,0);
        var effectiveY = Math.round(position.y,0);

        var context = canvas.getContext2d();

        context.fillStyle = "rgb(200,0,0)";
        context.fillRect(effectiveX - 3, effectiveY - 3, 6, 6);
    };
    
    function onDeviceMove(x,y) {
        mps.cycle();
                
        position.x = x;
        position.y = y;

        historyPos.unshift([x,y]);
        historyDot.unshift(Math.pow(x,2) + Math.pow(y,2));
    }
}