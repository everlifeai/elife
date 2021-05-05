'use strict'
const fs = require('fs')
const path = require('path')

const FIND='1KHLiKZvAvjbY1ziZEHMXawbCEIM6qwjCDm3VYRan/s='
const REPLACE='P6EGPtCNW7irtdeIk+vRVzVbWOlctUKJuce1IZkO2N4='

function main() {
    let filelist = []
    console.log("Searching & fixing up Everlife App Key...")
    withJSFiles('node_modules', (err, file) => {
        if(err && err.code !== 'ENOENT') exitWithErr(err)
        else if(!file) {
            replace_file_ndx_1(filelist, 0)
        } else filelist.push(file)
    })

    function replace_file_ndx_1(filelist, ndx) {
        if(ndx >= filelist.length) return
        replaceAppKey(filelist[ndx], (err) => {
            if(err && err.code !== 'ENOENT') exitWithErr(err)
            else replace_file_ndx_1(filelist, ndx+1)
        })
    }
}


/*      outcome/
 * Walk the given directory and
 * callback with each javascript
 * or JSON file found.
 */
let depth = 1
function withJSFiles(p, cb) {
    if(hitErr()) return
    fs.readdir(p, (err, files) => {
        if(err) cb(err)
        else {
            depth += files.length
            for(let i = 0;i < files.length;i++) {
                let file = path.join(p, files[i])
                fs.stat(file, (err, stats) => {
                    if(err) cb(err)
                    else {
                        if(stats.isDirectory()) {
                            withJSFiles(file, cb)
                        } else if(stats.isFile()) {
                            if(file.endsWith(".js") || file.endsWith(".json")) cb(null, file)
                            depth--
                            if(!depth) cb()
                        }
                    }
                })
            }
            depth--
            if(!depth) cb()
        }
    })
}

function replaceAppKey(file, cb) {
    if(hitErr()) return
    fs.readFile(file, 'utf8', (err, data) => {
        if(err) cb(err)
        else {
            let ndx = data.indexOf(FIND)
            if(ndx >= 0) do_replace_1(data)
            else cb()
        }
    })

    function do_replace_1(data) {
        console.log(`Replacing in ${file}`)
        data = data.replace(FIND, REPLACE)
        fs.writeFile(file, data, cb)
    }
}

/*      outcome/
 * If we hit an error, set the exit
 * code so that other existing
 * processes can shortcircuit and
 * the program will exit with an
 * exit code.
 */
function exitWithErr(err) {
    console.error(err)
    process.exitCode = 1
}

function hitErr() {
    return process.exitCode
}

main()
