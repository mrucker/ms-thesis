var _renderer  = new TargetRenderer(0, .5, .5, 1000);

var _prerender_n_touch = _renderer.prerender(_renderer.gradientRGB, _renderer.evenOpacity, _renderer.evenFill, _renderer.mediumStroke);
var _prerender_y_touch = _renderer.prerender(_renderer.allBlack   , _renderer.evenOpacity, _renderer.evenFill, _renderer.mediumStroke);

function Targets(mouse, featureWeights) {
    var radius     = 150;
    var targets    = [];
    var effectiveA = 0;
    var effectiveR = 0;
    
    //if you change this 200 value be sure to remember to also change the matlab huge_trans_pre function as well
    var process = poissonProcess.create(200, function () { targets.push(new Target(mouse, featureWeights))} );

    this.startAppearing = function() {
        process.start();
    }

    this.stopAppearing = function() {
        process.stop();
    }

    this.draw = function(canvas){

        effectiveA = (canvas.getResolution(0)/3000) * (canvas.getResolution(1)/1500) * (Math.PI * radius * radius);
        effectiveR = Math.round(Math.sqrt(effectiveA/Math.PI),0);

		//_renderer.sample(canvas,0,0);
		
		var context = canvas.getContext2d();
		
        targets.forEach(function(target){ target.setR(effectiveR); target.draw(canvas); });

        targets = targets.filter(function(target) {return !target.isDead();} );
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

function Target(mouse, featureWeights) {
    var x = null;
    var y = null;
    var r = 0;
    var g = 0;
    var b = 0;

    var originalX       = x;
    var originalY       = y;
    var originalWidth   = 0;
    var originalHeight  = 0;
    var effectiveX      = 0;
    var effectiveY      = 0;
    var effectiveR      = 0;
    var createTime      = Date.now();
    var touchedBefore   = false;
    var self            = this;
    
    this.setR   = function(r){ effectiveR = r;    }; 
    this.getR   = function() { return effectiveR; };
    this.getX   = function() { return effectiveX; };
    this.getY   = function() { return effectiveY; };
    this.getAge = function() { return Date.now() - createTime; };    
    this.isDead = function() { return self.getAge() >= 100 && _renderer.yOffset(self.getAge()) == 0;};
    
    this.getData     = function() { 
        return [
            Math.round(self.getX()     ,0),
            Math.round(self.getY()     ,0),
            Math.round(self.getAge()   ,0),
        ]; 
    };
    
    this.isNewTouch = function() {
        
        if (self.isTouched() && !touchedBefore) {
            touchedBefore = true;
            return true;
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
        var r_param = featureWeights;
        var f_value = self.getFeatures();
        var r_value = f_value[0]*r_param[0] + f_value[1]*r_param[1] + f_value[2]*r_param[2] + f_value[3]*r_param[3] + f_value[4]*r_param[4];

        r_value = r_value * 1/r_param[4];
        r_value = Math.max(r_value,-1);
        r_value = Math.min(r_value, 1);

        return r_value;
    };
    
    this.getFeatures = function () {
        var maxD = 3526;

        var mouseHistPos = mouse.getHistoryPos();
        var mouseHistDot = mouse.getHistoryDot();

        var targetLoc    = [effectiveX,effectiveY];
        var targetLocDot = Math.pow(effectiveX,2) + Math.pow(effectiveY,2);

        var d3 = targetLocDot + mouseHistDot[0] - 2*(targetLoc[0]*mouseHistPos[0][0] + targetLoc[1]*mouseHistPos[0][1]);
        var d2 = targetLocDot + mouseHistDot[1] - 2*(targetLoc[0]*mouseHistPos[1][0] + targetLoc[1]*mouseHistPos[1][1]);
        var d1 = targetLocDot + mouseHistDot[2] - 2*(targetLoc[0]*mouseHistPos[2][0] + targetLoc[1]*mouseHistPos[2][1]);
        var d0 = targetLocDot + mouseHistDot[3] - 2*(targetLoc[0]*mouseHistPos[3][0] + targetLoc[1]*mouseHistPos[3][1]);

        d3 = d3/Math.pow(maxD,2);
        d2 = d2/Math.pow(maxD,2);
        d1 = d1/Math.pow(maxD,2);
        d0 = d0/Math.pow(maxD,2);

        d3 = Math.sqrt(d3);
        d2 = Math.sqrt(d2);
        d1 = Math.sqrt(d1);
        d0 = Math.sqrt(d0);
        
        var d = d3;
        var v = d3-d2;
        var a = d3/2-d2+d1/2;
        var j = d3/4-3*d2/4+3*d1/4-d0/4;

        return [d, v, a, j, self.isTouched()*1];
    };
    
    this.draw = function(canvas, r) {
        self.drawImage(canvas, r);
    }

    this.drawCircle = function(canvas){

        originalWidth   = originalWidth  || canvas.getResolution(0);
        originalHeight  = originalHeight || canvas.getResolution(1);
        originalX       = originalX      || (canvas.getResolution(0) - effectiveR*2) * Math.random() + effectiveR;
        originalY       = originalY      || (canvas.getResolution(1) - effectiveR*2) * Math.random() + effectiveR;

        effectiveX = Math.round((originalX/originalWidth ) * canvas.getResolution(0),0);
        effectiveY = Math.round((originalY/originalHeight) * canvas.getResolution(1),0);

        var context   = canvas.getContext2d();

        context.fillStyle = fillStyle();
        context.beginPath();
        context.arc(effectiveX, effectiveY, effectiveR, 0, 2 * Math.PI);
        context.fill(); 
    }

    this.drawSquare = function(canvas){

        originalWidth   = originalWidth  || canvas.getResolution(0);
        originalHeight  = originalHeight || canvas.getResolution(1);
        originalX       = originalX      || (canvas.getResolution(0) - effectiveR*2) * Math.random() + effectiveR;
        originalY       = originalY      || (canvas.getResolution(1) - effectiveR*2) * Math.random() + effectiveR;

        effectiveX = Math.round((originalX/originalWidth ) * canvas.getResolution(0),0);
        effectiveY = Math.round((originalY/originalHeight) * canvas.getResolution(1),0);

        var context = canvas.getContext2d();

        context.fillStyle = fillStyle();
        context.fillRect(effectiveX-effectiveL/2, effectiveY-effectiveL/2, effectiveL, effectiveL); 
    }

    this.drawImage = function(canvas){

        originalWidth   = originalWidth  || canvas.getResolution(0);
        originalHeight  = originalHeight || canvas.getResolution(1);
        originalX       = originalX      || (canvas.getResolution(0) - effectiveR*2) * Math.random() + effectiveR;
        originalY       = originalY      || (canvas.getResolution(1) - effectiveR*2) * Math.random() + effectiveR;

        effectiveX = Math.round((originalX/originalWidth ) * canvas.getResolution(0),0);
        effectiveY = Math.round((originalY/originalHeight) * canvas.getResolution(1),0);

        var context = canvas.getContext2d();

        var xOffset = _renderer.xOffset(self.getReward());
        var yOffset = _renderer.yOffset(self.getAge());

		if(self.isTouched()) {
			context.drawImage(_prerender_y_touch,xOffset,yOffset, 200, 200, effectiveX-effectiveR, effectiveY-effectiveR, 2*effectiveR, 2*effectiveR);
		}
		else {
			context.drawImage(_prerender_n_touch,xOffset,yOffset, 200, 200, effectiveX-effectiveR, effectiveY-effectiveR, 2*effectiveR, 2*effectiveR);
		}
			
    }

    function dist(x1,y1,x2,y2) {
        return Math.sqrt(Math.pow(x1-x2,2)+Math.pow(y1-y2,2));
    }

    function fillStyle() {
        return 'rgba('+ renderer.rgb(self.getReward()) +','+ renderer.opacity(self.getAge()) +')';
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

	this.allGray = function(rewStep) {
		return "150,150,150";
	}

	this.mediumStroke = function(rewStep) {
		return 10;
	}
	
	this.evenFill = function(rewStep) {
		return rewStep/rewSteps * target_radius;
	}
	
	this.prerender = function(color, opacity, fill, stroke) {

        var canvas = document.createElement("canvas");

		canvas.width  = rewSteps * width;
		canvas.height = ageSteps * height;

		var context = canvas.getContext("2d");

        for(var rewStep = 0; rewStep < rewSteps; rewStep++) {
            for(var ageStep = 0; ageStep < ageSteps; ageStep++) {
				
				var xOffset = rewStep * width  + target_radius;
                var yOffset = ageStep * height + target_radius;
                			
				var center_radius = fill(rewStep);
				var stroke_weight = stroke(rewStep);
				var stroke_begins = target_radius - stroke_weight;
				
				var style = "rgba(" + color(rewStep) + "," + opacity(ageStep) + ")";
				
				if ( center_radius < stroke_begins ) {
					context.beginPath();
					context.lineWidth = stroke_weight;
					context.strokeStyle = style;
					context.arc(xOffset, yOffset, stroke_begins, 0, 2 * Math.PI);
					context.stroke();

					context.beginPath();
					context.fillStyle = style;
					context.arc(xOffset, yOffset, center_radius, 0, 2 * Math.PI);
					context.fill();
				}
				else {
					context.beginPath();
					context.fillStyle = style;
					context.arc(xOffset, yOffset, target_radius, 0, 2 * Math.PI);
					context.fill();
				}
			}
        }
        
        return canvas;
    }
	
    this.xOffset = function (reward) {
		return 200 * Math.round((reward+1)/2 * (rewSteps-1));
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