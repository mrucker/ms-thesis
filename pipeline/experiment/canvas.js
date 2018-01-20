function Canvas(canvas)
{
    //for more information on the resize event and the devicePixelRatio for High-DPI screens see:
    //details -- https://webglfundamentals.org/webgl/lessons/webgl-resizing-the-canvas.html
    //example -- https://www.aregooglesbouncingballshtml5.com/

    var callbacks          = {};
    var context2d          = canvas.getContext('2d');
    var devicePixelRatio   = window.devicePixelRatio;
    var boundingClientRect = canvas.getBoundingClientRect();
    var that               = this;
    var isAnimating        = false;
    
    canvas.height      = Math.floor($(window).height() * devicePixelRatio);
    canvas.width       = Math.floor($(window).width()  * devicePixelRatio);
    boundingClientRect = canvas.getBoundingClientRect();
    
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
    
    this.addEventListener = function(type, callback) {
        callbacks[type] = [callback].concat(callbacks[type] || []);        
        canvas.addEventListener(type, proxyCallback);
    };
    
    this.removeEventListener = function(type, callback) {
        canvas.removeEventListener(type, proxyCallback);
        callbacks[type] = undefined;
    }

    this.draw = function(canvas) {}
    
    this.wipe = function (canvas) {
        canvas.getContext2d().clearRect(0,0, this.getWidth(), this.getHeight());
    }
    
    function onResize () {
        canvas.height      = Math.floor($(window).height() * devicePixelRatio);
        canvas.width       = Math.floor($(window).width()  * devicePixelRatio);
        boundingClientRect = canvas.getBoundingClientRect();
    };
        
    function animate() {
        that.wipe(that);
        that.draw(that);
        
        if(isAnimating) {
            window.requestAnimationFrame(animate);
        }
    };
    
    function proxyCallback(e) {
        callbacks[e.type].forEach(function(callback) { callback.call(that, e); })
    }
}