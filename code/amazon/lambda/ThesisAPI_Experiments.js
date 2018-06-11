'use strict';

const isHuman  = {};
const aws_sdk  = require('aws-sdk'); 
const dynamodb = new aws_sdk.DynamoDB();

//we explicitly set the content-type because JQuery complains if we send
//an empty body with the default content-type of "application/json"
const head = { 
    "Access-Control-Allow-Origin" : "https://thesis.markrucker.net",
    "Content-Type"                : ""
};
    
exports.handler = (event, context, callback) => {

    if(event.httpMethod != "POST" &&  event.httpMethod != "PATCH") 
    {
        callback(null, {statusCode: 405, body:"", headers: head });
        
        return;
    }
    
    if(!getIsHuman(event.pathParameters.participantId)) {
    
        callback(null, {statusCode: 401, body:"", headers: head });
        
        return;
    }
    
    if (event.httpMethod == "POST" && event.pathParameters.participantId && event.pathParameters.experimentId)
    {
        post(event, callback);
        
        return;
    }
    
    if (event.httpMethod == "PATCH" && event.pathParameters.participantId && event.pathParameters.experimentId)
    {
        patch(event, callback);
        
        return;
    }

    callback(null, {statusCode: 500, body:JSON.stringify(event), headers: head });
};

function post(event, callback) {
    
    event.body = JSON.parse(event.body);
    
    var item = {
        "Id"             : {"S": event.pathParameters.experimentId },
        "ParticipantId"  : {"S": event.pathParameters.participantId },
        "InsertTimeStamp": {"S": new Date().toUTCString() },
    };
    
    if(event.body.startTime) {
        item["StartTime"] = {"S": event.body.startTime };
    }
    
    if(event.body.dimensions) {
        item["Dimensions"] = {"L": event.body.dimensions.map(o => ({"N": String(o)})) };
    }
    
    if(event.body.resolution) {
        item["Resolution"] = {"L": event.body.resolution.map(o => ({"N": String(o)})) };
    }
    
    let params = 
    {
        Item               : item
      , TableName          : "ThesisExperiments"
      , ConditionExpression: "attribute_not_exists(Id)"
    };

    dynamodbClient().putItem(params, function(err,data) { 
        if(err) callback(null, { statusCode: 500, body: "", headers: head });
           else callback(null, { statusCode: 201, body: "", headers: head });
    });
}

function patch(event, callback) {
    
    var updateExpressions = [];
    var updateAttributes  = {};

    event.body = JSON.parse(event.body);

    if(event.body.stopTime) {
        updateAttributes[":stopTime"] = {"S" : event.body.stopTime};
        updateExpressions.push("StopTime =if_not_exists(StopTime, :stopTime)");
    }
    
    if(event.body.fps) {
        updateAttributes[":fps"] = {"S" : String(event.body.fps) };
        updateExpressions.push("FPS =if_not_exists(FPS, :fps)");
    }
    
    if(event.body.ops) {
        updateAttributes[":ops"] = {"S" : String(event.body.ops) };
        updateExpressions.push("OPS =if_not_exists(OPS, :ops)");
    }
    
    if(event.body.errors && event.body.errors.length > 0) {
        updateAttributes[":errors"] = {"SS" : event.body.errors};
        updateExpressions.push("Errors =if_not_exists(Errors, :errors)");
    }
    
    let params   = {
        Key: {
            "Id"           : {"S": event.pathParameters.experimentId },
            "ParticipantId": {"S": event.pathParameters.participantId }
        },
        ExpressionAttributeValues: updateAttributes,
        UpdateExpression         : "SET " + updateExpressions.join(','),
        ConditionExpression      : "attribute_exists(Id)",
        TableName                : "ThesisExperiments"
    };

    dynamodbClient().updateItem(params, function(err,data) {
        if(err) callback(null, { statusCode: 500, body: "", headers: head });
           else callback(null, { statusCode: 200, body: "", headers: head });
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