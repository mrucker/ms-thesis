'use strict';

const isHuman = {};

const aws_sdk  = require('aws-sdk'); 
const dynamodb = new aws_sdk.DynamoDB();

//we explicitly set the content-type because JQuery complains if we send
//an empty body with the default content-type of "application/json"
const head = { 
    "Access-Control-Allow-Origin" : "https://thesis.markrucker.net",
    "Content-Type"                : ""
};
    
exports.handler = (event, context, callback) => {

    if(event.httpMethod != "POST") 
    {
        callback(null, {statusCode: 405, body:"", headers: head });
    }
    
    if(!getIsHuman(event.pathParameters.participantId)) {
    
        callback(null, {statusCode: 401, body:"", headers: head });
        
        return;
    }
    
    if (event.httpMethod == "POST" && event.pathParameters.experimentId)
    {
        post(event, callback);
        
        return;
    }

    callback(null, {statusCode: 500, body:"", headers: head });
};

function post(event, callback) {
    
    event.body = JSON.parse(event.body);
    
    var item = {
        "ExperimentId"   : {"S": event.pathParameters.experimentId }
      , "SequenceNumber" : {"S": String(event.body[0]) }
      , "Observations"   : {"L": event.body[1].map(o => ({"L": o.map(d => ({"N":String(d)}) ) }))}
    };

    let params = 
    {
        Item               : item
      , TableName          : "ThesisObservations"
      , ConditionExpression: "attribute_not_exists(ExperimentId) and attribute_not_exists(SequenceNumber)"
    };

    dynamodbClient().putItem(params, function(err,data) { 
        if(err) callback(null, { statusCode: 500, body: "", headers: head });
           else callback(null, { statusCode: 201, body: "", headers: head });
    });
}

function getIsHuman(participantId) {
    if(isHuman[participantId] === undefined) {
        isHuman[participantId] = true; //here is where I'd look it up
    }
    
    return isHuman[participantId];
}

function dynamodbClient() {
    return dynamodb;
}