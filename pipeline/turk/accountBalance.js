
$(document).ready( function () {
    //AWS is loaded in a script tag in the html page
    var region                = 'us-east-1';
    var aws_access_key_id     = 'AKIAJIGZ2IZY4BGLMXLQ';
    var aws_secret_access_key = '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';

    AWS.config = {
        "accessKeyId": aws_access_key_id,
        "secretAccessKey": aws_secret_access_key,
        "region": region,
        "sslEnabled": 'true'
    };

    var endpoint = 'https://mturk-requester-sandbox.us-east-1.amazonaws.com';

    // Uncomment this line to use in production
    // endpoint = 'https://mturk-requester.us-east-1.amazonaws.com';

    var mturk = new AWS.MTurk({ endpoint: endpoint });

    // This will return $10,000.00 in the MTurk Developer Sandbox
    mturk.getAccountBalance(function(err, data){ 
        $(document.body).append("<h1>" + data.AvailableBalance + "</h1>");
    });
});