function Counter(countFrom)
{
    var isCountdown = true;
    var startTime   = undefined;
    var stopTime    = undefined;
    var stopAfter   = undefined;
    
    this.startCounting = function() {
        startTime = Date.now();
        stopTime  = undefined;
    }
    
    this.stopCounting = function() {
        stopTime = Date.now();
    }
    
    this.resetCounting = function() {
        startTime = undefined;
        stopTime  = undefined;
    }
    
    this.stopAfter = function(milliseconds, callback){
        stopAfter    = milliseconds;
        stopCallback = callback;
    }
    
    this.draw = function(canvas){
                
        if( isAfter() ) {
            stopTime = startTime + stopAfter;
            myDraw(canvas);
            stopCallback();
        }
        
        if(stopTime == undefined) {
            myDraw(canvas);
        }
    };
    
    function myDraw(canvas){
        var context   = canvas.getContext2d();
        
        context.save();
        
        context.translate(canvas.getWidth()/2, canvas.getHeight()/2)        
        context.fillStyle    = 'rgb(100,100,100)';
        context.font         = '100px Arial';
        context.textAlign    = 'center';
        context.textBaseline = 'middle';
        context.fillText(countAsText(),0,0);
        
        context.restore();
    }
    
    function countAsText() {
        
        var milSinceStart = isCountdown ? stopAfter - runTime() : runTime();
        var cntSinceStart = milSinceStart/(stopAfter/countFrom);
                
        var cntModifier   = isCountdown ? Math.ceil  : Math.floor;        
        var cntPart       = cntModifier(cntSinceStart);        
        var cntPartAsText = padZeros(cntPart.toString(),2);
        
        return cntPart <= 0 ? "GO!" : cntPartAsText;
    }
    
    function isAfter() {
        return runTime() > stopAfter + 500;
    }
    
    function runTime() {
        return (stopTime || Date.now()) - startTime;
    }

    function padZeros(number, pad_size) {
        
        var pad_char = '0';
        var pad_full = new Array(1 + pad_size).join(pad_char);
        
        return (pad_full + number).slice(-pad_size);
    }
}