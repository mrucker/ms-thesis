function Mouse(canvas)
{
    var self     = this;
    
	var position  = {x:undefined, y:undefined};
	var velocity  = {x:undefined, y:undefined, m:undefined, d:undefined};

	var moveTimeout = undefined;

    //chrome: 60  mps
    //IE    : 120 mps
    var mps = new Frequency("mps", false);

    this.startTracking = function () {

		mps.start();

		position = {x:canvas.getResolution(0)/2, y:canvas.getResolution(1)/2};
		velocity = {x:0, y:0, m:0, d:0};

        canvas.addOnDeviceMove(onDeviceMove);
    };

    this.stopTracking = function () {

        canvas.removeOnDeviceMove(onDeviceMove);

        mps.stop();

        position = {x:undefined, y:undefined};
		velocity = {x:undefined, y:undefined, m:undefined, d:undefined};
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

	this.getDirectionTo = function(x,y) {
		return Math.atan2(y - position.y, x - position.x);
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
		updateVelocity(position, position.x, position.y);

		if(moveTimeout) clearTimeout(moveTimeout);

		moveTimeout = setTimeout(notMoving, 100);
	}

    function onDeviceMove(x,y) {
        mps.cycle();

		updateVelocity(position, x, y)

		position.x = x;
        position.y = y;

		if(moveTimeout) clearTimeout(moveTimeout);

		moveTimeout = setTimeout(notMoving, 100);
    }

	function updateVelocity(oldPosition, x, y) {

		newVelocityX = x - oldPosition.x;
		newVelocityY = y - oldPosition.y;
		newVelocityM = Math.sqrt(Math.pow(newVelocityX,2) + Math.pow(newVelocityY,2));
		newVelocityD = Math.atan2(newVelocityY,newVelocityX);

		velocity.x = 2/6 * velocity.x + 4/6 * newVelocityX;
		velocity.y = 2/6 * velocity.y + 4/6 * newVelocityY;
		velocity.m = 5/6 * velocity.m + 1/6 * newVelocityM;
		velocity.d = 2/6 * velocity.d + 4/6 * newVelocityD;
	}
}