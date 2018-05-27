function Canvas(canvas)
{
    //for more information on the resize event and the devicePixelRatio for High-DPI screens see:
    //details -- https://webglfundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
    //example -- https://www.aregooglesbouncingballshtml5.com/

    var context2d          = canvas.getContext('2d');
    var isAnimating        = false;
    var self               = this;
    var deviceMoveListeners = [];
    
    onResize();
    
    window.addEventListener('resize', onResize);
    
    this.getContext2d = function() {
        return context2d;
    };
    
    this.getWidth = function() {
        return canvas.width;
    };
    
    this.getHeight = function() {
        return canvas.height;
    };        
 
    this.startAnimating = function () {
        isAnimating = true;           
        window.requestAnimationFrame(animate);
    };
    
    this.stopAnimating = function () {
        isAnimating = false;
    };
    
    this.addDeviceMoveListener = function(callback) {
        
        if(deviceMoveListeners.length == 0) {
            canvas.addEventListener("mousemove", onMouseMove, false);
            canvas.addEventListener("touchmove", onTouchMove, false);
        }
        
        deviceMoveListeners = deviceMoveListeners.concat([callback]).toDistinct();
    }
    
    this.removeDeviceMoveListener = function(callback) {
        
        deviceMoveListeners = deviceMoveListeners.filter(function(listener) { return listener != callback; });
        
        if(deviceMoveListeners.length == 0) {
            canvas.removeEventListener("mousemove", onMouseMove)
            canvas.removeEventListener("touchmove", onTouchMove);
        }
    }

    this.draw = function(canvas) {}
    
    this.wipe = function (canvas) {
        canvas.getContext2d().clearRect(0,0, this.getWidth(), this.getHeight());
    }
    
    function animate() {
        self.wipe(self);
        self.draw(self);
        
        if(isAnimating) {
            window.requestAnimationFrame(animate);
        }
    };
    
    function onResize () {
        //the -10 is to make sure that scrollbars do not appear
        var pageWidth  = $(window).width()-10;
        var pageHeight = $(window).height()-10;
        
        var deviceWidth  = pageWidth  * window.devicePixelRatio;
        var deviceHeight = pageHeight * window.devicePixelRatio;
            
        //this represents the resolution of the canvas
        canvas.width  = deviceWidth;
        canvas.height = deviceHeight;
        
        //this represents the amount of space the canvas consumes on the page (aka the whole web page)
        canvas.style.width  = pageWidth + 'px';
        canvas.style.height = pageHeight + 'px';
        
        //context2d.transform(screenWidth*Math.sqrt(2),0,0,trueHeight*Math.sqrt(2),0,0);
        //context2d.transform(window.devicePixelRatio,0,0,window.devicePixelRatio,0,0);
    };

    function onMouseMove(e) {
        onInputMove(e.clientX, e.clientY);
    }
    
    function onTouchMove(e) {
        onInputMove(e.touches[0].clientX, e.touches[0].clientY);
        e.preventDefault();
    }
    
    function onInputMove(clientX,clientY) {

        // the clientX and clientY values are the mouse (x,y) coordinates relative to the viewable browser window.
        // This means things like, if the user is scrolled down on a page, the top left of the visible page is still coordinate (0,0).
        // Therefore, if there are scroll bars on our canvas, or the canvas has a different resolution we need to calculate our canvas x,y.
        
        var scrollDifferenceLeft = canvas.getBoundingClientRect().left;
        var scrollDifferenceTop  = canvas.getBoundingClientRect().top;        
        var resolutionDifference = window.devicePixelRatio;
        
        var relativeX = (clientX - scrollDifferenceLeft) * resolutionDifference;
        var relativeY = (clientY - scrollDifferenceTop ) * resolutionDifference;
        
        deviceMoveListeners.forEach(function (listener) { listener(relativeX, relativeY); });
    }
    
}