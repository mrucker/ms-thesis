function Canvas(canvas)
{
    //for more information on the resize event and the devicePixelRatio for High-DPI screens see:
    //details -- https://webglfundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
    //example -- https://www.aregooglesbouncingballshtml5.com/
    
    var context2d          = canvas.getContext('2d');
    var devicePixelRatio   = window.devicePixelRatio;
    var boundingClientRect = canvas.getBoundingClientRect();
    var that               = this;
    var isAnimating        = false;
    
    canvas.height      = Math.floor($(window).height() * devicePixelRatio);
    canvas.width       = Math.floor($(window).width()  * devicePixelRatio);
    boundingClientRect = canvas.getBoundingClientRect();

    var onResize = function () {        
        canvas.height      = Math.floor($(window).height() * devicePixelRatio);
        canvas.width       = Math.floor($(window).width()  * devicePixelRatio);
        boundingClientRect = canvas.getBoundingClientRect();
    };
        
    var animate = function() {
        that.wipe();
        that.draw();
        
        if(isAnimating) {
            window.requestAnimationFrame(animate);
        }
    };
    
    this.getBoundingClientRect = function() {
        return boundingClientRect;
    };
    
    this.getDevicePixelRatio = function() {
        return devicePixelRatio;
    };
    
    this.getContext2d = function() {
        return context2d;
    };
    
    this.getHeight = function() {
        return canvas.height;
    };
    
    this.getWidth = function() {
        return canvas.width;
    };
 
    this.startAnimating = function () {
        isAnimating = true;   
        window.addEventListener('resize', onResize);
        window.requestAnimationFrame(animate);
    };
    
    this.stopAnimating = function () {
        isAnimating = false;
        window.removeEventListener('resize', onResize);
    };
    
    this.addEventListener = function(eventName, onEventName) {
        canvas.addEventListener(eventName, onEventName);
    };
        
    this.draw = function() {}
    
    this.wipe = function () {
        context2d.clearRect(0,0, this.getWidth(), this.getHeight());
    }
}