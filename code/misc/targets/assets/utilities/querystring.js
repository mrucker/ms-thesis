var querystring = {
    value: function(name) {

        var cleanName = name.replace(/[\[\]]/g, "\\$&");
        var url       = window.location.href;
        var regex     = new RegExp("[?&]" + cleanName + "(=([^&#]*)|&|#|$)");
        var results   = regex.exec(url);

        return !results ? null : !results[2] ? '' : decodeURIComponent(results[2].replace(/\+/g, " "));
    },    
    exists: function(name) {
        return this.value(name) != null;
    }
}