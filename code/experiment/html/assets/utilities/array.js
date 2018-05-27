Array.prototype.toFlat = function() {
    return [].concat.apply([], this);
};

Array.prototype.toDistinct = function(map) {
    
    map = map || function(v) { return v; };
    
    if(map && typeof(map) != "function") {
        throw "Illegal map value (" + key + ", " + typeof(map) + ")"; 
    }    
    
    var areEqual = (map.length == 1) ? function(v1,v2) { return map(v1) == map(v2); } : map;

    return this.filter(function(v1, index, self) { return self.findIndex(function(v2) { return areEqual(v1,v2); }) === index; });
};

Array.prototype.toDict = function(key, map) {

    if(!key || typeof(key) != "string" || typeof(key) != "function") {
       throw "Illegal key (" + key + ", " + typeof(key) + ")";
    }

    var toKey = (typeof(key) == "string") ? (function(item) { return item[key]; }) : (function(item) { return key(item); });
    var toObj = map || (function(item) { return item; });

    return this.reduce(function(dict, item) {
        dict[toKey(item)] = dict[toKey(item)] || [];
        dict.push(toObj(item));
        return dict;
    }, {});
}

Array.prototype.pull = function(value) {
    return this.filter(function(item) { return item != value; });
}