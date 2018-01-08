var targets = [];

$(document).ready( function () {
    var canvas  = document.querySelector('#c');

    if (!canvas.getContext) {
        return;//canvas-unsupported code here
    }
  
    sizeWipeDraw = function(){
        sizeCanvas(canvas);
        wipeCanvas(canvas);
        drawCanvas(canvas);
    };
 
    wipeDraw = function() { 
        wipeCanvas(canvas); 
        drawCanvas(canvas); 
        window.requestAnimationFrame(wipeDraw);
    };
  
    sizeWipeDraw();
  
    $(window).bind('resize', sizeWipeDraw);
  
    window.requestAnimationFrame(wipeDraw);
    
    poissonProcess.create(50, function () { targets.push(new Target(canvas))} ).start();    
});

//https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Drawing_shapes

function sizeCanvas(canvas) 
{
    // If we define a width and height here along with our css style it makes things blurry
    // See this resource for a more in depth explnation (https://webglfundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html)
    // As a solution for now I'm simply removing the width and height attributes from the canvas element so css resizes everything

    //Also see https://www.aregooglesbouncingballshtml5.com/ for a working example

    var realToCSSPixels = window.devicePixelRatio; //to handle High-DPI screens (see above webglfundamentals link for details and performance considerations)

    canvas.height = Math.floor($(window).height() * realToCSSPixels);
    canvas.width  = Math.floor($(window).width()  * realToCSSPixels);
};

function wipeCanvas(canvas)
{
    canvas.getContext('2d').clearRect(0,0,canvas.width,canvas.height);    
}

function drawCanvas(canvas)
{
    drawTargets();
}

function drawTargets()
{
    targets.forEach(function(target){ target.draw(); });
     
    targets = targets.filter(function(target) {return !target.isDead();} );
       
}