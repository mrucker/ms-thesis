//An interesting article on Math.random(), https://v8project.blogspot.com/2015/12/theres-mathrandom-and-then-theres.html

//Because it isn't possible to get an atomic lock on our dynamodb database it isn't possible to guarantee there will be no collision for users
//Therefore, we must rely on statistical likelihood of having no collision rather than knowing for certain there will be no collisions.
//One nice artifact of this approach is that it also increases security
$(document).ready( function () {

    var generators = [generateId3, generateId4];

    generators.forEach(function(g){

        var duplicateCount = 0;        
        var potentialIds = [];
        
        var start = Date.now();
        
        for(var i = 0; i < Math.pow(10,7); i++)
        {
            potentialIds.push(g());
        }
        
        var stop = Date.now();

        var seen          = new Set();
        var hasDuplicates = potentialIds.some(function(r) { return seen.size === seen.add(r).size; });                
        
        var duplicateMsg = hasDuplicates ? 'Has Duplicates' : 'No Duplicates';
        
        $(document.body).append('<h1>' + g.name + ' ' + duplicateMsg + ' in ' + i +' (Sample: ' + potentialIds[1] + ')</h1>');
        $(document.body).append('<h2>' + 'runtime: ' + (stop-start)/(i)  + '</h2>');
    });
});

//14 bytes per user id in dynamodb (dynamodb uses UTF-8 which encodes alll ASCII characters in 8 bits)
//Final value represents a random number between 0 and 2^32 (c.f., https://stackoverflow.com/a/27944437/1066291)
function generateId3()
{
    return Math.floor(Math.random()*Math.pow(10,16)).toString(16);
}

//17 bytes per user id in dynamodb (dynamodb uses UTF-8 which encodes alll ASCII characters in 8 bits)
//r1 = Final value represents a number between 0 and 4.295 billion (we remove characters and convert to hex to save space)
//r2 = Final value represents a number between 0 and 795.36 days worth of miliseconds (we remove characters and convert to hex to save space)
function generateId4()
{
    var r1 = Math.floor(Math.random()*Math.pow(10,16)).toString(16).substring(0,8); 
    var r2 = Date.now().toString(16).substring(2);
    
    return r1 + r2;
}

//32 bytes per user id in dynamodb (dynamodb uses UTF-8 which encodes alll ASCII characters in 8 bits)
//A quasi UUID algorithm according to the ietf standard (not a perfect implementation of ietf algorithm)
//Algorithm taken from https://stackoverflow.com/a/21963136/1066291
function generateId5()
{
    var lut = Array(256).fill().map((_, i) => (i < 16 ? '0' : '') + (i).toString(16));
    var formatUuid = ({d0, d1, d2, d3}) =>
      lut[d0       & 0xff]        + lut[d0 >>  8 & 0xff] + lut[d0 >> 16 & 0xff] + lut[d0 >> 24 & 0xff] + '-' +
      lut[d1       & 0xff]        + lut[d1 >>  8 & 0xff] + '-' +
      lut[d1 >> 16 & 0x0f | 0x40] + lut[d1 >> 24 & 0xff] + '-' +
      lut[d2       & 0x3f | 0x80] + lut[d2 >>  8 & 0xff] + '-' +
      lut[d2 >> 16 & 0xff]        + lut[d2 >> 24 & 0xff] +
      lut[d3       & 0xff]        + lut[d3 >>  8 & 0xff] +
      lut[d3 >> 16 & 0xff]        + lut[d3 >> 24 & 0xff];

    var getRandomValuesFunc = window.crypto && window.crypto.getRandomValues ?
      () => {
        const dvals = new Uint32Array(4);
        window.crypto.getRandomValues(dvals);
        return {
          d0: dvals[0],
          d1: dvals[1],
          d2: dvals[2],
          d3: dvals[3],
        };
      } :
      () => ({
        d0: Math.random() * 0x100000000 >>> 0,
        d1: Math.random() * 0x100000000 >>> 0,
        d2: Math.random() * 0x100000000 >>> 0,
        d3: Math.random() * 0x100000000 >>> 0,
      });

    return formatUuid(getRandomValuesFunc());
}