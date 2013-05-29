{ List: {any, filter, map}, Func: {curry, flip, fix, apply} } = require 'prelude-ls'
commander = require 'commander'

fs = require 'fs'
{walk} = require 'walk'
log = console.log

app = {}
app.findFiles = (recursive, allowed, path, cb) -->
    if not recursive
    then @flatten-find allowed, path, cb
    else @walker-find allowed, path, cb

app.append-path = (separator, path1, path2) -->
    firts-char = path1.charAt path1.length-1
    last-char = path2.charAt 0
    if any (is separator), [firts-char, last-char]
    then path1 + path2
    else path1 + separator + path2

app.append-path = app.append-path '/'

app.flatten-find = (allowed, path, cb)->
    append = app.append-path path
    err, files <- fs.readdir path
    return cb err if err
    files = map append, files
    files = filter allowed, files
    cb null, files

app.walker-find = (allowed, path, cb)->
    files = []
    append = @append-path
    walker = walk path, followLinks : false
    walker.on 'error', (err) -> cb err
    walker.on 'end', -> cb null, files
    (path, stats, next) <- walker.on 'file'
    file = append path, stats.name
    if allowed file then files.push file
    next!

commander = module.exports.commander = commander.version '0.0.0'
    .usage '[OPTIONS]'
    .option '-p, --path <p>',  'Path to files', String
    .option '-m, --match <r>', 'Mask to find files', String
    .option '-i, --ignore <r>', 'Mask to ignore files', String
    .option '-r, --recursive', 'Recursive strategy', Boolean

module.exports.init = (basedir, cb)->
    
    err, pkg <- fs.readFile 'package.json', 'utf-8'

    return cb err if err

    pkg = JSON.parse pkg


    path = if commander.path 
    then commander.path 
    else basedir 

    recursive = if commander.recursive 
    then commander.recursive 
    else false

    app.findFiles = app.findFiles recursive

    matcher = if commander.match 
    then commander.match 
    else '.*'

    ig-matcher = if commander.ignore 
    then commander.ignore 
    else ''

    try 
        mask = new RegExp matcher
    catch  err
        return cb err if err

    if ig-matcher then
        try 
            ig-mask = new RegExp ig-matcher
        catch  err
            return cb err if err

    allowed = (allow, ignore, value) -->
        if ignore and ignore.test value
        then false
        else allow.test value
        
    app.findFiles = app.findFiles allowed mask, ig-mask

    exists <- fs.exists path
    if not exists 
    then return cb '"'+ path+ '": such path does not exists.'

    err, files <- app.findFiles path
    return cb err if err

    cb(null, files)