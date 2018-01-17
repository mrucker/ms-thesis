function Participant(canvas)
{
    //17 bytes per user id in dynamodb (dynamodb uses UTF-8 which encodes alll ASCII characters in 8 bits)    
    var id = readCookie() || generateId();
    
    writeCookie(id);
    writeDynamo(id);
    
    this.getId = function() { return id };
    
    function readCookie() {
        return document.cookie;
    }
    
    function writeCookie(val) {
        document.cookie = val;
    }
    
    function writeDynamo(id) {
        //here is where I'd write my the participantId to dynamodb
    }
    
    function generateId() {
        //r1 = Final value represents a number between 0 and 4.295 billion (we remove characters and convert to hex to save space)
        //r2 = Final value represents a number between 0 and 795.36 days worth of miliseconds (we remove characters and convert to hex to save space)
        var r1 = Math.floor(Math.random()*Math.pow(10,16)).toString(16).substring(0,8); 
        var r2 = Date.now().toString(16).substring(2);
    
        return r1 + r2;
    }
}