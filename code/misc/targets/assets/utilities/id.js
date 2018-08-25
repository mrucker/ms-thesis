function Id() {

}

//17 bytes in storage size
Id.generate = function () {
    //r1 = Final value represents a number between 0 and 4.295 billion (we remove characters and convert to hex to save space)
    //r2 = Final value represents a number between 0 and 795.36 days worth of miliseconds (we remove characters and convert to hex to save space)
    var r1 = Math.floor(Math.random()*Math.pow(10,16)).toString(16).substring(0,8); 
    var r2 = Date.now().toString(16).substring(2);

    return r1 + r2;
}

Id.readStore = function(key) {
                
    if(!Id.isStorageAvailable('localStorage')) {
        return undefined;
    }

    return window.localStorage.getItem(key);
}

Id.writeStore = function (key,id) {

    if(!Id.isStorageAvailable('localStorage')) {
        return;
    }

    window.localStorage.setItem(key, id);
}

//from https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API
Id.isStorageAvailable = function(type) {
    try {
        var storage = window[type],
            x = '__storage_test__';
        storage.setItem(x, x);
        storage.removeItem(x);
        return true;
    }
    catch(e) {
        return e instanceof DOMException && (
            // everything except Firefox
            e.code === 22 ||
            // Firefox
            e.code === 1014 ||
            // test name field too, because code might not be present
            // everything except Firefox
            e.name === 'QuotaExceededError' ||
            // Firefox
            e.name === 'NS_ERROR_DOM_QUOTA_REACHED') &&
            // acknowledge QuotaExceededError only if there's something already stored
            storage.length !== 0;
    }
}