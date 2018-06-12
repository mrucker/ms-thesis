function Counter(countFrom, countFor, isCountdown)
{
    var startTime    = undefined;
    var stopTime     = undefined;
    
    var elapseAfter    = countFor;
    var elapseCallback = undefined;
    var elapseTimeout  = undefined;

    this.startCounting = function() {
        startTime = Date.now() - runTime();
        stopTime  = undefined;
        
        if(elapsedBy() < 0) {
            //we add 30 to make sure the last draw is made before stopping
            elapseTimeout = setTimeout(function() { if (elapseCallback) elapseCallback(); }, -elapsedBy()+10);
        }
    }

    this.stopCounting = function() {
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

        if(elapsedBy() < 0) {
            drawCount(canvas);
        }
        
        if(0 < elapsedBy() && elapsedBy() < 500) {
            drawGo(canvas);
        }
    };

    function drawGo(canvas) {
        drawText(canvas, "GO!");
    }

    function drawCount(canvas) {
        drawText(canvas, countAsText());
    }
    
    function drawText(canvas, text) {
        var context   = canvas.getContext2d();
        var centerX   = Math.round(canvas.getResolution(0)/2,0);
        var centerY   = Math.round(canvas.getResolution(1)/2,0);
        
        context.font         = '100px Arial';
        context.textAlign    = 'center';
        context.textBaseline = 'middle';        
        context.fillStyle    = 'rgb(100,100,100)';
        context.fillText(text, centerX, centerY);
    }
   
    function countAsText() {
        
        var milSinceStart = isCountdown ? elapseAfter - runTime() : runTime();
        var cntSinceStart = milSinceStart/(elapseAfter/countFrom);
                
        var cntModifier   = isCountdown ? Math.ceil  : Math.floor;        
        var cntPart       = cntModifier(cntSinceStart);        
        var cntPartAsText = padZeros(cntPart.toString(),2);
        
        return cntPartAsText;
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