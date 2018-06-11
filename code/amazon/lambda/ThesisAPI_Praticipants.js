'use strict';

const https    = require('https');
const AWS      = require('aws-sdk');
const dynamodb = new AWS.DynamoDB();

//we explicitly set the content-type because JQuery complains if we send
//an empty body with the default content-type of "application/json"
const head = {
    "Access-Control-Allow-Origin" : "https://thesis.markrucker.net",
    "Content-Type"                : ""
};

exports.handler = (event, context, callback) => {
    
    if(event.httpMethod != "POST") 
    {
        callback(null, {statusCode: 405, body: event.httpMethod || "null", headers: head });
        
        return;
    }
    
    if (event.httpMethod == "POST" && event.pathParameters.participantId)
    {
        post(event, callback);
        
        return;
    }
        
    callback(null, {statusCode: 500, body:"", headers: head });
};

function post(event, callback) {
    
    event.body = JSON.parse(event.body);
    
    var item = {
        "Id"             : {"S": event.pathParameters.participantId },
        "InsertTimeStamp": {"S": new Date().toUTCString() }
    };
    
    if(event.body.age) {
        item["Age"] = {"S" : event.body.age.substring(0,100).toLowerCase() };
    }
    
    if(event.body.gender) { 
        item["Gender"] = {"S" : event.body.gender.substring(0,100).toLowerCase() };
    }
    
    if(event.body.machine) {
        item["Machine"] = {"S" : event.body.machine.substring(0,100).toLowerCase() };
    }
    
    if(event.body.device) {
        item["Device"] = {"S" : event.body.device.substring(0,100).toLowerCase() };
    }
    
    if(event.body.browser) {
        item["Browser"] = {"S" : event.body.browser.substring(0,100).toLowerCase() };
    }
    
    if(event.body.system) {
        item["System"] = {"S" : event.body.system.substring(0,100).toLowerCase() };
    }
    
    if(event.body.newcomer) {
        item["First"] = {"S" : event.body.newcomer.substring(0,100).toLowerCase() };
    }
    
    var token = event.body.token;
    var ip    = event.requestContext.identity.sourceIp;
    
    checkIsHuman(token, ip).then(resp => {
        item["Human"] = {"BOOL": resp.success };
    }, () => {
        item["Human"] = {"BOOL": true };
    }).then(() => {
        let params = { 
            Item               : item
          , TableName          : "ThesisParticipants"
          , ConditionExpression: "attribute_not_exists(Id)"
        };
    
        console.log(JSON.stringify(item));
    
        dynamodbClient().putItem(params, function(err,data) { 
            if(err) callback(null, { statusCode: 500, body: err, headers: head  });
               else callback(null, { statusCode: 201, body: "", headers: head  });
        });
    });
}

function checkIsHuman(token, ipAddress) {
    return new Promise((resolve, reject) => {
        const postData = `secret=${process.env.recaptcha_secret}&response=${token}&remoteip=${ipAddress}`;
        
        const options = {
          hostname: process.env.recaptcha_host
         ,port: 443
         ,path: process.env.recaptcha_path
         ,method: 'POST'
         ,headers: {
           'Content-Type': 'application/x-www-form-urlencoded',
           'Content-Length': postData.length
          }
        };
        
        const req = https.request(options, res => {
            let body = '';

            res.setEncoding('utf8');
            res.on('data', (chunk) => body += chunk);
            
            res.on('end', () => { 
                resolve(JSON.parse(body)); 
            });
        });
        
        req.write(postData);
        req.on('error', reject);
        req.end();
    });
}

function dynamodbClient() {
    return dynamodb;
}