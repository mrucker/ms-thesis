function Timer(stopAfter, isCountdown)
{
    var startTime    = undefined;
    var stopTime     = undefined;
    var stopCallback = undefined;

    this.startTiming = function() {
        startTime = Date.now();
        stopTime  = undefined;
    }

    this.stopTiming = function() {
        stopTime = Date.now();
    }

    this.reset = function() {
        startTime = undefined;
        stopTime  = undefined;
    }

    this.onStop = function(callback) {
        stopCallback = callback;
    }

    this.draw = function(canvas){
        if( isAfter() ) {
            stopTime = startTime + stopAfter;
            myDraw(canvas);
            stopCallback();
        }
        else {
            myDraw(canvas);
        }
    };

    function myDraw(canvas){
        var context   = canvas.getContext2d();
        
        context.save();
        context.fillStyle    = 'rgb(100,100,100)';
        context.font         = '48px Arial';
        context.textBaseline = 'bottom';
        context.textAlign    = 'right';
        context.fillText(timeAsText(),canvas.getWidth(),canvas.getHeight());
        context.restore();
    }
    
    function timeAsText() {
        
        var milSinceStart = isCountdown ? stopAfter - runTime() : runTime();
        var secSinceStart = milSinceStart/1000;
        
        var minModifier = isCountdown ? Math.floor : Math.floor;
        var secModifier = isCountdown ? Math.ceil  : Math.floor;
        
        var minPart = minModifier(secSinceStart/60);
        var secPart = secModifier(secSinceStart%60);
        
        var minPartAsText = padZeros(minPart.toString(),2);
        var secPartAsText = padZeros(secPart.toString(),2);
        
        return minPartAsText + ":" + secPartAsText;
    }
    
    function isAfter() {
        return runTime() > stopAfter;
    }
    
    function runTime() {
        return (stopTime || Date.now()) - (startTime || Date.now());
    }

    function padZeros(number, pad_size) {
        
        var pad_char = '0';
        var pad_full = new Array(1 + pad_size).join(pad_char);
        
        return (pad_full + number).slice(-pad_size);
    }
}