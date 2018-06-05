function Timer(timeFor, isCountdown)
{
    var startTime    = undefined;
    var stopTime     = undefined;
    
    var elapseAfter    = timeFor;
    var elapseCallback = undefined;
    var elapseTimeout  = undefined;

    this.startTiming = function() {
        startTime = Date.now() - runTime();
        stopTime  = undefined;
        
        if(elapsedBy() < 0) {
            //we add 30 to make sure the last draw is made before stopping
            elapseTimeout = setTimeout(elapseCallback, -elapsedBy()+30);
        }
    }

    this.stopTiming = function() {
        stopTime = Date.now();
        
        if(elapseTimeout) {
            clearTimeout(elapseTimeout);
        }
    }

    this.reset = function() {
        startTime = undefined;
        stopTime  = undefined;
    }

    this.onElapsed = function(callback) {
        elapseCallback = callback;
    }

    this.draw = function(canvas){
        
        if( elapsedBy() > 0 ) {
            drawText(canvas, "00:00");
        }
        else {
            drawText(canvas, timeAsText());
        }
    };
    
    function drawText(canvas, text) {
        var context   = canvas.getContext2d();

        context.font         = '48px Arial';
        context.textBaseline = 'bottom';
        context.textAlign    = 'right';
        
        context.fillStyle = 'rgb(100,100,100)';
        context.fillText(text,canvas.getWidth(),canvas.getHeight());
    }
    
    function timeAsText() {
        
        var milSinceStart = isCountdown ? elapseAfter - runTime() : runTime();
        var secSinceStart = milSinceStart/1000;
        
        var minModifier = isCountdown ? Math.floor : Math.floor;
        var secModifier = isCountdown ? Math.ceil  : Math.floor;
        
        var minPart = minModifier(secSinceStart/60);
        var secPart = secModifier(secSinceStart%60);
        
        var minPartAsText = padZeros(minPart.toString(),2);
        var secPartAsText = padZeros(secPart.toString(),2);
        
        return minPartAsText + ":" + secPartAsText;
    }
    
    function elapsedBy() {
        return runTime() - elapseAfter;
    }

    function runTime() {
        return (!startTime) ? 0 : (stopTime || Date.now()) - startTime;
    }

    function padZeros(number, pad_size) {
        
        var pad_char = '0';
        var pad_full = new Array(1 + pad_size).join(pad_char);
        
        return (pad_full + number).slice(-pad_size);
    }
}