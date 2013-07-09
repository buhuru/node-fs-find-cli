(function(){
  var finder, log, exit;
  finder = require('./lib/finder');
  log = console.log;
  exit = function(m){
    m == null && (m = 'no message!');
    log('Error:' + m);
    return process.exit();
  };
  finder.commander.parse(process.argv);
  finder.init(__dirname, function(err, files){
    if (err) {
      exir(err.toString());
    }
    log("\n");
    log(files.length + " files were found: \n");
    return log(files.join("\n"));
  });
}).call(this);
