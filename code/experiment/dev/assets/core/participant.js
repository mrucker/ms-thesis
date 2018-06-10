function Participant(canvas)
{
    var id   = Id.generate();
    
    this.getId = function() { 
        return id; 
    };
    
    this.saveDemographics = function() {
        if(getDemographicsValidity()) {
            saveData(getDemographicsData());
            return true;
        }        
        return false;
    }
    
    function saveData(data) {
        $.ajax({
            "url"   :"https://api.thesis.markrucker.net/v1/participants/" + id,
            "method":"POST",
            "data"  : JSON.stringify(data)
        });
    }
    
    function getDemographicsForm() {
        return $('#modal form');
    }
    
    function getDemographicsValidity() {
        var $form    = getDemographicsForm();
        var validity = $form[0].checkValidity();
        
        $form.addClass('was-validated');
        
        return validity;
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