function Mouse(canvas)
{
    var self     = this;
    var position = {x:undefined, y:undefined};
	var velocity = {x:undefined, y:undefined, m:undefined};

	var moveTimeout = undefined;
	
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

        position = {x:undefined, y:undefined};
		velocity = {x:undefined, y:undefined, m:undefined};
    };

    this.getX = function() {
        return position.x || canvas.getResolution(0)/2;
    };

    this.getY = function() {
        return position.y || canvas.getResolution(1)/2;
    };

	this.getVelocity = function(dim) {
		if(dim == 0) return velocity.x;
		if(dim == 1) return velocity.y;

		return velocity.m;
	}

	this.getDirectionFrom = function(x,y) {
		return Math.atan2(y - position.y, x - position.x);
	}

	this.getDirectionFromCenter = function() {
		return self.getDirectionFrom(canvas.getResolution(0)/2, canvas.getResolution(1)/2)
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

	function notMoving() {
		velocity = {x:0, y:0, m:0};
	}
	
    function onDeviceMove(x,y) {
        mps.cycle();

		velocity.x = x - position.x;
		velocity.y = y - position.y;
		velocity.m = Math.sqrt(velocity.x^2 + velocity.y^2)

        position.x = x;
        position.y = y;
		
		if(moveTimeout) clearTimeout(moveTimeout);
		
		moveTimeout = setTimeout(notMoving, 30);
    }
}