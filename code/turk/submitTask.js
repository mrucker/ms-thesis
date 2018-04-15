
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

    // Connect to sandbox
    var mturk = new AWS.MTurk({ endpoint: endpoint });
    
    /* 
    Publish a new HIT to the Sandbox marketplace start by reading in the HTML markup specifying your task from a seperate file (my_question.xml). To learn more about the HTML question type, see here: http://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_HTMLQuestionArticle.html
    */ 
    
    // Construct the HIT object below
    // https://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_CreateHITOperation.html
    var myHIT = {
        Title                      : 'This is a new test question',
        Description                : 'Another description',
        MaxAssignments             : 1,
        LifetimeInSeconds          : 3600,
        AssignmentDurationInSeconds: 600,
        Reward                     : '0.20',        
        Question                   : externalFrameHIT,
        //Question                   : externalLinkHIT,

        // Add a qualification requirement that the Worker must be either in Canada or the US 
        QualificationRequirements: [
            {
                QualificationTypeId: '00000000000000000071',
                Comparator: 'In',
                LocaleValues: [
                    { Country: 'US' },
                    { Country: 'CA' },
                ],
            },
        ],
    };

    // Publish the object created above
    mturk.createHIT(myHIT, function (err, data) {
        if (err) {
            $(document.body).append("<h1>" + err.message + "</h1>");            
        } else {
            var b = $(document.body);
            
            b.append('<h1>'+data+'</h1>');
            // Save the HITId printed by data.HIT.HITId and use it in the RetrieveAndApproveResults.js code sample
            b.append('<p>'+'HIT published here: https://workersandbox.mturk.com/mturk/preview?groupId='+data.HIT.HITTypeId+' with HITId: '+data.HIT.HITId+'</p>');            
        }
    })
});

var externalFrameHIT = 
    `<ExternalQuestion xmlns="http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2006-07-14/ExternalQuestion.xsd">
        <ExternalURL>https://thesis.markrucker.net</ExternalURL>
        <FrameHeight>400</FrameHeight>
    </ExternalQuestion>`;
    
var externalLinkHIT = 
    `<QuestionForm xmlns="http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2017-11-06/QuestionForm.xsd">
        <Question>
            <QuestionIdentifier>surveyCode</QuestionIdentifier>
            <DisplayName>Survey Code</DisplayName>
            <IsRequired>true</IsRequired>
            <QuestionContent>
                <Text>
                    Please provide the survey code here:
                </Text>
            </QuestionContent>
            <AnswerSpecification>
                <FreeTextAnswer>                    
                    <Constraints>
                        <IsNumeric minValue="000" maxValue="999"/>
                        <Length minLength="3" maxLength="3"/>
                    </Constraints>
                    <NumberOfLinesSuggestion>1</NumberOfLinesSuggestion>
                </FreeTextAnswer>
            </AnswerSpecification>
        </Question>
    </QuestionForm>`;