var mockContext = {};

$.ajax = function(params) {

    requestStats.totalCount++;
    
	if(params.data) {		
		requestStats.totalSize += params.data.length;
	}

    console.log(params);
    
    return $.Deferred().resolve();
}


grecaptcha = {
    render: function(container,params) {
        mockContext.captchaCallback = params.callback;
    },
    
    execute: function() {
        setTimeout(mockContext.captchaCallback, 100);
    }
}