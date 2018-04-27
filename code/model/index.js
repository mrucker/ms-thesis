$(document).ready( function () {
    var canvas  = new Canvas(document.querySelector('#c'));

    if (!canvas.getContext2d) {
        return;//if canvas unsupported code here
    }

    var mouse   = new Mouse(canvas);
    
    var context = canvas.getContext2d();
    var width   = canvas.getWidth();
    var height  = canvas.getHeight();
    
    var colWidth  = 30; //width/125; //10;
    var rowHeight = 30; //height/100; //10;

    var cols = width/colWidth;
    var rows = height/rowHeight;

    console.log("rows:" + rows);
    console.log("cols:" + cols);
    console.log("cels:" + cols*rows);


    for(var col = 0; col < cols; col++) {
        context.moveTo(colWidth*col,0);
        context.lineTo(colWidth*col,height);
        context.stroke();
    }

    for(var row = 0; row < rows; row++) {
        context.moveTo(0, rowHeight*row);
        context.lineTo(width, rowHeight*row);
        context.stroke();
    }

    canvas.draw = function(canvas) {
        var context = canvas.getContext2d();

        context.fillStyle    = 'rgb(256,256,256)';
        context.fillRect(canvas.getWidth()-300,canvas.getHeight()-50, 300, 50);
        
        context.save();
        context.fillStyle    = 'rgb(100,100,100)';
        context.font         = '48px Arial';
        context.textAlign    = 'right';
        context.textBaseline = 'bottom';
        context.fillText(Math.floor(mouse.getX()/colWidth) + "," + Math.floor(mouse.getY()/rowHeight),canvas.getWidth(),canvas.getHeight());
        context.restore();
    };

    mouse.startTracking();
    canvas.startAnimating();
});