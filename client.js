'use strict'
var fs           = require('fs')
var path         = require('path')
var pull         = require('pull-stream')
var toPull       = require('stream-to-pull-stream')
var File         = require('pull-file')
var explain      = require('explain-error')
var Config       = require('ssb-config/inject')
var Client       = require('ssb-client')
var minimist     = require('minimist')
var muxrpcli     = require('muxrpcli')
var packageJson  = require('./package.json')
var ssbKeys = require('ssb-keys')

const u = require('@elife/utils')

var cmdAliases = {
    feed: 'createFeedStream',
    history: 'createHistoryStream',
    hist: 'createHistoryStream',
    public: 'getPublicKey',
    pub: 'getPublicKey',
    log: 'createLogStream',
    logt: 'messagesByType',
    conf: 'config'
}

const appKey = Buffer.from('P6EGPtCNW7irtdeIk+vRVzVbWOlctUKJuce1IZkO2N4=', 'base64');

function do_(args) {
  var manifestFile = path.join(u.dataLoc(), '__ssb', 'manifest.json')

  let manifest

  try {
    manifest = JSON.parse(fs.readFileSync(manifestFile))
  } catch (err) {
    throw explain(err,
      'no manifest file'
      + '- should be generated first time server is run'
    )
  }

  let port = process.env['SSB_PORT']

  let keys = ssbKeys.loadOrCreateSync(u.secretFile())

  var opts = {
    appKey: appKey,
    manifest: manifest,
    port,
    host: 'localhost',
    caps: {
      shs: appKey
    },
    key: keys.id,
  }

  // connect
  Client(keys, opts, function (err, rpc) {
    if(err) {
      if (/could not connect/.test(err.message)) {
        console.error('Error: Could not connect to ssb-server ' + opts.host + ':' + opts.port)
        console.error('Use the "start" command to start it.')
        console.error('Use --verbose option to see full error')
        throw err
        process.exit(1)
      }
      throw err
    }

    // add aliases
    for (var k in cmdAliases) {
      rpc[k] = rpc[cmdAliases[k]]
      manifest[k] = manifest[cmdAliases[k]]
    }

    // add some extra commands
    //    manifest.version = 'async'
    manifest.config = 'sync'
    //    rpc.version = function (cb) {
    //      console.log(packageJson.version)
    //      cb()
    //    }
    rpc.config = function (cb) {
      console.log(JSON.stringify(config, null, 2))
      cb()
    }

    if (args[0] === 'blobs.add') {
      var filename = process.args[1]
      var source =
        filename ? File(process.args[1])
        : !process.stdin.isTTY ? toPull.source(process.stdin)
        : (function () {
          console.error('USAGE:')
          console.error('  blobs.add <filename> # add a file')
          console.error('  source | blobs.add   # read from stdin')
          process.exit(1)
        })()
      pull(
        source,
        rpc.blobs.add(function (err, hash) {
          if (err)
            throw err
          console.log(hash)
          process.exit()
        })
      )
      return
    }

    // run commandline flow
    muxrpcli(args, manifest, rpc, false)
  })

}

module.exports = {
  do_,
}
