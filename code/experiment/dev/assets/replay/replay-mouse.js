function ReplayMouse(observations)
{
    var self = this;
    
	var rw_ps = [];
	var sm_vs = [];
	var sm_as = [];
	
	init_ps_vs_as();
	
	var o_i = 0;

    this.getX = function() {
		return rw_ps[o_i].x;
    };

    this.getY = function() {
        return rw_ps[o_i].y;
    };

	this.getVelocity = function(dim) {
		
		var velocity = sm_vs[o_i]
		
		if(dim == 0) return velocity.x;
		if(dim == 1) return velocity.y;
		if(dim == 2) return velocity.m;
		if(dim == 3) return velocity.d;
		
		return velocity.m;
	}
	
	this.getAcceleration = function(dim) {
		
		var acceleration = sm_as[o_i]
		
		if(dim == 0) return acceleration.x;
		if(dim == 1) return acceleration.y;
		if(dim == 2) return acceleration.m;
		if(dim == 3) return acceleration.d;
		
		return velocity.m;
	}

	this.getDirectionTo = function(x,y) {
		return Math.atan2(-(y-self.getY()), x - self.getX());
	}

	this.getDirectionToCenter = function() {
		return self.getDirectionTo(canvas.getResolution(0)/2, canvas.getResolution(1)/2)
	}
	
    this.draw = function(canvas) {

        var effectiveX = Math.round(self.getX(),0);
        var effectiveY = Math.round(self.getY(),0);

        var context = canvas.getContext2d();

        context.fillStyle = "rgb(200,0,0)";
        context.fillRect(effectiveX - 3, effectiveY - 3, 6, 6);
    };

	this.showObservation = function(i) {
		o_i = i;
	}

	function init_ps_vs_as() {

		rw_ps.push({x:observations[0][0], y:observations[0][1]          });
		sm_vs.push({x:0, y:0, m:0, d:0});
		sm_as.push({x:0, y:0, m:0, d:0});
		
		zero_count = 0;

		for(i = 1; i < 450; i++) {
			
			raw_p_at_i = {x:undefined, y:undefined                          };
			raw_v_at_i = {x:undefined, y:undefined, m:undefined, d:undefined};
			raw_a_at_i = {x:undefined, y:undefined, m:undefined, d:undefined};

			rw_p_at_i = {x:undefined, y:undefined                          };
			sm_v_at_i = {x:undefined, y:undefined, m:undefined, d:undefined};
			sm_a_at_i = {x:undefined, y:undefined, m:undefined, d:undefined};

			raw_p_at_i.x = observations[i][0];
			raw_p_at_i.y = observations[i][1];
						
			raw_v_at_i.x = raw_p_at_i.x - rw_ps[i-1].x;
			raw_v_at_i.y = raw_p_at_i.y - rw_ps[i-1].y;
			raw_v_at_i.m = Math.sqrt(Math.pow(raw_v_at_i.x,2) + Math.pow(raw_v_at_i.y,2));
			raw_v_at_i.d = Math.atan2(-raw_v_at_i.y,raw_v_at_i.x);

			raw_a_at_i.x = raw_v_at_i.x - sm_vs[i-1].x;
			raw_a_at_i.y = raw_v_at_i.y - sm_vs[i-1].y;
			raw_a_at_i.m = Math.sqrt(Math.pow(raw_a_at_i.x,2) + Math.pow(raw_a_at_i.y,2));

			rw_p_at_i.x = raw_p_at_i.x;
			rw_p_at_i.y = raw_p_at_i.y;

			if(raw_v_at_i.m != 0) {				
				zero_count = 0;
				
				sm_v_at_i.x = 2/6 * sm_vs[i-1].x + 4/6 * raw_v_at_i.x;
				sm_v_at_i.y = 2/6 * sm_vs[i-1].y + 4/6 * raw_v_at_i.y;
				sm_v_at_i.m = 2/6 * sm_vs[i-1].m + 4/6 * raw_v_at_i.m;
				sm_v_at_i.d = 2/6 * sm_vs[i-1].d + 4/6 * raw_v_at_i.d;

				sm_a_at_i.x = 2/6 * sm_as[i-1].x + 4/6 * raw_a_at_i.x;
				sm_a_at_i.y = 2/6 * sm_as[i-1].y + 4/6 * raw_a_at_i.y;
				sm_a_at_i.m = 2/6 * sm_as[i-1].m + 4/6 * raw_a_at_i.m;
				
			}
			else {
				zero_count++;

				sm_v_at_i = sm_vs[i-1];
				sm_a_at_i = sm_as[i-1]

				if(zero_count > 10) {
					sm_v_at_i.x *= Math.pow(12/13,3);
					sm_v_at_i.y *= Math.pow(12/13,3);
					sm_v_at_i.m *= Math.pow(12/13,3);

					sm_a_at_i.x *= Math.pow(12/13,3);
					sm_a_at_i.y *= Math.pow(12/13,3);
					sm_a_at_i.m *= Math.pow(12/13,3);
				}
			}

			rw_ps.push(rw_p_at_i);
			sm_vs.push(sm_v_at_i);
			sm_as.push(sm_a_at_i);
		}
	}
}