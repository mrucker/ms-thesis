//I decided this was best handled by an html dialog element
function Dialog(x,y,text)
{
    this.draw = function(canvas)
    {
        var context = canvas.getContext2d();
        var font    = { family : 'arial', size: 60, style: function() { return size + "px" + " " + family; } };
        
        context.save();
                
        context.font = font.style();
        context.translate(x,y);
        
        
        var height = 60;//context.measureText("---").width;        
        var width  = context.measureText(text).width;
                        
        context.fillStyle = 'rgba(100,0,0,1)';
        context.fillRect(0,0,width,height);
        
        context.textAlign    = 'left';
        context.textBaseline = 'top';
        context.fillStyle    = 'rgb(0,0,100)'
        context.fillText(text,0,0);
        
        context.restore();
    }
}