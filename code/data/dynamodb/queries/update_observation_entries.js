var AWS = require('aws-sdk')
var fs  = require('fs');

AWS.config.region = 'us-east-1' //for some reason it'll read the credentials from the shared file but not the region

var documentClient = new AWS.DynamoDB.DocumentClient();

fs.readdir('entries/experiments/', (err, fileNames) => {
	if(err) {
		console.log(err);
	}
	else {
		fileNames.forEach(function(fileName) => {
			var experimentId = fileName.substring(0,str.lastIndexOf(".json"));
			
			var filePath = 'entries/observations/' + experimentId + '.json';
			var fileFlag = 'wx+';
			var errHandl = (err) => { 													
				if (err && err.code == 'EEXIST') console.log('observations ' + experimentId + ' already written');
				if (err && err.code != 'EEXIST') console.log(err); 
				if (!err                       ) console.log('observations ' + experimentId + ' freshly written');
			};

			fs.open(filePath, fileFlag, (err, fd) => {
				errHandl(err);
				
				if(!err) {
					
					//There was no error which means the file doesnt already exist. In this case I should read my observation data and write it.
					var params = {
					   TableName                 : 'ThesisObservations'
					  ,ConsistentRead            : true
					  ,FilterExpression          : 'ExperimentId = :experiment_id'
					  ,ExpressionAttributeValues : {':experiment_id' : experimentId}
					};
					
					documentClient.scan(params, function(err, data) {
						if(err) {
							console.log(err);
						}
						else {
							var sortedObservations    = data.Items.sort((i1,i2) => i1.SequenceNumber - i2.SequenceNumber).map(i => i.Observations);
							var flattenedObservations = [].concat.apply([], sortedObservations);
							
							fs.write(fd, JSON.stringify(flattenedObservations), (err) => { if(err) console.log(err) });
						}
					}
				}
			});
		});
	}
});