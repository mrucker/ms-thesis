$(document).ready( function () {	

	var observations = JSON.parse(prompt("Enter session data"));
	var rewardId     = prompt("Enter reward id", "1");
	var frameRate    = parseInt(prompt("Enter frameRate", "30"));
	
    var canvas   = initializeCanvas();
	var experiment = new ReplayExperiment(canvas, observations, rewardId, frameRate);
		
	experiment.run();
	
	
	function initializeCanvas() {
        var canvas  = new Canvas(document.querySelector('#c'));
        
        canvas.resize($(window).width() - 10, $(window).height() - 10);
        
        $(window).on('resize', function() {
            canvas.resize($(window).width() - 10, $(window).height() - 10);
        });
		
		return canvas;
    }
 });
 