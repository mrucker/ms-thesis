function getTargetSuites() {
    
    var canvas = new Canvas(document.querySelector('#c')).resize($(window).width() - 10, $(window).height() - 10);
    var mouse  = new Mouse(canvas);
    
    var onComplete = function(e) { $("#results").append("<li>" + String(e.target) + "</li>"); };
    
    var benchMarks = [
        {
            'name'      : 'target.draw()',
            'fn'        : function() { target.draw(canvas); },
            'setup'     : function() { 
                var canvas = new Canvas(document.querySelector('#c'));
                var target = new Target(new Mouse(canvas)); 
            },
            'onComplete': onComplete
        },//1
        {
            'name'      : 'target.getReward()',
            'fn'        : function() { var reward = target.getReward(); },
            'setup'     : function() { 
                var canvas = new Canvas(document.querySelector('#c'));
                var target = new Target(new Mouse(canvas)); 
            },
            'onComplete': onComplete
        },//2
        {
            'name'      : 'target.getFeatures()',
            'fn'        : function() { var reward = target.getFeatures(); },
            'setup'     : function() { 
                var canvas = new Canvas(document.querySelector('#c'));
                var target = new Target(new Mouse(canvas)); 
            },
            'onComplete': onComplete
        },//3
        {
            'name'      : 'target.isTouched()',
            'fn'        : function() { var reward = target.isTouched(); },
            'setup'     : function() { 
                var canvas = new Canvas(document.querySelector('#c'));
                var target = new Target(new Mouse(canvas)); 
            },
            'onComplete': onComplete
        }
    ];
        
    new Benchmark(benchMarks[0]).run({'async':false});
    new Benchmark(benchMarks[1]).run({'async':false}); 
    new Benchmark(benchMarks[2]).run({'async':false}); 
    new Benchmark(benchMarks[3]).run({'async':false}); 
}