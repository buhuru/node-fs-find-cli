commander = require 'commander'
app = require 'node-find'
fs = require 'fs'
{walk} = require 'walk'
log = console.log

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