var AWS = require('aws-sdk')
var fs  = require('fs')

AWS.config.region      = 'us-east-1' //for some reason it'll read the credentials from the shared file but not the region

var params = {
	 TableName                : 'ThesisObservations'
	,ConsistentRead           : false
	,KeyConditionExpression   : 'ExperimentId = :experiment_id'
	,ExpressionAttributeValues: {
		':experiment_id': '5d11f6b55675eb8bd'
	}
};

var documentClient = new AWS.DynamoDB.DocumentClient();

documentClient.query(params, function(err, data) {
   if (err) {
       console.log(err);
   } 
   else {
        var sortedObservations    = data.Items.sort((i1,i2) => i1.SequenceNumber - i2.SequenceNumber).map(i => i.Observations);
        var flattenedObservations = [].concat.apply([], sortedObservations);

        console.log(JSON.stringify(flattenedObservations));
        //console.log(JSON.stringify(toActions(flattenedObservations)));
   }
});

 function toStates(observations) {
    var states = observations.slice(3).map(function(observation, i) {

        var mp_0 = observations[3+i-0].slice(0,2); //gives us [x,y];
        var mp_1 = observations[3+i-1].slice(0,2); //gives us [x,y];
        var mp_2 = observations[3+i-2].slice(0,2); //gives us [x,y];
        var mp_3 = observations[3+i-3].slice(0,2); //gives us [x,y];

        return mp_0.concat(mp_1).concat(mp_2).concat(mp_3).concat(observation.slice(2));
    });
    
    return states;
}

function toActions(observations) {
    var actions = observations.slice(3).map(function(obs, i) {

        var thisState_x = observations[3+i-0][0];
        var thisState_y = observations[3+i-0][1];
        var prevState_x = observations[3+i-1][0];
        var prevState_y = observations[3+i-1][1];

        return i == 0 ? [0,0] : [ thisState_x - prevState_x, thisState_y - prevState_y ];
    });
    
    return actions;
}