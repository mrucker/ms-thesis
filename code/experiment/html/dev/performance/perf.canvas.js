$(document).ready( function () {
    new Canvas(document.querySelector('#c')).resize($(window).width() - 10, $(window).height() - 10);
    
    var benchMarks = [
        {
            'name'      : 'getContext2d',
            'fn'        : function( ) { var context = canvas.getContext2d(); },
            'setup'     : function( ) { var canvas  = new Canvas(document.querySelector('#c')); },
            'onComplete': function(e) { console.log(String(e.target)); }
        },
        {
            'name'      : 'clearRect(0,0,100,100)',
            'fn'        : function( ) { context.clearRect(0,0,100,100); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); },
            'onComplete': function(e) { console.log(String(e.target)); }
        },
        {
            'name'      : 'clearRect(0,0,500,500)',
            'fn'        : function( ) { context.clearRect(0,0,500,500); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); },
            'onComplete': function(e) { console.log(String(e.target)); }
        },
        {
            'name'      : 'fillRect(0,0,100,100)',
            'fn'        : function( ) { context.fillStyle = "rgb(0,255,255)"; context.fillRect(0,0,100,100); },
            'setup'     : function( ) { var context  = new Canvas(document.querySelector('#c')).getContext2d(); },
            'onComplete': function(e) { console.log(String(e.target)); }
        }
    ];
    
    //new Benchmark(benchMarks[0]).run({'async':false});
    new Benchmark(benchMarks[1]).run({'async':false});
    //new Benchmark(benchMarks[2]).run({'async':false});
    //new Benchmark(benchMarks[3]).run({'async':false});
});