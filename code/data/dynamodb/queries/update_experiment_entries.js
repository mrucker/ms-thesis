var AWS = require('aws-sdk')
var fs  = require('fs');

AWS.config.region = 'us-east-1'

//note, filtering and projecting doesn't reduce the RCU units used. These are calculated based on what was scanned not what was returned.
var params = {
   TableName                 : 'ThesisExperiments'
  ,ConsistentRead            : false
  ,FilterExpression          : 'InsertTimeStamp >= :time_stamp'
  ,ExpressionAttributeValues : {':time_stamp' : '2018-08-23T15:20:01.602Z'}
};

var documentClient = new AWS.DynamoDB.DocumentClient();

documentClient.scan(params, function(err, data) {
	if (err) {
		console.log(err);
	}
	else {
		data.Items.forEach(function(item) {
			
			var filePath = 'entries/experiments/'+item.Id+'.json';
			var fileData = JSON.stringify(item);
			var fileFlag = {flag: 'wx+'};
			var errAsync = (err) => { 													
				if (err && err.code == 'EEXIST') console.log('experiment ' + item.Id + ' already written');
				if (err && err.code != 'EEXIST') console.log(err); 
				if (!err                       ) console.log('experiment ' + item.Id + ' freshly written');
			};
			
			//https://nodejs.org/api/fs.html#fs_file_system_flags
			//https://nodejs.org/api/fs.html#fs_fs_writefile_file_data_options_callback
			fs.writeFile(filePath, fileData, fileFlag, errAsync);
		});
	}
});