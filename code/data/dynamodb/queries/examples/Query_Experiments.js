var AWS = require('aws-sdk')

AWS.config.region      = 'us-east-1' //for some reason it'll read the credentials from the shared file but not the region

var params = {
	 TableName                : 'ThesisExperiments'
	,ConsistentRead           : false
	,KeyConditionExpression   : 'ParticipantId = :participant_id'
	,ExpressionAttributeValues: {
		':participant_id': '1ec6d9e95672ca072',
	}
};

var documentClient = new AWS.DynamoDB.DocumentClient();

documentClient.query(params, function(err, data) {
   if (err) console.log(err);
   else     console.log(data);
});