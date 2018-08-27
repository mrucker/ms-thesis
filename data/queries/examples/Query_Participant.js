var AWS = require('aws-sdk')

AWS.config.region      = 'us-east-1' //for some reason it'll read the credentials from the shared file but not the region

var params = {
	 TableName                : 'ThesisParticipants'
	,KeyConditionExpression   : 'Id = :id'
	,ExpressionAttributeValues: {
		':id': '1ec6d9e95672ca072',
	}
	//,ProjectionExpression      : 'Id'
	//,FilterExpression          : 'InsertTimeStamp >= :time_stamp'
	//,ExpressionAttributeValues : {':time_stamp' : '2018-08-23T15:20:01.602Z'}

};

var documentClient = new AWS.DynamoDB.DocumentClient();

documentClient.query(params, function(err, data) {
   if (err) console.log(err);
   else     console.log(data);
});