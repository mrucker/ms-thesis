var AWS = require('aws-sdk')

AWS.config.region      = 'us-east-1' //for some reason it'll read the credentials from the shared file but not the region

var params = {
  TableName                : 'ThesisParticipants',
  KeyConditionExpression   : 'Id = :id',
  ExpressionAttributeValues: {
    ':id': '22bf81593efa83ce8',
  }
};

var documentClient = new AWS.DynamoDB.DocumentClient();

documentClient.query(params, function(err, data) {
   if (err) console.log(err);
   else     console.log(data);
});