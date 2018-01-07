$(document).ready( function () {
  var canvas  = document.querySelector('#c');  

  sizeCanvas(canvas);
  wipeCanvas(canvas);
  drawCanvas(canvas);

  $(window).bind('resize', function(){ sizeCanvas(canvas); wipeCanvas(canvas); drawCanvas(canvas); });
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
    if (canvas.getContext) {
        drawContent(canvas.getContext('2d'));
    } else {
        // canvas-unsupported code here
    }
}

function drawContent(context)
{
    drawText(context);
    drawRectangles(context);
    drawPaths(context);

    context.stroke(newCircle(300,400,35));

}

function drawText(context)
{
    context.fillStyle = 'blue';
    context.font      = 'italic 40pt Calibri, sans-serif';
    context.fillText('Hello World!', 100, 50);
}

function drawRectangles(context)
{
    context.fillStyle = 'rgb(0, 200, 0)';
    context.fillRect(100,100, 150,150);
    context.strokeRect(100, 100, 150, 150);

    context.fillStyle = 'rgba(200, 0, 0, 0.5)';
    context.fillRect(175, 175, 150, 150);
    context.strokeRect(175, 175, 150, 150);
}

function drawPaths(context)
{
    context.beginPath();
    context.moveTo(100,100);
    context.lineTo(175,175);
    context.moveTo(250,100);
    context.lineTo(325,175);
    context.moveTo(100,250);
    context.lineTo(175,325);
    context.moveTo(250,250);
    context.lineTo(325,325);
    context.stroke();

    // COMMANDS TO CREATE PATHS
    // context.beginPath();
    // context.closePath();
    // context.moveTo();
    // context.lineTo();
    // context.bezzierCurveTo();
    // context.quadraticCurveTo();
    // context.arc();
    // context.arcTo();
    // context.ellipse();
    // context.rect();

    // COMMANDS TO RENDER PATHS
    // context.fill();
    // context.stroke();
}

function newCircle(x,y,r)
{
        var circle = new Path2D();
        circle.moveTo(x, y);
        circle.arc(x-r, y, r, 0, 2 * Math.PI);

        //circle.arc(x, y, radius, startAngle, endAngle);

        return circle;
}