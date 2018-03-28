$(document).ready( function () {
    var canvas  = new Canvas(document.querySelector('#c'));

    if (!canvas.getContext2d) {
        return;//if canvas unsupported code here
    }
    
    
    var context = canvas.getContext2d();
    var width   = canvas.getWidth();
    var height  = canvas.getHeight();
    
    
    
    var colWidth  = width/125; //10;
    var rowHeight = height/100; //10;
    
    var cols = width/colWidth;
    var rows = height/rowHeight;
    
    console.log("rows:" + rows);
    console.log("cols:" + cols);
    console.log("cels:" + cols*rows);
    
    for(var col = 0; col<cols; col++) {
        context.moveTo(colWidth*col,0);
        context.lineTo(colWidth*col,height);
        context.stroke();
    }
    
    for(var row = 0; row<rows; row++) {
        context.moveTo(0, rowHeight*row);
        context.lineTo(width, rowHeight*row);
        context.stroke();
    }
});