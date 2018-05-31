function Counter(countFrom, countFor, isCountdown)
{
    var startTime    = undefined;
    var stopTime     = undefined;
    var stopAfter    = countFor;
    var timeout      = undefined;
    var prevDrawText = "";

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

    this.onStop = function(callback) {
        stopCallback = callback;
    }
    
    this.draw = function(canvas){

        if( !isAfter() ) {
            drawCount(canvas);
        }

        if(isAfter() && (runTime() - stopAfter) < 500) {
            drawGo(canvas);
        }
        
        if(isAfter() && (runTime() - stopAfter) > 500 && prevDrawText == "GO!") {
            eraseText(canvas, prevDrawText);
            prevDrawText = "";
        }
    };

    function drawGo(canvas) {
        drawText(canvas, "GO!");
    }

    function drawCount(canvas) {
        drawText(canvas, countAsText());
    }

    function eraseText(canvas, text) {
        var context   = canvas.getContext2d();
        var centerX   = Math.round(canvas.getWidth()/2,0);
        var centerY   = Math.round(canvas.getHeight()/2,0);
        
        context.font = '100px Arial';
        
        var w = context.measureText(text).width;
        var h = 100;
            
        context.clearRect(centerX-Math.ceil(w/2),centerY-Math.ceil(h/2), w, h);
    }
    
    function drawText(canvas, text) {
        var context   = canvas.getContext2d();
        var centerX   = Math.round(canvas.getWidth()/2,0);
        var centerY   = Math.round(canvas.getHeight()/2,0);
        
        context.font         = '100px Arial';
        context.textAlign    = 'center';
        context.textBaseline = 'middle';        
        context.fillStyle    = 'rgb(100,100,100)';
        context.fillText(text, centerX, centerY);
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