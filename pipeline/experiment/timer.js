function Timer(canvas)
{
    var r = 50;
    var g = 50;
    var b = 50;
    var startTime = undefined;
    var stopTime  = undefined;
    var context   = canvas.getContext2d();
    var stopAfter = undefined;
    var stopEvent = undefined;

    this.resetTiming = function() {
        startTime = undefined;
        stopTime  = undefined;
        stopAfter = undefined;
    }
    
    this.startTiming = function() {
        startTime = Date.now();
        stopTime  = undefined;
    }
    
    this.stopTiming = function() {
        stopTime = Date.now();
    }
    
    this.stopAfter = function(milliseconds, callback){
        stopAfter = milliseconds;
        onStop    = callback;
    }
    
    this.draw = function(){
        context.save();
        context.fillStyle = 'rgb('+r+','+g+','+b+')';
        context.font      = '48px Arial';
        context.fillText(timeAsText(),0,canvas.getHeight());
        context.restore();
        
        if( isAfter() ) {
            stopTime = startTime + stopAfter;
            onStop();
        }
    };
    
    function timeAsText() {
        var milSinceStart = runTime();
        var minSinceStart = Math.floor(milSinceStart/(1000*60)).toString();
        var secSinceStart = Math.floor((milSinceStart/1000)%60).toString();
        
        return padZeros(minSinceStart,2) + ":" + padZeros(secSinceStart,2);
    }
    
    function isAfter() {        
        return runTime() > stopAfter;
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