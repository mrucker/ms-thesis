function getCanvasSuites() {
    
    new Canvas(document.querySelector('#c')).resize($(window).width() - 10, $(window).height() - 10);
    
    var onComplete = function(e) { $("#results").append("<li>" + String(e.target) + "</li>"); };
    
    var benchMarks = [
        {
            'name'      : 'getContext2d',
            'fn'        : function( ) { var context = canvas.getContext('2d'); },
            'setup'     : function( ) { var canvas  = document.querySelector('#c'); },
            'onComplete': onComplete
        },//1
        {
            'name'      : 'clearRect(0,0,100,100)',
            'fn'        : function( ) { context.clearRect(0,0,100,100); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); },
            'onComplete': onComplete
        },//2
        {
            'name'      : 'clearRect(0,0,300,300)',
            'fn'        : function( ) { context.clearRect(0,0,300,300); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); },
            'onComplete': onComplete
        },//3
        {
            'name'      : 'rgb&fillRect(0,0,100,100)',
            'fn'        : function( ) { context.fillStyle = "rgb(0,255,255)"; context.fillRect(0,0,100,100); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); },
            'onComplete': onComplete
        },//4
        {
            'name'      : 'rgb&fillRect(0,0,300,300)',
            'fn'        : function( ) { context.fillStyle = "rgb(0,255,255)"; context.fillRect(0,0,300,300); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); },
            'onComplete': onComplete
        },//5
        {
            'name'      : 'rgba1&fillRect(0,0,100,100)',
            'fn'        : function( ) { context.fillStyle = "rgba(0,255,255,.5)"; context.fillRect(0,0,100,100); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); },
            'onComplete': onComplete
        },//6
        {
            'name'      : 'rgba2&fillRect(0,0,100,100)',
            'fn'        : function( ) { context.fillStyle = "rgba(0,255,255,.511111)"; context.fillRect(0,0,100,100); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); },
            'onComplete': onComplete
        },//7
        {
            'name'      : 'rgba1&fillRect(0,0,300,300)',
            'fn'        : function( ) { context.fillStyle = "rgba(0,255,255,.5)"; context.fillRect(0,0,300,300); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); },
            'onComplete': onComplete
        },//8
        {
            'name'      : 'fillRect(0,0,100,100)',
            'fn'        : function( ) { context.fillRect(0,0,100,100); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); context.fillStyle = "rgb(0,255,255)"; },
            'onComplete': onComplete
        },//9
        {
            'name'      : 'fillRect(0,0,300,300)',
            'fn'        : function( ) { context.fillRect(0,0,300,300); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); context.fillStyle = "rgb(0,255,255)"; },
            'onComplete': onComplete
        }
    ];
        
    var clearRect = {
        'short': 'clearRect'
      , 'long' : "clearRect appears to perform about the same as fillRect in Chrome and with an unknown performance in other browsers."
      , 'long2': "I say unknown because it causes a noticable performance drop in IE even though this test seems to say that it doesn't."
      , 'suite': new Benchmark.Suite().add(benchMarks[1]).add(benchMarks[2])
    };
        
    var longAlpha = {
        'short': 'longAlpha'
      , 'long' : "long tail decimals don't negatively influence transparency rendering"
      , 'suite': new Benchmark.Suite().add(benchMarks[5]).add(benchMarks[6])
    };
    
    var anyAlpha = {
        'short': 'anyAlpha'
      , 'long' : "alpha value doesn't significantly impact the draw performance"
      , 'suite': new Benchmark.Suite().add(benchMarks[4]).add(benchMarks[7])
    };
    
    var largeRect = {
        'short': 'largeRect'
      , 'long' : "large rectangles cause a precipitous drop off in draw performance"
      , 'suite': new Benchmark.Suite().add(benchMarks[8]).add(benchMarks[9])
    }
    
    var getContext2d = {
        'short': 'getContext2d'
      , 'long' : "getting the 2d context takes time in certain browsers"
      , 'suite': new Benchmark.Suite().add(benchMarks[0])
    };
    
    var setFillStyle = {
        'short': 'setFillStyle'
      , 'long' : "setting the fillStyle causes measurable drop in performance"
      , 'suite': new Benchmark.Suite().add(benchMarks[3]).add(benchMarks[8])
    };
    
    return [clearRect, longAlpha, anyAlpha, largeRect, getContext2d, setFillStyle];
}