function getTargetSuites() {
    
    var canvas = new Canvas(document.querySelector('#c')).resize($(window).width() - 10, $(window).height() - 10);
    var mouse  = new Mouse(canvas);
    
    var onComplete = function(e) { $("#results").append("<li>" + String(e.target) + "</li>"); };
    
    var benchMarks = [
        {//0
            'name'      : 'target.drawCircle()',
            'fn'        : function() { target.drawCircle(canvas); },
            'setup'     : function() { 
                var canvas = new Canvas(document.querySelector('#c'));
                var target = new Target(new Mouse(canvas)); 
            },
            'onComplete': onComplete
        },
        {//1
            'name'      : 'target.drawSquare()',
            'fn'        : function() { target.drawSquare(canvas); },
            'setup'     : function() { 
                var canvas = new Canvas(document.querySelector('#c'));
                var target = new Target(new Mouse(canvas)); 
            },
            'onComplete': onComplete
        },
        {//2
            'name'      : 'target.drawImage()',
            'fn'        : function() { target.drawImage(canvas); },
            'setup'     : function() { 
                var canvas = new Canvas(document.querySelector('#c'));
                var target = new Target(new Mouse(canvas)); 
            },
            'onComplete': onComplete
        },
        {//3
            'name'      : 'target.getReward()',
            'fn'        : function() { var reward = target.getReward(); },
            'setup'     : function() { 
                var canvas = new Canvas(document.querySelector('#c'));
                var target = new Target(new Mouse(canvas)); 
            },
            'onComplete': onComplete
        },
        {//4
            'name'      : 'target.getFeatures()',
            'fn'        : function() { var reward = target.getFeatures(); },
            'setup'     : function() { 
                var canvas = new Canvas(document.querySelector('#c'));
                var target = new Target(new Mouse(canvas)); 
            },
            'onComplete': onComplete
        },
        {//5
            'name'      : 'target.isTouched()',
            'fn'        : function() { var reward = target.isTouched(); },
            'setup'     : function() { 
                var canvas = new Canvas(document.querySelector('#c'));
                var target = new Target(new Mouse(canvas)); 
            },
            'onComplete': onComplete
        }
    ];
    
    var drawTarget = {
        'short': 'drawTarget'
      , 'long' : "Draws the target control using three different methods"
      , 'suite': new Benchmark.Suite().add(benchMarks[2]).add(benchMarks[0]).add(benchMarks[1])
    };
    
    var calculateTarget = {
        'short': 'calculateTarget'
      , 'long' : "Performs all intrinsic target calculations such as features, reward and touch"
      , 'suite': new Benchmark.Suite().add(benchMarks[3]).add(benchMarks[4]).add(benchMarks[5])
    };
    
    return [drawTarget, calculateTarget];
}