$(document).ready( function () {
    var canvas  = new Canvas(document.querySelector('#c'));

    if (!canvas.getContext2d) {
        return;//if canvas unsupported code here
    }

    var mouse   = new Mouse(canvas);    
    var context = canvas.getContext2d();

    canvas.draw = function(canvas) {
        var context = canvas.getContext2d();
        
        drawGrid(mouse, canvas, context);

    };

    mouse.startTracking();
    canvas.startAnimating();
});

var oldWidth = 0;
var oldHeight = 0;

function drawGrid(mouse, canvas, context) {
    var width   = canvas.getWidth();
    var height  = canvas.getHeight();
    
    var colSize = 400; //width/125; //10;
    var rowSize = 400; //height/100; //10;

    var cols = width/colSize;
    var rows = height/rowSize;

    if(oldWidth != width || oldHeight != height) {

        oldWidth = width;
        oldHeight = height;
    
        for(var row = 0; row < rows; row++) {
            for(var col = 0; col < cols; col++) {
                context.moveTo((col+0)*colSize, (row+0)*rowSize);
                context.lineTo((col+0)*colSize, (row+1)*rowSize);
                context.lineTo((col+1)*colSize, (row+1)*rowSize);
                context.lineTo((col+1)*colSize, (row+0)*rowSize);
                context.lineTo((col+0)*colSize, (row+0)*rowSize);
                context.stroke();
                
                var centerX = (col+.5)*colSize;
                var centerY = (row+.5)*rowSize;
                var radius  = (0  +.5)*colSize;
                
                context.moveTo(centerX, centerY);
                context.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                context.stroke();
            }
        }
    }
    
    context.fillStyle    = 'rgb(256,256,256)';
    context.fillRect(canvas.getWidth()-300,canvas.getHeight()-50, 300, 50);
    
    context.save();
    context.fillStyle    = 'rgb(100,100,100)';
    context.font         = '48px Arial';
    context.textAlign    = 'right';
    context.textBaseline = 'bottom';
    context.fillText(Math.floor(mouse.getX()/colSize) + "," + Math.floor(mouse.getY()/rowSize),canvas.getWidth(),canvas.getHeight());
    context.restore();
}