$(document).ready( function () {

	var canvas = new Canvas(document.querySelector('#c'));
	
	canvas.resize($(window).width() - 10, $(window).height() - 10);
	
	$(window).on('resize', function() {
		canvas.resize($(window).width() - 10, $(window).height() - 10);
	});

	var mouse  = new Mouse(canvas);
	var targets = [];
	
	var xs = 10;
	var ys = 3;
		
	for(x = 1; x <= xs; x++) {
		for(y = 1; y <= ys; y++) {
			targets.push(new Target(mouse, x/(xs+1), y/(ys+1), 100, 100))
		}
	}
	
	mouse .startTracking();
	canvas.startAnimating();
	
	canvas.draw = function() {
		targets.forEach(function(target) {target.draw(canvas)});
		mouse.draw(canvas);
	};
	
	
});