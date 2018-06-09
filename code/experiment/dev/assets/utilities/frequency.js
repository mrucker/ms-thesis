function Frequency(name, shouldLog)
{
    var self       = this;
    var startTime  = undefined;
    var stopTime   = undefined;
    var cycleCount = 0;
    
    this.cycleCount = function () {
        return cycleCount;
    }
    
    this.runTime = function() {

        return !startTime ? 0 : ((stopTime || performance.now()) - startTime)/1000            
    }
    
    this.start = function() {
        startTime  = performance.now();
        stopTime   = undefined;
        cycleCount = 0;
    }
    
    this.stop = function() {
        stopTime = performance.now();
    }
    
    this.cycle = function() {
        if(startTime && !stopTime) {
            cycleCount++;
            
            if(shouldLog && cycleCount % 100 == 0) {
                console.log(name + ": " + self.getHz());
            }
        }
        
    }    
    
    this.correctedHz = function(newCycles, targetHz) {
        //we want to reach our targetHz in xCycles
        //this can be expressed as wanting to have the following (cycleCount + xCycles)/unknownTime = targetHz
        //by arithmetic operations we can solve for our unknown time unknownTime = (cycleCount + xCycles)/targetHz
        //given that our process has already ran for runTime = performance.now() - startTime 
        //we must run our xCycles in unknownTime - runTime or one cycle every xCycles/(unknownTime - runTime)
        
        var targetCycles            = cycleCount + newCycles;
        var timeToReachTargetCycles = targetCycles/targetHz;
        var currentTimeTimeRunning  = self.runTime();
        
        return newCycles/(timeToReachTargetCycles - currentTimeTimeRunning)
    }

    this.getHz = function() {
        
        if(self.runTime() == 0) throw "frequency measure was never started";
        
        return Math.round(cycleCount/self.runTime());
    }    
}