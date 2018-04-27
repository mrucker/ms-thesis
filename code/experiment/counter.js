function Counter(countFrom, isCountdown)
{
    var startTime = undefined;
    var stopTime  = undefined;
    var stopAfter = undefined;
    var timeout   = undefined;

    this.startCounting = function() {
        startTime = Date.now();
        stopTime  = undefined;

        timeout = setTimeout(stopCallback, stopAfter);
    }

    this.stopCounting = function() {
        stopTime = Date.now();
        clearTimeout(timeout);
    }

    this.reset = function() {
        startTime = undefined;
        stopTime  = undefined;
    }

    this.stopAfter = function(milliseconds, callback){
        stopAfter    = milliseconds;
        stopCallback = callback;
    }
    
    this.draw = function(canvas){

        if( !isAfter() ) {
            drawCount(canvas);
        }

        if(isAfter() && (runTime() - stopAfter) < 500) {
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
        
        context.save();        
        
        context.translate(canvas.getWidth()/2, canvas.getHeight()/2)        
        context.fillStyle    = 'rgb(100,100,100)';
        context.font         = '100px Arial';
        context.textAlign    = 'center';
        context.textBaseline = 'middle';
        context.fillText(text,0,0);
        
        context.restore();
    }

    function countAsText() {
        
        var milSinceStart = isCountdown ? stopAfter - runTime() : runTime();
        var cntSinceStart = milSinceStart/(stopAfter/countFrom);
                
        var cntModifier   = isCountdown ? Math.ceil  : Math.floor;        
        var cntPart       = cntModifier(cntSinceStart);        
        var cntPartAsText = padZeros(cntPart.toString(),2);
        
        return cntPartAsText;
    }

    function isAfter() {
        return runTime() > stopAfter;
    }

    function runTime() {
        var now = Date.now();
        
        if(!startTime) return 0;
        
        return (!startTime) ? 0 : (stopTime || Date.now()) - startTime;
    }

    function padZeros(number, pad_size) {
        
        var pad_char = '0';
        var pad_full = new Array(1 + pad_size).join(pad_char);
        
        return (pad_full + number).slice(-pad_size);
    }
}