function Experiment(participant)
{
    var id = generateId();        
    var that = this;
        
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "https://api.thesis.markrucker.net/v1/participants/" + participant.getId() + "/experiments", true);
    xhttp.send(id);
    
    this.beginExperiment = function() {
        
        var xhttp = new XMLHttpRequest();
        xhttp.open("PATCH", "https://api.thesis.markrucker.net/v1/participants/" + participant.getId() + "/experiments/" + id, true);
        xhttp.send('{"startTime":"' + new Date().toUTCString() +'"}');
    }    
    
    this.endExperiment = function () {
        
        var xhttp = new XMLHttpRequest();
        xhttp.open("PATCH", "https://api.thesis.markrucker.net/v1/participants/" + participant.getId() + "/experiments/" + id, true);
        xhttp.send('{"stopTime":"' + new Date().toUTCString() +'"}');
    }
    
    function makeObservation() {
        
    };
    
    function saveObservation() {
        
    };
    
    //17 bytes in storage size
    function generateId() {
        //r1 = Final value represents a number between 0 and 4.295 billion (we remove characters and convert to hex to save space)
        //r2 = Final value represents a number between 0 and 795.36 days worth of miliseconds (we remove characters and convert to hex to save space)
        var r1 = Math.floor(Math.random()*Math.pow(10,16)).toString(16).substring(0,8); 
        var r2 = Date.now().toString(16).substring(2);

        return r1 + r2;
    }
}