function Canvas(canvas)
{
    var self       = this;    
    var everyother = false;
    var onMove     = undefined;
    var started    = undefined;
    var stopped    = undefined;
    var fps        = new Frequency("fps", false);
    
    this.getContext2d = function() {
        return canvas.getContext('2d');
    };
    
    this.getDimensions = function(dim) {
        if(dim != 0 && dim != 1 && dim != undefined) {
            throw "invalid dimension";
        }

        var w = Number(canvas.style.width.trim().toLowerCase().replace("px",""));
        var h = Number(canvas.style.height.trim().toLowerCase().replace("px",""));
        
        if(dim == undefined) {
            return [w,h];
        }
        
        return [w, h][dim]
    }
    
    this.getResolution = function(dim) {
        if(dim != 0 && dim != 1 && dim != undefined) {
            throw "invalid dimension";
        }

        if(dim == undefined) {
            return [canvas.width, canvas.height];
        }
        
        return [canvas.width, canvas.height][dim]    }
     
    this.startAnimating = function () {
        fps.start(); 
        
        started = true;
        stopped = false;
        
        window.requestAnimationFrame(animate);
    };
    
    this.stopAnimating = function () {
        fps.stop();
        
        stopped = true;
    };
    
    this.getFPS = function() {
        return Math.round(fps.getHz(),0);
    }
    
    this.addOnDeviceMove = function(callback) {

        canvas.addEventListener("mousemove", onMouseMove, false);
        canvas.addEventListener("touchmove", onTouchMove, false);

        onMove = callback;
    }

    this.removeOnDeviceMove = function(callback) {

        onMove = undefined;

        canvas.removeEventListener("mousemove", onMouseMove);
        canvas.removeEventListener("touchmove", onTouchMove);
    }

    this.draw = function(canvas) {}

    this.wipe = function (canvas) {
        canvas.getContext2d().clearRect(0,0, self.getResolution(0), self.getResolution(1));
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
        fps.cycle();

        if(everyother = !everyother) {
            self.wipe(self);
            self.draw(self);

            // var context = self.getContext2d();
            // context.fillStyle    = 'rgb(100,100,100)';
            // context.font         = '48px Arial';
            // context.textAlign    = 'left';
            // context.textBaseline = 'top';
            // context.fillText(self.getFPS(), 0, 0);
        }

        if(started && !stopped) {
            window.requestAnimationFrame(animate);
        }
    };

    function onMouseMove(e) {
        onDeviceMove(e.clientX, e.clientY);
    }

    function onTouchMove(e) {
        onDeviceMove(e.touches[0].clientX, e.touches[0].clientY);
        e.preventDefault();
    }

    function onDeviceMove(clientX,clientY) {

        // the clientX and clientY values are the mouse (x,y) coordinates relative to the viewable browser window.
        // This means things like, if the user is scrolled down on a page, the top left of the visible page is still coordinate (0,0).
        // Therefore, if there are scroll bars on our canvas, or the canvas has a different resolution we need to calculate our canvas x,y.
        
        var scrollDifferenceLeft = canvas.getBoundingClientRect().left;
        var scrollDifferenceTop  = canvas.getBoundingClientRect().top;
        var resolutionDifference = window.devicePixelRatio;
        
        var relativeX = (clientX - scrollDifferenceLeft) * resolutionDifference;
        var relativeY = (clientY - scrollDifferenceTop ) * resolutionDifference;
        
        
        onMove(relativeX, relativeY);
    }
    
}