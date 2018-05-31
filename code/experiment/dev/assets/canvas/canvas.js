function Canvas(canvas)
{
    var self          = this;
    var isAnimating   = false;
    var everyother    = false;
    var moveListeners = [];
    
    this.getContext2d = function() {
        return canvas.getContext('2d');
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
        
        if(moveListeners.length == 0) {
            canvas.addEventListener("mousemove", onMouseMove, false);
            canvas.addEventListener("touchmove", onTouchMove, false);
        }
        
        moveListeners = moveListeners.concat([callback]).toDistinct();
    }
    
    this.removeDeviceMoveListener = function(callback) {
        
        moveListeners = moveListeners.filter(function(listener) { return listener != callback; });
        
        if(moveListeners.length == 0) {
            canvas.removeEventListener("mousemove", onMouseMove)
            canvas.removeEventListener("touchmove", onTouchMove);
        }
    }

    this.draw = function(canvas) {}
    
    this.wipe = function (canvas) {
        //on IE and Firefox clear rect is considerably faster than fillRect
        //on modern chrome browsers this doesn't seem to be the case. Fill and clear are about equal.
        canvas.getContext2d().clearRect(0,0, this.getWidth(), this.getHeight());
    }
    
    this.scale = function(scaleW, scaleH) {
        canvas.width  *= scaleW;
        canvas.height *= scaleH;
        
        canvas.style.width  *= scaleW;
        canvas.style.height *= scaleH;
    }
    
    this.resize = function(styleW, styleH) {
        
        //this represents the number of pixels inside the canvas
        canvas.width  = styleW * window.devicePixelRatio;
        canvas.height = styleH * window.devicePixelRatio;
        
        //this represents the amount of space the canvas consumes on the page
        canvas.style.width  = styleW + 'px';
        canvas.style.height = styleH + 'px';
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
        
        moveListeners.forEach(function (listener) { listener(relativeX, relativeY); });
    }
    
}