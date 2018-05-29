function Canvas(canvas)
{
    var self        = this;
    var context2d   = canvas.getContext('2d');
    var isAnimating = false;
    var everyother  = false;
    var deviceMoveListeners = [];

    var pageW       = $(window).width();
    var pageH       = $(window).height();
    var styleW      = pageW -10;
    var styleH      = pageH -10;
    var deviceW     = styleW * window.devicePixelRatio;
    var deviceH     = styleH * window.devicePixelRatio;

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
        //either of these methods cause noticable performance loss on low resource machines
        
        //canvas.getContext2d().fillStyle = 'rgba(255,255,255,1)';
        //canvas.getContext2d().fillRect(0,0, this.getWidth(), this.getHeight());
        
        canvas.getContext2d().clearRect(0,0, this.getWidth(), this.getHeight());
    }
    
    function animate() {
        
        everyother = !everyother;
        
        if(everyother) {  
            self.wipe(self);
            self.draw(self);
        }

        if(isAnimating) {
            window.requestAnimationFrame(animate);
        }
    };
    
    function onResize () {
        
        var ratioW = $(window).width()/pageW;
        var ratioH = $(window).height()/pageH;

        pageW   *= ratioW
        pageH   *= ratioH
        styleW  *= ratioW;
        styleH  *= ratioH;        
        deviceW *= ratioW;
        deviceH *= ratioH;
            
        //this represents the resolution of the canvas
        canvas.width  = deviceW;
        canvas.height = deviceH;
        
        //this represents the amount of space the canvas consumes on the page (aka the whole web page)
        canvas.style.width  = styleW + 'px';
        canvas.style.height = styleH + 'px';        
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