
    perf = {};
    canvas  = new Canvas(document.querySelector('#c'));
    timer   = new Timer(15000, true);
    counter = new Counter(3, 3000, true);
    mouse   = new Mouse(canvas);
    targets = new Targets(mouse);