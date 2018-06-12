function Participant(canvas)
{
    var id     = Id.generate();
    var memory = {};
    
    this.getId = function() {
        return id; 
    };
    
    this.saveDemographics = function() {
        //we save in memory now because by the time the
        //recaptcha finishes the browser form will be erased
        saveMemory(getDemographicsData());
        grecaptcha.execute();
    }
    
    this.reCAPTCHA = function(token) {
        
        var demo = loadMemory();
        
        demo["token"] = token;
        
        saveData(demo);
    }
    
    function saveData(data) {
        $.ajax({
            "url"   :"https://api.thesis.markrucker.net/v1/participants/" + id,
            "method":"POST",
            "data"  : JSON.stringify(data)
        });
    }
    
    function saveMemory(data) {
        memory = data;
    }
    
    function loadMemory() {
        return memory;
    }
    
    function getDemographicsForm() {
        return $('#modal form');
    }
     
    function getDemographicsData() {
        var obj = {};

        getDemographicsForm().serializeArray().forEach(function(o) { obj[o.name] =  o.value; });

        obj.newcomer = obj.newcomer.startsWith("Yes") ? "Yes" : "No";        
        obj.system   = String(platform.os);
        obj.browser  = platform.name + " " + platform.version;
        
        return obj;
    }
}