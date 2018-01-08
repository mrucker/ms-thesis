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
    
    poissonProcess.create(5000, function () { targets.push(new Target(canvas))} ).start();    
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
    drawContent(canvas.getContext('2d'));
}

function drawContent(context)
{
    drawText(context);
    drawRectangles(context);
    drawPaths(context);
    context.stroke(newCircle(300,400,35));
    drawTargets();
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

function drawTargets()
{
    targets.forEach(function(target){
        target.wipe();
        target.draw();
    });
}

function Target(canvas)
{
    var r = 10;
    var x = (canvas.height - 2*r) * Math.random() + r; //[r,height-r]
    var y = (canvas.width  - 2*r) * Math.random() + r; //[r, width-r]
    var c = 'rgb(0,200,0)';
    
    var context    = canvas.getContext('2d');
    var createTime = new Date();
    var circlePath = new Path2D();
    
    circlePath.moveTo(this.x, this.y);
    circlePath.arc(x-r, y, r, 0, 2 * Math.PI);
        
    this.getCreateTime = function() { return createTime };
    this.getX          = function() { return x; };
    this.getY          = function() { return y; };
    
    this.wipe = function(){
        context.save();
        context.fillStyle = 'rgb(0,0,0)';
        context.fill(circlePath);
        context.restore();
    }
    
    this.draw = function(){
        context.save();
        context.fillStyle = c;
        context.fill(circlePath);
        context.restore();
    }
}