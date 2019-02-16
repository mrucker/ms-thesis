var _renderer = new TargetRenderer ();

function TargetRenderer() {
	
	var self = this;

	var areaPctSqrt = 1;
	var baseRadius  = 100;
	
	var lifespan = 1000;
	
	var fadeInTime  = 0.0 * lifespan;
	var fadeOffTime = 0.5 * lifespan;
	var fadeOutTime = 0.5 * lifespan;

	//3 megapixel maximum on iOS (e.g., 1000 * 3000)
	//aka, (rewSteps*ageSteps*width*height)/1000000 must be < 3 on iOS;
	
	var rewSteps = 20;
	var ageSteps = 10;

	var width         = 2 * baseRadius * areaPctSqrt;
	var height        = 2 * baseRadius * areaPctSqrt;
	var target_radius = 1 * baseRadius * areaPctSqrt;

	var n_touch_render = undefined;
	var y_touch_render = undefined;

	this.setBaseRadius = function(new_baseRadius) {
		baseRadius = new_baseRadius;
		
		rerender();
	}
	
	this.setAreaPctSqrt = function(new_areaPctSqrt) {
		areaPctSqrt = Math.round(new_areaPctSqrt * 100) / 100;

		rerender();
	}
	
	this.getWidth  = function() {
		return width; 
	}
	
	this.getHeight = function() { 
		return height; 
	}

	this.getAreaPctSqrt = function() {
		return areaPctSqrt;
	}
	
	this.getEffectiveRadius = function() {
		return baseRadius * areaPctSqrt;
	}
	
	this.get_n_touch_render = function() {
		if(!n_touch_render) {
			n_touch_render = render(allGray150, allGray90, evenFill, mediumStroke, evenOpacity);
		}

		return n_touch_render;
	}
	
	this.get_y_touch_render = function() {
		if(!y_touch_render) {
			y_touch_render = render(allGray90 , allBlack , evenFill, heavyStroke , evenOpacity);
		}

		return y_touch_render;
	}
	
	this.xOffset = function (reward, min, max) {
		return width * Math.round((reward-min)/(max-min) * (rewSteps-1));
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
		
        return height * Math.round(o_value * (ageSteps-1));
    }
	
	function rerender() {
		width         = 2 * baseRadius * areaPctSqrt;
		height        = 2 * baseRadius * areaPctSqrt;
		target_radius = 1 * baseRadius * areaPctSqrt;

		n_touch_render = undefined;
		y_touch_render = undefined;
	}
	
    function evenOpacity(ageStep) {
		return ageStep / ageSteps;
    }

    function gradientRGB (rewStep) {

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

	function allBlack(rewStep) {
		return "0,0,0";
	}

	function allGray90(rewStep) {
		return "50,50,50";
	}

	function allGray150(rewStep) {
		return "150,150,150";
	}

	function mediumStroke(rewStep) {
		return 6;
	}

	function heavyStroke(rewStep) {
		return 12;
	}

	function evenFill(rewStep) {
		return rewStep/rewSteps * target_radius;
	}

	function render(fill_color, line_color, fill_radius, stroke_width, opacity) {

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
}