'use strict'
const pm2 = require('pm2')
const path = require('path')
const pkgmgr = require('@elife/pkg-mgr')
const u = require('@elife/utils')

if(!process.env.IN_DOCKER){
    const dotenv = require('dotenv').config({ path : path.join(u.dataLoc(),'cfg.env')})
}

/*      understand/
 * This is the main entry point where we start.
 *
 *      outcome/
 * Load any configuration information and start the core processes.
 */
function main() {
    let conf = loadConfig()
    startCoreProcesses(conf)
}

/*      outcome/
 * Load the configuration (from environment variables) or defaults
 */
function loadConfig() {
    let cfg = {};
    if(process.env.SVC_FOLDER) {
        cfg.SVC_FOLDER = process.env.SVC_FOLDER;
    } else {
        cfg.SVC_FOLDER = "./services";
    }
    return cfg;
}

/*      outcome/
 * The main responsibility of the avatar is to stay running and stable
 * (after all it has to *live forever*). For this to work, it delegates
 * all other work to different processes (a.l.a Erlang's supervisor
 * trees).
 *
 * These core processes include:
 * 1. The Scuttlebot Immortal Feed and Replication
 * 2. A Database for storing working data
 * 3. A Skill Manager for installing, running, and managing skills
 *      - Infrastructure Skills (as hub/as host/...)
 *      - Worker skills (twitter svc, vanity address, ...)
 * 4. A Communication Manager for installing, running, and managing
 * communication channels
      - Telegram channel
      - Messenger channel
      - Alexa channel
      - Web channel
      - ...
 * 5. An AI for understanding and managing user interaction and
 * strategies for earning
 *    - Cakechat (python with microservices relay...)
 *    - ...
 * 6. The stellar blockchain interface for payments, receipts, and smart
 * contracts.
 *
 * The avatar downloads, installs, and starts the core processes.
 *
 * TODO: Monitoring and regulating component CPU/Memory/Disk usage
 */
function startCoreProcesses(cfg) {
    const core_procs = [
        { pkg: "everlifeai/elife-ai" },
        { pkg: "everlifeai/elife-sbot" },
        { pkg: "everlifeai/elife-level-db" },
        { pkg: "everlifeai/elife-skill-mgr" },
        { pkg: "everlifeai/elife-communication-mgr" },
        { pkg: "everlifeai/elife-stellar" },
    ];

    u.showMsg(`Installing core packages...`)
    load_pkgs_1(0, (err) => {
        if(err) {
            u.showErr(err)
            process.exit(1)
        } else {
            u.showMsg(`Starting core functionality...`)
            start_processes_1((err) => {
                if(err) {
                    u.showErr(err)
                    process.exit(2)
                }
            })
        }
    })

    function load_pkgs_1(ndx, cb) {
        if(core_procs.length <= ndx) return cb()
        let pkg = core_procs[ndx].pkg
        u.showMsg(`Loading ${pkg}...`)
        pkgmgr.load(pkg, cfg.SVC_FOLDER, (err, loc) => {
            if(err) cb(err)
            else {
                core_procs[ndx].loc = loc
                load_pkgs_1(ndx+1, cb)
            }
        })
    }

    function start_processes_1(cb) {
        pm2.connect(true, (err) => {
            if(err) cb(err)
            else start_procs_1(0, cb)
        })
    }

    function start_procs_1(ndx, cb) {
        if(core_procs.length <= ndx) return cb()
        let loc = core_procs[ndx].loc
        u.showMsg(`Starting ${loc}...`)
        startProcess(cfg, loc, (err) => {
            if(err) cb(err)
            else start_procs_1(ndx+1, cb)
        })
    }
}

function startProcess(cfg, cwd, cb) {
    let name = path.basename(cwd)
    let lg = path.join(u.logsLoc(), `${name}.log`)
    let opts = {
        name: name,
        script: "index.js",
        cwd: cwd,
        log: lg,
    }
    pm2.start(opts, cb)
}

process.on('SIGINT', () => {
    stopAllChildProcesses()
})

process.on('exit', () => {
    stopAllChildProcesses()
})

function stopAllChildProcesses() {
    pm2.connect(true, (err) => {
        pm2.stop('all')
    })
}

main()
