function Experiment(participant)
{
    var id = 0;
    
    this.beginExperiment = function() {        
        //create an experiment in dynamoDB passing along participant.getId();
        //set the id value to the dynamoDB.Id;
        //begin passive background observing
    }
    
    function makeObservation() {
        
    };
    
    function saveObservation() {
        
    };
    
    this.endExperiment = function () {
        //get the completion code from dynamodb
        //use lambda functions to double check runtime.
    }
}