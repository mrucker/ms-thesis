$.ajax = function(params) {
    console.log(params);
    return $.Deferred().resolve();
}