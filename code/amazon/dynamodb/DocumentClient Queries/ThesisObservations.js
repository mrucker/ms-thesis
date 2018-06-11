var AWS = require('aws-sdk')

AWS.config.region      = 'us-east-1' //for some reason it'll read the credentials from the shared file but not the region

var params = {
  TableName                : 'ThesisObservations'
 ,KeyConditionExpression   : 'ExperimentId = :id'
 ,ConsistentRead           : false
 ,ExpressionAttributeValues: {
    ':id': 'c3fa355b3efa8e580'
  }
};

var documentClient = new AWS.DynamoDB.DocumentClient();

documentClient.query(params, function(err, data) {
   if (err) console.log(err);
   else     console.log(data.Items.map(d => JSON.stringify(d.Observations)));
});