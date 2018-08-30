function Mouse(canvas)
{
    var self = this;

	var noMoveTime = 40;
    
	var position     = {x:undefined, y:undefined};
	var velocity     = {x:undefined, y:undefined, m:undefined, d:undefined};
	var acceleration = {x:undefined, y:undefined, m:undefined, d:undefined};

	var moveTimeout = undefined;

    //chrome: 60  mps
    //IE    : 120 mps
    var mps = new Frequency("mps", false);

    this.startTracking = function () {

		mps.start();

		position     = {x:canvas.getResolution(0)/2, y:canvas.getResolution(1)/2};
		velocity     = {x:0, y:0, m:0, d:0};
		acceleration = {x:0, y:0, m:0, d:0};

        canvas.addOnDeviceMove(onDeviceMove);
    };

    this.stopTracking = function () {

        canvas.removeOnDeviceMove(onDeviceMove);

        mps.stop();

        position     = {x:undefined, y:undefined};
		velocity     = {x:undefined, y:undefined, m:undefined, d:undefined};
		acceleration = {x:undefined, y:undefined, m:undefined, d:undefined};
    };

    this.getX = function() {
        return position.x;
    };

    this.getY = function() {
        return position.y || canvas.getResolution(1)/2;
    };

	this.getVelocity = function(dim) {
		if(dim == 0) return velocity.x;
		if(dim == 1) return velocity.y;
		if(dim == 2) return velocity.m;
		if(dim == 3) return velocity.d;
		
		return velocity.m;
	}
	
	this.getAcceleration = function(dim) {
		if(dim == 0) return acceleration.x;
		if(dim == 1) return acceleration.y;
		if(dim == 2) return acceleration.m;
		if(dim == 3) return acceleration.d;
		
		return velocity.m;
	}

	this.getDirectionTo = function(x,y) {
		return Math.atan2(-(y - position.y), x - position.x);
	}

	this.getDirectionToCenter = function() {
		return self.getDirectionTo(canvas.getResolution(0)/2, canvas.getResolution(1)/2)
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
		
		//this drops off too fast and doesn't look good
		//instead I'm going to write a custom blend formula
		//updateVelocity(position, position.x, position.y);
		
		var scale = 12/13;

		velocity.x *= 12/13;
		velocity.y *= 12/13;
		velocity.m *= 12/13;

		acceleration.x *= 12/13;
		acceleration.y *= 12/13;
		acceleration.m *= 12/13;

		if(moveTimeout) clearTimeout(moveTimeout);

		if(velocity.m > .0001) {
			moveTimeout = setTimeout(notMoving, 9);
		}
	}

    function onDeviceMove(x,y) {
        mps.cycle();

		updateVelocity(position, x, y)

		position.x = x;
        position.y = y;

		if(moveTimeout) clearTimeout(moveTimeout);

		moveTimeout = setTimeout(notMoving, 300);
    }

	function updateVelocity(oldPosition, x, y) {

		newVelocityX = x - oldPosition.x;
		newVelocityY = y - oldPosition.y;
		newVelocityM = Math.sqrt(Math.pow(newVelocityX,2) + Math.pow(newVelocityY,2));
		newVelocityD = Math.atan2(-newVelocityY,newVelocityX);

		newAccelerationX = x - oldPosition.x - velocity.x;
		newAccelerationY = y - oldPosition.y - velocity.y;
		newAccelerationM = Math.sqrt(Math.pow(newAccelerationX,2) + Math.pow(newAccelerationY,2));
		//newAccelerationD = Math.atan2(-newAccelerationY,newAccelerationX);

		velocity.x = 2/6 * velocity.x + 4/6 * newVelocityX;
		velocity.y = 2/6 * velocity.y + 4/6 * newVelocityY;
		velocity.m = 2/6 * velocity.m + 4/6 * newVelocityM;
		velocity.d = 2/6 * velocity.d + 4/6 * newVelocityD;
		
		acceleration.x = 2/6 * acceleration.x + 4/6 * newAccelerationX;
		acceleration.y = 2/6 * acceleration.y + 4/6 * newAccelerationY;
		acceleration.m = 5/6 * acceleration.m + 1/6 * newAccelerationM;
		//acceleration.d = 2/6 * acceleration.d + 4/6 * newAccelerationD;
	}
}