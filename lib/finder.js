(function(){
  var commander, app, fs, walk, log;
  commander = require('commander');
  app = require('node-find');
  fs = require('fs');
  walk = require('walk').walk;
  log = console.log;
  commander = module.exports.commander = commander.version('0.0.0').usage('[OPTIONS]').option('-p, --path <p>', 'Path to files', String).option('-m, --match <r>', 'Mask to find files', String).option('-i, --ignore <r>', 'Mask to ignore files', String).option('-r, --recursive', 'Recursive strategy', Boolean);
  module.exports.init = function(basedir, cb){
    return fs.readFile('package.json', 'utf-8', function(err, pkg){
      var path, recursive, matcher, igMatcher, mask, igMask, allowed;
      if (err) {
        return cb(err);
      }
      pkg = JSON.parse(pkg);
      path = commander.path ? commander.path : basedir;
      recursive = commander.recursive ? commander.recursive : false;
      app.findFiles = app.findFiles(recursive);
      matcher = commander.match ? commander.match : '.*';
      igMatcher = commander.ignore ? commander.ignore : '';
      try {
        mask = new RegExp(matcher);
      } catch (e$) {
        err = e$;
        if (err) {
          return cb(err);
        }
      }
      if (igMatcher) {
        try {
          igMask = new RegExp(igMatcher);
        } catch (e$) {
          err = e$;
          if (err) {
            return cb(err);
          }
        }
      }
      allowed = curry$(function(allow, ignore, value){
        if (ignore && ignore.test(value)) {
          return false;
        } else {
          return allow.test(value);
        }
      });
      app.findFiles = app.findFiles(allowed(mask, igMask));
      return fs.exists(path, function(exists){
        if (!exists) {
          return cb('"' + path + '": such path does not exists.');
        }
        return app.findFiles(path, function(err, files){
          if (err) {
            return cb(err);
          }
          return cb(null, files);
        });
      });
    });
  };
  function curry$(f, bound){
    var context,
    _curry = function(args) {
      return f.length > 1 ? function(){
        var params = args ? args.concat() : [];
        context = bound ? context || this : this;
        return params.push.apply(params, arguments) <
            f.length && arguments.length ?
          _curry.call(context, params) : f.apply(context, params);
      } : f;
    };
    return _curry();
  }
}).call(this);
