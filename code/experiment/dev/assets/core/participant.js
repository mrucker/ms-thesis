function Participant(canvas)
{
    var id         = Id.generate();
    var putRequest = undefined;

    this.getId = function() { return id; };
    
    this.saveData = function(data) {
        $.ajax({
            "url   ":"https://api.thesis.markrucker.net/v1/participants/" + id,
            "method":"POST",
            "data"  : JSON.stringify(data)
        });
    }
}