function Id() {
    
}

//17 bytes in storage size
Id.generate = function () {
    //r1 = Final value represents a number between 0 and 4.295 billion (we remove characters and convert to hex to save space)
    //r2 = Final value represents a number between 0 and 795.36 days worth of miliseconds (we remove characters and convert to hex to save space)
    var r1 = Math.floor(Math.random()*Math.pow(10,16)).toString(16).substring(0,8); 
    var r2 = Date.now().toString(16).substring(2);

    return r1 + r2;
}