var _renderer  = new TargetRenderer(0, .5, .5, 1000);

var _prerender_n_touch = _renderer.prerender(_renderer.allGray150, _renderer.allGray90, _renderer.evenFill, _renderer.mediumStroke, _renderer.evenOpacity);
var _prerender_y_touch = _renderer.prerender(_renderer.allGray90 , _renderer.allBlack , _renderer.evenFill, _renderer.heavyStroke , _renderer.evenOpacity);

function Targets(mouse, rewardId) {
    var radius     = 150;
    var targets    = [];
    var effectiveA = 0;
    var effectiveR = 0;
    
    //if you change this 200 value be sure to remember to also change the matlab huge_trans_pre function as well
    var process = poissonProcess.create(200, function () { targets.push(new Target(mouse, radius, 0, 0, 0, rewardId))} );

    this.startAppearing = function() {
        process.start();
    }

    this.stopAppearing = function() {
        process.stop();
    }

    this.draw = function(canvas){

		//I need this here so that it is reported up the chain
		effectiveR = Math.round(radius * canvas.getAreaPctSqrt());
		
		targets.forEach(function(target){ target.draw(canvas); });
        targets = targets.filter(function(target) { return !target.isDead();} );
    }

    this.getData = function(width, height) {
        
        //this is a little janky, but because the targets are positioned relative to the canvas they don't have a position until the next 
        //time the canvas is redrawn. Therefore it is possible for the target to exist and not have a position so we ignore it until it does.       
        var ts = targets.filter(function(target) { return target.getX() != null && target.getY() != null; });
        var ds = ts.map(function(target) { return target.getData().map(Math.round); });
        
        return [effectiveR].concat(ds.toFlat());
    }

    this.touchCount = function() {
        return targets.filter(function(target) { return target.isNewTouch(); }).length;
    }
}

function Target(mouse, radius, x_pct, y_pct, fixed_age, rewardId) {

	var self = this;

	x_pct = x_pct || Math.random();
	y_pct = y_pct || Math.random();

    var effectiveX = 0;
    var effectiveY = 0;
    var effectiveR = 0;
	
    var creationTime   = Date.now();
	var isNextTouchNew = true;
	
	var xOffsetOnTouch = 0;
	
	var isPal = false;
    
	this.setPal = function(isOn) { isPal = isOn; }
	
	this.getR   = function() { return effectiveR; };
    this.getX   = function() { return effectiveX; };
    this.getY   = function() { return effectiveY; };
    this.getAge = function() { return fixed_age || (Date.now() - creationTime); };
    this.isDead = function() { return self.getAge() >= 100 && _renderer.yOffset(self.getAge()) == 0;};

    this.getData = function() {
        return [
            Math.round(self.getX()     ,0),
            Math.round(self.getY()     ,0),
            Math.round(self.getAge()   ,0),
        ];
    };

    this.isNewTouch = function() {

		if(self.isTouched() && isNextTouchNew) {
			isNextTouchNew = false;
			return true;
		}

		if(!self.isTouched()) {
			isNextTouchNew = true;
		}

		return false;
    }

    this.isTouched  = function() {

        var targetX = effectiveX;
        var targetY = effectiveY;
        var mouseX = mouse.getX();
        var mouseY = mouse.getY();

        return dist(targetX,targetY,mouseX,mouseY) <= effectiveR;
    };
	
	this.getReward = function() {
		return self.getReward_4_8();
	}

    this.getReward_4_5 = function() {
		
		if(rewardId == 1) return 0.5;
		
        var f_classes = self.getFeatures_4_5().map(function(v) { return v-1; });

		var lox_index = [0,96,192]
		var loy_index = [0,32,64];
		var dir_index = [0,4,8,12,16,20,24,28];
		var age_index = [1,2,3,4];

		var r_index = lox_index[f_classes[0]] + loy_index[f_classes[1]] + dir_index[f_classes[2]] + age_index[f_classes[3]];

		if(rewardId == 2) {
			var rewards = [0.2,0.51,1,0.71,0.44,0.38,0.72,0.58,0.39,0.43,0.7,0.59,0.39,0.38,0.69,0.56,0.36,0.31,0.56,0.4,0.21,0.38,0.68,0.72,0.54,0.32,0.58,0.49,0,0.55,1,1,0.25,0.33,0.62,0.61,0.24,0.28,0.45,0.29,0.53,0.25,0.52,0.25,0.26,0.25,0.74,0.53,0.24,0.07,0.32,0,0,0.22,0.59,0.25,0.09,0.19,0.41,0.11,0.11,0.32,0.6,0.25,0.2,0.47,0.65,0.55,0.44,0.42,0.89,0.52,0.32,0.44,0.64,0.88,0.64,0.37,0.55,0.44,0.58,0.27,0.28,0.32,0.21,0.33,0.51,0.41,0.1,0.34,0.47,0.39,0.27,0.66,0.58,0.35,0.35,0.45,0.71,1,0.42,0.35,0.61,0.51,0.3,0.32,0.57,0.43,0.25,0.28,0.5,0.39,0.22,0.26,0.46,0.4,0.19,0.25,0.48,0.41,0.19,0.31,0.5,0.59,0.24,0.34,0.61,0.44,0.12,0.28,0.86,0.39,0.15,0.19,0.52,0.27,0.12,0.14,0.71,0,0.09,0.1,0.41,0.08,0,0.06,0.35,0.32,0,0.03,0.37,0.08,0.05,0.18,0.26,0.04,0.61,0.19,0.69,0.12,0.14,0.41,0.63,0.27,0.76,0.32,1,0.72,0.18,0.23,0.8,0.27,0,0.2,0.44,0,0.05,0.19,0.4,0.2,0.11,0.21,0.46,0.26,0.14,0.27,0.48,0.3,0.25,0.31,0.55,0.32,0.19,0.45,0.6,0.6,0.38,0.35,0.52,0.47,0.32,0.34,0.49,0.43,0.28,0.32,0.47,0.41,0.25,0.28,0.39,0.37,0.2,0.31,0.45,0.42,0.24,0.32,0.45,0.42,0.24,0.43,0.61,0.54,0.3,0.33,0.53,0.77,0.3,0.29,0.45,0.3,0.68,0.24,0.39,0.22,0.2,0.23,0.39,0.27,0.16,0.15,0.12,0.19,0,0.2,0.35,0.27,0.04,0.24,0.35,0.29,0.21,0.57,0.5,0.63,0.18,0.59,0.51,0.46,0.3,0.18,0.42,0.47,0.04,0.29,0.35,0.35,0.18,0.25,0.36,0.27,0,0.22,0.28,0.25,0.09,0.23,0.33,0.23,0,0.27,0.36,0.31,0.16,0.38,0.45,0.38,0.2];
			return rewards[r_index];
		}
		else {
			return 0.5;
		}
    };
	
	this.getReward_4_6 = function() {

		if(rewardId == 1) return 0.5;

        var f_classes = self.getFeatures_4_6().map(function(v) { return v-1; });

		var lox_index = [0, 216, 432];
		var loy_index = [0,  72, 144];
		var vox_index = [0,  24,  48];
		var voy_index = [0,   8,  16];
		var dir_index = [1,2,3,4,5,6,7,8];

		var r_index = lox_index[f_classes[0]] + loy_index[f_classes[1]] + vox_index[f_classes[2]] + voy_index[f_classes[3]] + dir_index[f_classes[4]];

		if(rewardId == 2) {
			//var rewards = [0.4,0.44,0.02,0.06,0.2,0.54,0.78,0.96,0.99,0.5,0.27,0.29,0.37,0.56,0.69,0.79,0.81,0.56,0.5,0.51,0.53,0.57,0.61,0.63,0.64,0.5,0.27,0.29,0.37,0.56,0.69,0.79,0.81,0.54,0.41,0.42,0.46,0.57,0.64,0.7,0.71,0.57,0.54,0.54,0.55,0.58,0.6,0.61,0.61,0.56,0.5,0.51,0.53,0.57,0.61,0.63,0.64,0.57,0.54,0.54,0.55,0.58,0.6,0.61,0.61,0.58,0.57,0.57,0.57,0.58,0.58,0.59,0.59,0.56,0,0,0,0.29,0.8,1,1,0.57,0.18,0.21,0.21,0.42,0.7,0.96,1,0.58,0.48,0.49,0.49,0.54,0.61,0.67,0.68,0.57,0.18,0.21,0.21,0.42,0.7,0.96,1,0.58,0.36,0.37,0.38,0.49,0.65,0.79,0.81,0.58,0.53,0.53,0.53,0.56,0.6,0.63,0.64,0.58,0.48,0.49,0.49,0.54,0.61,0.67,0.68,0.58,0.53,0.53,0.53,0.56,0.6,0.63,0.64,0.58,0.57,0.57,0.57,0.58,0.58,0.59,0.59,0.57,0.04,0.07,0.01,0.31,0.75,0.96,0.99,0.58,0.28,0.3,0.26,0.43,0.68,0.79,0.81,0.58,0.51,0.51,0.5,0.54,0.6,0.63,0.64,0.58,0.28,0.3,0.26,0.43,0.68,0.79,0.81,0.58,0.41,0.42,0.4,0.5,0.63,0.7,0.71,0.58,0.54,0.54,0.54,0.56,0.59,0.61,0.61,0.58,0.51,0.51,0.5,0.54,0.6,0.63,0.64,0.58,0.54,0.54,0.54,0.56,0.59,0.61,0.61,0.58,0.57,0.57,0.57,0.58,0.58,0.59,0.59,0.39,0,0,0,0.17,0.64,0.83,0.98,0.48,0.18,0.14,0.16,0.35,0.61,0.72,0.8,0.56,0.48,0.47,0.48,0.52,0.59,0.61,0.63,0.48,0.18,0.14,0.16,0.35,0.61,0.72,0.8,0.52,0.36,0.33,0.35,0.45,0.6,0.66,0.7,0.57,0.53,0.52,0.52,0.55,0.58,0.6,0.61,0.56,0.48,0.47,0.48,0.52,0.59,0.61,0.63,0.57,0.53,0.52,0.52,0.55,0.58,0.6,0.61,0.58,0.57,0.57,0.57,0.57,0.58,0.58,0.59,0.52,0,0,0,0,0.4,0.69,0.92,0.55,0.19,0.16,0.14,0.26,0.48,0.64,0.77,0.57,0.49,0.48,0.47,0.5,0.56,0.6,0.63,0.55,0.19,0.16,0.14,0.26,0.48,0.64,0.77,0.56,0.36,0.34,0.33,0.4,0.53,0.61,0.69,0.58,0.53,0.52,0.52,0.54,0.57,0.59,0.61,0.57,0.49,0.48,0.47,0.5,0.56,0.6,0.63,0.58,0.53,0.52,0.52,0.54,0.57,0.59,0.61,0.58,0.57,0.57,0.57,0.57,0.58,0.58,0.59,0.67,0.27,0.39,0.32,0.29,0.4,0.48,0.72,0.63,0.41,0.48,0.44,0.42,0.48,0.53,0.66,0.59,0.54,0.55,0.55,0.54,0.56,0.57,0.6,0.63,0.41,0.48,0.44,0.42,0.48,0.53,0.66,0.61,0.48,0.52,0.5,0.49,0.53,0.55,0.62,0.59,0.56,0.57,0.56,0.56,0.57,0.57,0.59,0.59,0.54,0.55,0.55,0.54,0.56,0.57,0.6,0.59,0.56,0.57,0.56,0.56,0.57,0.57,0.59,0.58,0.57,0.58,0.58,0.57,0.58,0.58,0.58,0.88,0.45,0.31,0.31,0.38,0.71,1,1,0.75,0.51,0.43,0.43,0.47,0.65,0.82,0.98,0.62,0.56,0.54,0.54,0.55,0.6,0.64,0.68,0.75,0.51,0.43,0.43,0.47,0.65,0.82,0.98,0.67,0.54,0.5,0.5,0.52,0.62,0.71,0.8,0.6,0.57,0.56,0.56,0.57,0.59,0.61,0.63,0.62,0.56,0.54,0.54,0.55,0.6,0.64,0.68,0.6,0.57,0.56,0.56,0.57,0.59,0.61,0.63,0.59,0.58,0.58,0.58,0.58,0.58,0.59,0.59,1,0.78,0.65,0.61,0.46,0.62,0.8,1,0.85,0.69,0.62,0.6,0.51,0.6,0.7,0.83,0.65,0.61,0.59,0.58,0.56,0.59,0.61,0.64,0.85,0.69,0.62,0.6,0.51,0.6,0.7,0.83,0.73,0.64,0.6,0.59,0.54,0.59,0.65,0.72,0.62,0.6,0.59,0.58,0.57,0.58,0.6,0.61,0.65,0.61,0.59,0.58,0.56,0.59,0.61,0.64,0.62,0.6,0.59,0.58,0.57,0.58,0.6,0.61,0.59,0.58,0.58,0.58,0.58,0.58,0.58,0.59,0.9,0.87,1,1,0.67,0.53,0.5,0.68,0.76,0.74,0.85,0.84,0.63,0.55,0.53,0.64,0.62,0.62,0.65,0.64,0.59,0.57,0.57,0.59,0.76,0.74,0.85,0.84,0.63,0.55,0.53,0.64,0.68,0.67,0.73,0.72,0.61,0.56,0.56,0.61,0.6,0.6,0.62,0.62,0.59,0.58,0.57,0.59,0.62,0.62,0.65,0.64,0.59,0.57,0.57,0.59,0.6,0.6,0.62,0.62,0.59,0.58,0.57,0.59,0.59,0.59,0.59,0.59,0.58,0.58,0.58,0.58];
			var rewards = [0.3,0.23,0.14,0.22,0.33,0.46,0.6,0.67,0.44,0.33,0.25,0.34,0.56,0.75,0.73,0.6,0.42,0.42,0.34,0.41,0.68,0.93,0.77,0.48,0.37,0.51,0.38,0.36,0.37,0.46,0.6,0.71,0.6,0.43,0.36,0.38,0.44,0.52,0.54,0.52,0.43,0.35,0.34,0.37,0.45,0.52,0.43,0.3,0.26,0.62,0.52,0.47,0.43,0.44,0.52,0.7,0.65,0.43,0.42,0.42,0.37,0.33,0.33,0.42,0.39,0.27,0.33,0.36,0.3,0.21,0.15,0.15,0.16,0.37,0.16,0.21,0.37,0.57,0.77,0.85,0.61,0.32,0.15,0.3,0.68,0.94,0.94,0.82,0.54,0.25,0.12,0.32,0.8,1,0.93,0.62,0.42,0.62,0.36,0.3,0.38,0.58,0.77,0.82,0.71,0.43,0.27,0.31,0.48,0.65,0.7,0.64,0.51,0.25,0.17,0.28,0.48,0.64,0.52,0.39,0.3,0.56,0.38,0.34,0.38,0.5,0.59,0.64,0.61,0.37,0.29,0.3,0.31,0.36,0.38,0.41,0.38,0.2,0.2,0.25,0.22,0.19,0.15,0.17,0.17,0.45,0.27,0.28,0.41,0.57,0.8,0.99,0.74,0.35,0.16,0.24,0.54,0.75,0.86,0.93,0.67,0.22,0.07,0.23,0.6,0.82,0.75,0.68,0.5,0.54,0.32,0.3,0.43,0.62,0.76,0.83,0.71,0.39,0.22,0.24,0.42,0.6,0.68,0.71,0.58,0.24,0.13,0.19,0.36,0.52,0.51,0.5,0.41,0.45,0.26,0.29,0.44,0.61,0.6,0.59,0.57,0.34,0.21,0.22,0.3,0.44,0.46,0.47,0.44,0.24,0.17,0.15,0.15,0.25,0.3,0.32,0.31,0.16,0.14,0.23,0.33,0.54,0.74,0.83,0.48,0.31,0.23,0.3,0.48,0.75,0.91,0.8,0.49,0.45,0.32,0.35,0.55,0.83,0.89,0.63,0.47,0.49,0.42,0.42,0.44,0.6,0.75,0.81,0.62,0.42,0.35,0.37,0.43,0.56,0.64,0.59,0.46,0.36,0.3,0.32,0.38,0.46,0.43,0.32,0.31,0.76,0.67,0.61,0.58,0.7,0.76,0.79,0.73,0.49,0.46,0.45,0.42,0.43,0.41,0.42,0.44,0.27,0.27,0.31,0.25,0.16,0.05,0.08,0.18,0.22,0.08,0.13,0.26,0.57,0.89,0.97,0.58,0.18,0,0.14,0.47,0.89,1,1,0.6,0.12,0,0.15,0.56,0.96,1,0.88,0.49,0.48,0.27,0.25,0.33,0.6,0.89,0.95,0.71,0.29,0.12,0.19,0.36,0.61,0.82,0.78,0.53,0.11,0,0.13,0.31,0.49,0.53,0.46,0.31,0.63,0.4,0.36,0.4,0.62,0.82,0.89,0.77,0.34,0.2,0.23,0.26,0.35,0.43,0.48,0.44,0.09,0.03,0.11,0.09,0.06,0,0.07,0.14,0.35,0.19,0.18,0.31,0.52,0.8,0.97,0.68,0.22,0,0.08,0.38,0.69,1,1,0.71,0.06,0,0.07,0.43,0.71,0.86,0.88,0.57,0.45,0.22,0.22,0.34,0.54,0.75,0.87,0.71,0.28,0.07,0.12,0.3,0.53,0.73,0.82,0.61,0.1,0,0.07,0.26,0.43,0.53,0.57,0.42,0.48,0.22,0.24,0.37,0.54,0.65,0.74,0.71,0.29,0.12,0.15,0.24,0.37,0.45,0.53,0.49,0.13,0.03,0.07,0.1,0.18,0.21,0.28,0.28,0.19,0.22,0.28,0.37,0.61,0.7,0.68,0.42,0.21,0.21,0.29,0.42,0.67,0.83,0.72,0.41,0.21,0.19,0.3,0.43,0.61,0.75,0.64,0.38,0.38,0.35,0.39,0.48,0.74,0.84,0.78,0.54,0.3,0.28,0.34,0.42,0.59,0.67,0.59,0.42,0.24,0.23,0.29,0.33,0.38,0.39,0.36,0.29,0.61,0.5,0.5,0.62,0.92,1,0.91,0.71,0.41,0.37,0.39,0.43,0.55,0.55,0.51,0.45,0.26,0.27,0.29,0.24,0.18,0.07,0.13,0.23,0.16,0.14,0.16,0.21,0.54,0.83,0.8,0.45,0.06,0,0.14,0.32,0.72,1,0.99,0.47,0,0,0.12,0.37,0.67,0.96,0.89,0.39,0.35,0.24,0.25,0.32,0.64,0.96,0.97,0.63,0.17,0.1,0.18,0.28,0.56,0.83,0.78,0.46,0.03,0,0.13,0.21,0.36,0.48,0.48,0.27,0.61,0.38,0.34,0.43,0.76,1,1,0.85,0.32,0.22,0.23,0.25,0.42,0.58,0.61,0.48,0.12,0.1,0.12,0.06,0.06,0.02,0.09,0.17,0.29,0.23,0.23,0.27,0.46,0.68,0.72,0.51,0.17,0.05,0.14,0.31,0.57,0.86,0.89,0.54,0.02,0,0.12,0.34,0.54,0.75,0.79,0.46,0.38,0.26,0.26,0.32,0.5,0.71,0.78,0.6,0.24,0.13,0.18,0.28,0.47,0.68,0.72,0.51,0.11,0.03,0.14,0.23,0.36,0.48,0.53,0.37,0.5,0.31,0.3,0.36,0.54,0.75,0.85,0.72,0.33,0.21,0.22,0.25,0.37,0.5,0.56,0.49,0.19,0.14,0.15,0.13,0.19,0.22,0.28,0.29];

			return rewards[r_index];
		}
		else {
			return 0.5;
		}
    };

	this.getReward_4_7 = function() {

		if(rewardId == 1) return 0.5;

        var f_classes = self.getFeatures_4_7().map(function(v) { return v-1; });
		
		var lox_index = [0, 144, 288];
		var loy_index = [0,  48,  96];
		var vel_index = [0,8,16,24,32,40];
		var dir_index = [1,2,3,4,5,6,7,8];

		var r_index = lox_index[f_classes[0]] + loy_index[f_classes[1]] + vel_index[f_classes[2]] + dir_index[f_classes[3]];

		if(rewardId == 2) {
			  var rewards = [0.38,0.44,0.44,0.44,0.46,0.47,0.46,0.44,0.43,0.44,0.44,0.45,0.46,0.46,0.45,0.44,0.44,0.44,0.44,0.45,0.48,0.48,0.47,0.44,0.43,0.43,0.42,0.45,0.54,0.58,0.53,0.43,0.4,0.4,0.32,0.36,0.69,0.88,0.69,0.35,0.28,0.37,0.22,0.28,0.84,1,0.85,0.26,0.14,0.44,0.43,0.43,0.45,0.48,0.47,0.44,0.43,0.44,0.44,0.44,0.45,0.47,0.46,0.44,0.44,0.44,0.43,0.44,0.47,0.49,0.49,0.45,0.43,0.44,0.39,0.39,0.5,0.61,0.57,0.42,0.39,0.41,0.22,0.18,0.56,1,0.8,0.28,0.22,0.37,0.04,0,0.63,1,1,0.13,0.04,0.44,0.43,0.43,0.44,0.46,0.45,0.44,0.43,0.44,0.44,0.44,0.44,0.46,0.45,0.44,0.44,0.44,0.43,0.43,0.45,0.47,0.47,0.44,0.44,0.42,0.38,0.38,0.45,0.53,0.5,0.41,0.4,0.35,0.19,0.16,0.43,0.74,0.58,0.27,0.26,0.28,0,0,0.41,0.96,0.67,0.12,0.11,0.44,0.44,0.44,0.46,0.47,0.46,0.43,0.43,0.44,0.44,0.45,0.47,0.47,0.46,0.44,0.44,0.44,0.45,0.49,0.55,0.54,0.52,0.46,0.44,0.44,0.43,0.49,0.65,0.67,0.59,0.45,0.41,0.39,0.29,0.3,0.63,0.82,0.62,0.25,0.24,0.35,0.14,0.09,0.62,1,0.65,0.04,0.06,0.44,0.42,0.43,0.45,0.48,0.47,0.43,0.43,0.44,0.44,0.44,0.46,0.48,0.48,0.45,0.44,0.44,0.43,0.46,0.52,0.56,0.57,0.49,0.44,0.41,0.37,0.42,0.59,0.74,0.71,0.49,0.4,0.29,0.09,0.12,0.63,1,0.88,0.26,0.18,0.16,0,0,0.68,1,1,0.03,0,0.44,0.43,0.43,0.45,0.47,0.46,0.44,0.43,0.44,0.44,0.44,0.45,0.47,0.46,0.45,0.44,0.44,0.43,0.44,0.47,0.5,0.51,0.46,0.44,0.4,0.36,0.4,0.51,0.6,0.58,0.45,0.4,0.27,0.1,0.2,0.6,0.84,0.62,0.26,0.23,0.14,0,0,0.69,1,0.67,0.07,0.06,0.44,0.44,0.44,0.46,0.47,0.46,0.44,0.44,0.45,0.45,0.47,0.49,0.49,0.48,0.46,0.44,0.45,0.46,0.54,0.64,0.61,0.57,0.5,0.45,0.44,0.45,0.59,0.8,0.76,0.7,0.53,0.43,0.37,0.3,0.39,0.69,0.78,0.7,0.4,0.29,0.3,0.15,0.2,0.6,0.82,0.72,0.27,0.15,0.43,0.43,0.44,0.46,0.48,0.47,0.45,0.44,0.44,0.44,0.45,0.48,0.49,0.5,0.47,0.45,0.44,0.44,0.49,0.57,0.62,0.65,0.54,0.46,0.4,0.39,0.49,0.69,0.8,0.85,0.6,0.44,0.22,0.11,0.27,0.67,0.96,0.92,0.45,0.27,0.05,0,0.05,0.67,1,1,0.31,0.1,0.43,0.43,0.44,0.46,0.46,0.46,0.44,0.44,0.44,0.44,0.45,0.46,0.47,0.47,0.46,0.44,0.44,0.43,0.46,0.49,0.53,0.55,0.49,0.45,0.39,0.38,0.45,0.56,0.62,0.65,0.52,0.43,0.23,0.15,0.37,0.68,0.74,0.63,0.39,0.32,0.08,0,0.29,0.81,0.88,0.63,0.27,0.21];
			return rewards[r_index];
		}
		else {
			return 0.5;
		}
    };
	
	this.getReward_4_8 = function() {

		if(rewardId == 1) return 0.5;

        var f_classes = self.getFeatures_4_8().map(function(v) { return v-1; });
		
		var lox_index = [0, 144, 288];
		var loy_index = [0,  48,  96];
		var vel_index = [0,8,16,24,32,40];
		var dir_index = [1,2,3,4,5,6,7,8];

		var r_index = lox_index[f_classes[0]] + loy_index[f_classes[1]] + vel_index[f_classes[2]] + dir_index[f_classes[3]];

		if(rewardId == 2) {
			var rewards = [0.98,0.55,0.54,0.53,0.54,0.56,0.53,0.52,0.53,0.54,0.53,0.53,0.54,0.55,0.53,0.52,0.53,0.54,0.53,0.53,0.56,0.57,0.53,0.52,0.52,0.59,0.54,0.51,0.59,0.65,0.52,0.46,0.5,0.8,0.56,0.41,0.64,0.9,0.42,0.21,0.41,1,0.58,0.3,0.7,1,0.31,0,0.31,0.56,0.53,0.52,0.53,0.55,0.53,0.52,0.53,0.54,0.53,0.53,0.54,0.55,0.53,0.52,0.53,0.54,0.52,0.52,0.55,0.57,0.54,0.52,0.52,0.62,0.52,0.47,0.55,0.64,0.52,0.46,0.52,0.93,0.49,0.25,0.48,0.84,0.4,0.22,0.52,1,0.47,0.01,0.41,1,0.27,0,0.51,0.54,0.52,0.52,0.53,0.55,0.53,0.53,0.53,0.53,0.53,0.53,0.53,0.54,0.54,0.53,0.53,0.53,0.52,0.52,0.53,0.56,0.54,0.53,0.53,0.56,0.49,0.46,0.51,0.6,0.54,0.5,0.53,0.65,0.35,0.23,0.41,0.73,0.52,0.39,0.51,0.75,0.2,0,0.3,0.87,0.5,0.27,0.49,0.56,0.54,0.52,0.54,0.55,0.52,0.51,0.52,0.54,0.54,0.54,0.55,0.56,0.53,0.52,0.53,0.55,0.54,0.56,0.61,0.61,0.55,0.51,0.52,0.62,0.55,0.55,0.66,0.7,0.52,0.43,0.49,0.89,0.58,0.35,0.54,0.77,0.28,0.09,0.35,1,0.6,0.14,0.42,0.85,0.05,0,0.21,0.56,0.53,0.51,0.53,0.55,0.52,0.51,0.53,0.54,0.53,0.53,0.54,0.56,0.54,0.52,0.53,0.55,0.53,0.54,0.59,0.63,0.56,0.52,0.52,0.65,0.53,0.48,0.6,0.72,0.54,0.45,0.52,1,0.5,0.16,0.37,0.76,0.33,0.13,0.48,1,0.47,0,0.13,0.82,0.11,0,0.45,0.55,0.52,0.51,0.53,0.55,0.54,0.53,0.53,0.54,0.53,0.52,0.54,0.55,0.54,0.53,0.53,0.54,0.52,0.52,0.55,0.58,0.55,0.53,0.53,0.58,0.48,0.46,0.53,0.65,0.57,0.5,0.53,0.74,0.33,0.16,0.36,0.75,0.54,0.37,0.51,0.9,0.16,0,0.17,0.87,0.52,0.23,0.49,0.55,0.54,0.53,0.54,0.55,0.53,0.52,0.53,0.54,0.54,0.55,0.57,0.57,0.54,0.53,0.53,0.55,0.55,0.6,0.68,0.66,0.57,0.53,0.53,0.62,0.58,0.62,0.78,0.77,0.57,0.47,0.51,0.86,0.62,0.45,0.59,0.72,0.36,0.21,0.4,1,0.67,0.27,0.4,0.67,0.15,0,0.3,0.56,0.54,0.52,0.53,0.54,0.53,0.52,0.53,0.55,0.54,0.54,0.56,0.57,0.55,0.53,0.53,0.56,0.54,0.57,0.65,0.68,0.59,0.53,0.53,0.65,0.56,0.55,0.7,0.8,0.61,0.49,0.53,1,0.58,0.29,0.41,0.68,0.4,0.25,0.52,1,0.6,0.02,0.13,0.57,0.18,0,0.51,0.55,0.53,0.52,0.53,0.54,0.54,0.53,0.54,0.54,0.53,0.53,0.54,0.55,0.54,0.53,0.54,0.55,0.53,0.53,0.57,0.61,0.57,0.54,0.54,0.59,0.51,0.49,0.57,0.68,0.6,0.52,0.54,0.78,0.43,0.25,0.36,0.67,0.57,0.44,0.56,0.97,0.34,0,0.14,0.66,0.55,0.35,0.58];
			//var rewards = [0.38,0.44,0.44,0.44,0.46,0.47,0.46,0.44,0.43,0.44,0.44,0.45,0.46,0.46,0.45,0.44,0.44,0.44,0.44,0.45,0.48,0.48,0.47,0.44,0.43,0.43,0.42,0.45,0.54,0.58,0.53,0.43,0.4,0.4,0.32,0.36,0.69,0.88,0.69,0.35,0.28,0.37,0.22,0.28,0.84,1,0.85,0.26,0.14,0.44,0.43,0.43,0.45,0.48,0.47,0.44,0.43,0.44,0.44,0.44,0.45,0.47,0.46,0.44,0.44,0.44,0.43,0.44,0.47,0.49,0.49,0.45,0.43,0.44,0.39,0.39,0.5,0.61,0.57,0.42,0.39,0.41,0.22,0.18,0.56,1,0.8,0.28,0.22,0.37,0.04,0,0.63,1,1,0.13,0.04,0.44,0.43,0.43,0.44,0.46,0.45,0.44,0.43,0.44,0.44,0.44,0.44,0.46,0.45,0.44,0.44,0.44,0.43,0.43,0.45,0.47,0.47,0.44,0.44,0.42,0.38,0.38,0.45,0.53,0.5,0.41,0.4,0.35,0.19,0.16,0.43,0.74,0.58,0.27,0.26,0.28,0,0,0.41,0.96,0.67,0.12,0.11,0.44,0.44,0.44,0.46,0.47,0.46,0.43,0.43,0.44,0.44,0.45,0.47,0.47,0.46,0.44,0.44,0.44,0.45,0.49,0.55,0.54,0.52,0.46,0.44,0.44,0.43,0.49,0.65,0.67,0.59,0.45,0.41,0.39,0.29,0.3,0.63,0.82,0.62,0.25,0.24,0.35,0.14,0.09,0.62,1,0.65,0.04,0.06,0.44,0.42,0.43,0.45,0.48,0.47,0.43,0.43,0.44,0.44,0.44,0.46,0.48,0.48,0.45,0.44,0.44,0.43,0.46,0.52,0.56,0.57,0.49,0.44,0.41,0.37,0.42,0.59,0.74,0.71,0.49,0.4,0.29,0.09,0.12,0.63,1,0.88,0.26,0.18,0.16,0,0,0.68,1,1,0.03,0,0.44,0.43,0.43,0.45,0.47,0.46,0.44,0.43,0.44,0.44,0.44,0.45,0.47,0.46,0.45,0.44,0.44,0.43,0.44,0.47,0.5,0.51,0.46,0.44,0.4,0.36,0.4,0.51,0.6,0.58,0.45,0.4,0.27,0.1,0.2,0.6,0.84,0.62,0.26,0.23,0.14,0,0,0.69,1,0.67,0.07,0.06,0.44,0.44,0.44,0.46,0.47,0.46,0.44,0.44,0.45,0.45,0.47,0.49,0.49,0.48,0.46,0.44,0.45,0.46,0.54,0.64,0.61,0.57,0.5,0.45,0.44,0.45,0.59,0.8,0.76,0.7,0.53,0.43,0.37,0.3,0.39,0.69,0.78,0.7,0.4,0.29,0.3,0.15,0.2,0.6,0.82,0.72,0.27,0.15,0.43,0.43,0.44,0.46,0.48,0.47,0.45,0.44,0.44,0.44,0.45,0.48,0.49,0.5,0.47,0.45,0.44,0.44,0.49,0.57,0.62,0.65,0.54,0.46,0.4,0.39,0.49,0.69,0.8,0.85,0.6,0.44,0.22,0.11,0.27,0.67,0.96,0.92,0.45,0.27,0.05,0,0.05,0.67,1,1,0.31,0.1,0.43,0.43,0.44,0.46,0.46,0.46,0.44,0.44,0.44,0.44,0.45,0.46,0.47,0.47,0.46,0.44,0.44,0.43,0.46,0.49,0.53,0.55,0.49,0.45,0.39,0.38,0.45,0.56,0.62,0.65,0.52,0.43,0.23,0.15,0.37,0.68,0.74,0.63,0.39,0.32,0.08,0,0.29,0.81,0.88,0.63,0.27,0.21];
			return rewards[r_index];
		}
		else {
			return 0.5;
		}
    };
	
    this.getFeatures_4_5 = function () {

		var lox_class = x_pct <= 1/3 ? 1 : x_pct <= 2/3 ? 2 : 3;
		var loy_class = y_pct <= 1/3 ? 1 : y_pct <= 2/3 ? 2 : 3;

		var mouseX = mouse.getX();
        var mouseY = mouse.getY();

		var dir_radian = Math.atan2(effectiveY - mouseY, effectiveX - mouseX);
		var dir_class  = Math.floor( (dir_radian + 3*Math.PI/8) / (Math.PI/4) );

		if(dir_class <= 0) {
			dir_class += 8;
		}

		var age_value = self.getAge();
		var age_class = age_value <= 250 ? 1 : age_value <= 500 ? 2 : age_value <= 750 ? 3 : 4;

		return [lox_class, loy_class, dir_class, age_class];
    };
	
	this.getFeatures_4_6 = function () {
	
		var vox_pct = mouse.getVelocity(0)/99;
		var voy_pct = mouse.getVelocity(1)/99;
		var dir_rad = isPal ? mouse.getDirectionFromCenter() : mouse.getDirectionFrom(effectiveX, effectiveY);

		var lox_class = x_pct   <= 1/3 ? 1 : x_pct   <= 2/3 ? 2 : 3;
		var loy_class = y_pct   <= 1/3 ? 1 : y_pct   <= 2/3 ? 2 : 3;
		var vox_class = vox_pct <= 1/3 ? 1 : vox_pct <= 2/3 ? 2 : 3;
		var voy_class = voy_pct <= 1/3 ? 1 : voy_pct <= 2/3 ? 2 : 3;
		var dir_class  = Math.floor( (dir_rad + 3*Math.PI/8) / (Math.PI/4) );

		if(dir_class <= 0) {
			dir_class += 8;
		}

		return [lox_class, loy_class, vox_class, voy_class, dir_class];
    };
	
	this.getFeatures_4_7 = function () {

		var d_rad = mouse.getDirectionTo(effectiveX, effectiveY);
		var v_pct = mouse.getVelocity(2)/78;
		
		var x_class = x_pct <= 1/3 ? 1 : x_pct <= 2/3 ? 2 : 3;
		var y_class = y_pct <= 1/3 ? 1 : y_pct <= 2/3 ? 2 : 3;
		var v_class = v_pct <= 1/6 ? 1 : v_pct <= 2/6 ? 2 : v_pct <= 3/6 ? 3 : v_pct <= 4/6 ? 4 : v_pct <= 5/6 ? 5 : 6;
		var d_class  = Math.floor( (d_rad + 3*Math.PI/8) / (Math.PI/4) );

		if(d_class <= 0) {
			d_class += 8;
		}

		return [x_class, y_class, v_class, d_class];
    };
	
	this.getFeatures_4_8 = function () {
		
		var d_rad = self.isTouched() ? mouse.getVelocity(3) : mouse.getDirectionTo(effectiveX, effectiveY);
		var v_pct = mouse.getVelocity(2)/78;
		
		var x_class = x_pct <= 1/3 ? 1 : x_pct <= 2/3 ? 2 : 3;
		var y_class = y_pct <= 1/3 ? 1 : y_pct <= 2/3 ? 2 : 3;
		var v_class = v_pct <= 1/6 ? 1 : v_pct <= 2/6 ? 2 : v_pct <= 3/6 ? 3 : v_pct <= 4/6 ? 4 : v_pct <= 5/6 ? 5 : 6;
		var d_class  = Math.floor( (d_rad + 3*Math.PI/8) / (Math.PI/4) );

		if(d_class <= 0) {
			d_class += 8;
		}

		return [x_class, y_class, v_class, d_class];
    };

    this.draw = function(canvas) {		
	
        effectiveR = Math.round(radius * (canvas.getAreaPctSqrt()                 )             );
        effectiveX = Math.round(x_pct  * (canvas.getResolution(0) - 2 * effectiveR) + effectiveR);
        effectiveY = Math.round(y_pct  * (canvas.getResolution(1) - 2 * effectiveR) + effectiveR);

        var context = canvas.getContext2d();

        var xOffset = _renderer.xOffset(self.getReward(), 0, 1);
        var yOffset = _renderer.yOffset(self.getAge());

		if(self.isTouched()) {
			xOffsetOnTouch = xOffsetOnTouch || xOffset;
			context.drawImage(_prerender_y_touch,xOffsetOnTouch,yOffset, 200, 200, effectiveX-effectiveR, effectiveY-effectiveR, 2*effectiveR, 2*effectiveR);
		}
		else {
			xOffsetOnTouch = 0;
			context.drawImage(_prerender_n_touch,xOffset,yOffset, 200, 200, effectiveX-effectiveR, effectiveY-effectiveR, 2*effectiveR, 2*effectiveR);
		}
    }

    function dist(x1,y1,x2,y2) {
        return Math.sqrt(Math.pow(x1-x2,2)+Math.pow(y1-y2,2));
    }
}

function TargetRenderer(fadeInTime, fadeOffTime, fadeOutTime, lifespan) {

	var target_radius = 100;

	var rewSteps = 40;
	var ageSteps = 20;

	var width  = 200;
	var height = 200;

    fadeInTime  *= lifespan;
    fadeOffTime *= lifespan;
    fadeOutTime *= lifespan;

    this.evenOpacity = function(ageStep) {
		return ageStep / ageSteps;
    }

    this.gradientRGB = function(rewStep) {

        var c_stop0 = [200, 0  ,  0 ];
        var c_stop1 = [ 0 , 200,  0 ];
        var c_stop2 = [ 0 , 0  , 200];

        var c_val0 = 0.0 * rewSteps;
        var c_val1 = 0.5 * rewSteps;
        var c_val2 = 1.0 * rewSteps;

		var c_wgt0 = 0;
		var c_wgt1 = 0;
		var c_wgt2 = 0;

		if(c_val0 <= rewStep && rewStep < c_val1) {
			c_wgt0 = Math.max(0, Math.min((1       ),(c_val1 - rewStep)/(c_val1-c_val0)));
			c_wgt1 = Math.max(0, Math.min((1-c_wgt0),(c_val2 - rewStep)/(c_val2-c_val1)));
		} 
		if(c_val1 <= rewStep && rewStep <= c_val2) {
			c_wgt1 = Math.max(0, Math.min((1-c_wgt0),(c_val2 - rewStep)/(c_val2-c_val1)));
		    c_wgt2 = Math.max(0, Math.min((1-c_wgt1),(1                               ))); 
		}			

        var color = [
            c_wgt0*c_stop0[0]+c_wgt1*c_stop1[0]+c_wgt2*c_stop2[0],
            c_wgt0*c_stop0[1]+c_wgt1*c_stop1[1]+c_wgt2*c_stop2[1],
            c_wgt0*c_stop0[2]+c_wgt1*c_stop1[2]+c_wgt2*c_stop2[2]
        ];

        color = color.map(function(c) { return Math.round(c,0); });
        
        return color.join(',');
	}

	this.allBlack = function(rewStep) {
		return "0,0,0";
	}

	this.allGray90 = function(rewStep) {
		return "90,90,90";
	}
	
	this.allGray150 = function(rewStep) {
		return "150,150,150";
	}

	this.mediumStroke = function(rewStep) {
		return 10;
	}
	
	this.heavyStroke = function(rewStep) {
		return 12;
	}
	
	this.evenFill = function(rewStep) {
		return rewStep/rewSteps * target_radius;
	}
	
	this.prerender = function(fill_color, line_color, fill_radius, stroke_width, opacity) {

        var canvas = document.createElement("canvas");

		canvas.width  = rewSteps * width;
		canvas.height = ageSteps * height;

		var context = canvas.getContext("2d");

		for(var rewStep = 0; rewStep < rewSteps; rewStep++) {
            for(var ageStep = 0; ageStep < ageSteps; ageStep++) {
				
				var xOffset = rewStep * width  + target_radius;
                var yOffset = ageStep * height + target_radius;
                			
				var center_radius = fill_radius(rewStep);
				var stroke_weight = stroke_width(rewStep);
				var stroke_begins = target_radius-(stroke_weight/2);
				
				var fill_style = "rgba(" + fill_color(rewStep) + "," + opacity(ageStep) + ")";
				var line_style = "rgba(" + line_color(rewStep) + "," + opacity(ageStep) + ")";

				context.beginPath();
				context.fillStyle = "rgb(255,255,255)";
				context.arc(xOffset, yOffset, target_radius, 0, 2 * Math.PI);
				context.fill();
				
				context.beginPath();
				context.fillStyle = fill_style;
				context.arc(xOffset, yOffset, center_radius, 0, 2 * Math.PI);
				context.fill();
				
				context.beginPath();
				context.lineWidth = stroke_weight;
				context.strokeStyle = line_style;
				context.arc(xOffset, yOffset, stroke_begins, 0, 2 * Math.PI);
				context.stroke();
			}
        }
        
        return canvas;
    }
	
    this.xOffset = function (reward, min, max) {
		return 200 * Math.round((reward-min)/(max-min) * (rewSteps-1));
    }
    
    this.yOffset = function(age) {
		var o_value   = 0;

        if (age <= fadeInTime){
            o_value = age/fadeInTime;
        }

        if (fadeInTime <= age && age <= fadeInTime+fadeOffTime){
            o_value = 1;
        }

        if (fadeInTime+fadeOffTime <= age && age <= fadeInTime+fadeOffTime+fadeOutTime){
            o_value = (fadeInTime+fadeOffTime+fadeOutTime-age) / fadeOutTime;
        }

        if (age >= fadeInTime+fadeOffTime+fadeOutTime) {
            o_value = 0;
        }		
		
        return 200 * Math.round(o_value * (ageSteps-1));
    }

	this.sample = function(canvas, x,y) {
		
		var context     = canvas.getContext2d();
		var x_step_size = 125;
		var radius      = 50;
		
		for(var r = -1; r <= 1; r+=.05) {
			
			var yOffset = _renderer.yOffset(985);
			var xOffset = _renderer.xOffset(r);
			
			context.drawImage(_prerender, xOffset, yOffset, 200, 200, (r+1)*x_step_size, 0, 2*radius, 2*radius);
		}

		var highlight = function(r) {
			context.beginPath();
			context.fillStyle = "rgba(256,256,256,1)";
			context.arc((r+1)*x_step_size + radius, 0 + radius, radius - 4, 0, 2 * Math.PI);
			context.fill();
			context.drawImage(_prerender, _renderer.xOffset(r), _renderer.yOffset(0), 200, 200, (r+1)*x_step_size, 0, 2*radius, 2*radius);
		}
		
		highlight(-1.0);
		highlight(-0.5);
		highlight( 0.0);
		highlight( 0.5);
		highlight( 1.0);
	}
}