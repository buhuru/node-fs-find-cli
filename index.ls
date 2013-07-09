finder = require './lib/finder'
log = console.log 

exit =(m='no message!') ->
    log 'Error:' + m 
    process.exit!

finder.commander.parse process.argv
err, files <- finder.init __dirname 
exir err.toString! if err

log "\n"
log files.length + " files were found: \n"
log files.join "\n"

