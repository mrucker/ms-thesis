function Participant(canvas)
{
    var id         = Id.generate();
    var putRequest = undefined;

    this.getId = function() { return id; };
    
    this.saveData = function(data) {
        if(!putRequest) {
            putRequest = $.ajax({
                "url   ":"https://api.thesis.markrucker.net/v1/participants/" + id,
                "method":"PUT",
                "data"  : data
            });
        }
        else {
            putRequest.done(function(){
                $.ajax({
                    "url"   :"https://api.thesis.markrucker.net/v1/participants/" + id,
                    "method":"PATCH",
                    "data"  :JSON.stringify(data)
                });
            });
        }
    }
}