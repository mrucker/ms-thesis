var AWS = require('aws-sdk');
var fs  = require('fs');

AWS.config.region = 'us-east-1'

if(!process.argv[2] || !process.argv[3]) {
	console.log('please enter a path to write to and a date time to update from');
	return;
}

if(isNaN(Date.parse(process.argv[3]))) {
	console.log('please enter a valid date time to update from')
	return;
}

var dataPath = process.argv[2];
var dateFrom = new Date(process.argv[3]);

DownloadAllFilesToPathAfterDate();

function DownloadAllFilesToPathAfterDate() {

          QueryParticipants(dateFrom.toISOString())
 	.then(WriteParticipants)
	.then(QueryExperiments )
	.then(WriteExperiments )
	.then(QueryObservations)
	.then(WriteObservations)
	.then(() => console.log("All Done"));
}

function QueryParticipants(lastUpdateTime) {
	var params = {
		 TableName                : 'ThesisParticipants'
		,ConsistentRead           : false
		,KeyConditionExpression   : 'StudyId = :study_id and InsertTimeStamp > :last_update_time'
		,ExpressionAttributeValues: {':study_id' : '1', ':last_update_time' : lastUpdateTime }
	};

	return QueryDynamoPromise(params).catch(err => {console.log(err)});	
}

function WriteParticipants(participants) {
	return WriteFilesPromise(participants, participant => participant.Id, "participants");
}

function QueryExperiments(participantIds) {
	var params = {
		 TableName                 : 'ThesisExperiments'
		,ConsistentRead            : false
		,KeyConditionExpression    : 'ParticipantId = :participant_id'		
	};
	
	var queryDataPromises = participantIds.filter(id => id != -1).map(participantId => {
		
		params.ExpressionAttributeValues = {':participant_id' : participantId };
		
		return QueryDynamoPromise(params);
	});
	
	return Promise.all(queryDataPromises);
}

function WriteExperiments(experiments) {
	//flatten the experiments to a single array
	experiments = [].concat.apply([], experiments);
	
	return WriteFilesPromise(experiments, experiment => experiment.Id, "experiments");
}

function QueryObservations(experimentIds) {
	var params = {
		 TableName                 : 'ThesisObservations'
		,ConsistentRead            : false
		,KeyConditionExpression    : 'ExperimentId = :experiment_id'		
	};
	
	var queryDataPromises = experimentIds.filter(id => id != -1).map(experimentId => {
		
		params.ExpressionAttributeValues = {':experiment_id' : experimentId };
		
		return QueryDynamoPromise(params);
	});

	return Promise.all(queryDataPromises);
}

function WriteObservations(observations) {

	var writeObservationPromises = observations.map(exp_obs => {
		
		var experimentId = exp_obs[1].ExperimentId;
		var sorted       = exp_obs.sort((i1,i2) => i1.SequenceNumber - i2.SequenceNumber).map(i => i.Observations);
		var flattened    = [].concat.apply([], sorted);

		return WriteFilesPromise([flattened], observations => experimentId, "observations");
	});

	return Promise.all(writeObservationPromises);
}

function QueryDynamoPromise(params) {
	return new Promise((res, rej) => {
		new AWS.DynamoDB.DocumentClient().query(params, function(err, data) {
			if(err) { 
				rej(err);
			}
			else {
				res(data.Items);
			}
		});
	});
}

function WriteFilesPromise(items, getId, folder) {
	var writeFilePromises = items.map(function(item) {
		return new Promise((res, rej) => {
			var itemId = getId(item);

			var filePath = dataPath + folder + '/' + itemId + '.json';
			var fileData = JSON.stringify(item);
			var fileFlag = {flag: 'wx+'};
			
			var callback = (err) => {
				if (err && err.code != 'EEXIST') {
					console.log(err);
					res(-1);
				}
				if(err && err.code == 'EEXIST') {
					console.log(folder + ' ' + itemId + ' already written');
					res(-1);
				} else { 
					console.log(folder + ' ' + itemId + ' freshly written')
					res(itemId); 
				}
			};

			//https://nodejs.org/api/fs.html#fs_file_system_flags
			//https://nodejs.org/api/fs.html#fs_fs_writefile_file_data_options_callback
			fs.writeFile(filePath, fileData, fileFlag, callback);
		});
	});
		
	return Promise.all(writeFilePromises);
}