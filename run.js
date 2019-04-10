'use strict'
const shell = require('shelljs')
const path = require('path')
const cla = require('command-line-args')
const u = require('elife-utils')
const shortid = require('shortid')

/*      understand/
 * Main entry point for our program
 */
function main() {
    let args = getArgs()
    if(args.help) showHelp()
    else if(args['info']) showInfo()
    else if(args['gui']) launchGUI()
    else if(args['rm-node-modules']) removeNodeModules()
    else if(args['rm-yarn-lock']) removeYarnLock()
    else {
        checkForRequiredInstalls()
        setupAvatarComponents()
        setupEnvironmentVariables(args)
        setupHomeFolders()
        setupWallet()
        setupUserConfig()
        startAvatar()
    }
}

function getArgs() {
    const ops = [
        { name: 'help', alias: 'h', type: Boolean },
        { name: 'gui', alias: 'g', type: Boolean },
        { name: 'info', alias: 'i', type: Boolean },
        { name: 'rm-node-modules', type: Boolean },
        { name: 'rm-yarn-lock', type: Boolean },
        { name: 'node-num', alias: 'n' },
    ]

    return cla(ops)
}

function showHelp() {
    shell.echo(`Start avatar node

    --info,i    : Show information about the installed avatar
    --gui,g     : Run the default GUI client (QWERT)

Also accepts the following options (usually for devs)
    --rm-node-modules   : Remove all node modules
    --rm-yarn-lock      : Remove all yarn locks

    --node-num=x, -n x  : Start as node number 'x'

    --help, -h          : show this help
`)
}

function showInfo() {
    const { version } = require('./package.json')
    shell.echo(`Avatar node (version ${version})`)
    shell.echo(`Installed in:`)
    shell.echo(`    ${shell.pwd()}`)
    shell.echo(`Data stored in: (BACKUP THIS FOLDER)`)
    shell.echo(`    ${u.dataLoc()}`)
}

function launchGUI() {
    let r

    r = shell.pushd('-q', 'qwert')
    if(r.code) {
        shell.echo('Failed to enter qwert/ directory')
        shell.exit(1)
    }

    r = shell.exec(`yarn start`)
    if(r.code) {
        shell.echo(`Failed to run 'yarn start' in qwert/ directory`)
    }

    shell.popd('-q')
}

function removeNodeModules() {
    let structure = avatarStructure()
    for(let i = 0;i < structure.length;i++) {
        let loc
        if(structure[i].required) loc = structure[i].required
        if(structure[i].optional) loc = structure[i].optional
        if(loc) {
            let nm = path.join(loc, 'node_modules')
            if(shell.test("-d", nm)) {
                shell.echo(`Removing ${nm}`)
                let r = shell.rm("-rf", nm)
                if(r.code) shell.echo(`Failed to remove ${nm}`)
            }
        }
    }
}

function removeYarnLock() {
    let structure = avatarStructure()
    for(let i = 0;i < structure.length;i++) {
        let loc
        if(structure[i].required) loc = structure[i].required
        if(structure[i].optional) loc = structure[i].optional
        if(loc) {
            let yl = path.join(loc, 'yarn.lock')
            if(shell.test("-f", yl)) {
                shell.echo(`Removing ${yl}`)
                let r = shell.rm(yl)
                if(r.code) shell.echo(`Failed to remove ${yl}`)
            }
        }
    }
}

function checkForRequiredInstalls() {
    if(!shell.which('yarn')) {
        shell.echo('Please install the yarn package manager to run the Everlife Avatar')
        shell.exit(1)
    }
}

/*      outcome/
 * The structure of the avatar node - required repos, additional
 * directories, and optional repos.
 */
function avatarStructure() {
    return [
        { required: "qwert" },

        { dir: "services" },

        { required: "services/elife-ai" },
        { dir: "services/elife-ai/brains" },
        { required: "services/elife-ai/brains/ebrain-aiml" },
        { required: "services/elife-ai/brains/ebrain-aiml/aiml" },

        { required: "services/elife-level-db" },

        { required: "services/elife-stellar" },

        { required: "services/elife-sbot", postInstall: "node fixAppKey" },

        { required: "services/elife-communication-mgr" },
        { dir: "services/elife-communication-mgr/channels" },
        { required: "services/elife-communication-mgr/channels/elife-telegram" },
        { required: "services/elife-communication-mgr/channels/elife-qwert" },

        { required: "services/elife-skill-mgr" },
        { dir: "services/elife-skill-mgr/skills" },
        { required: "services/elife-skill-mgr/skills/eskill-intro" },
        { required: "services/elife-skill-mgr/skills/eskill-about" },
        { required: "services/elife-skill-mgr/skills/eskill-follower" },

        { optional: "services/elife-skill-mgr/skills/eskill-vanity-address" },
        { optional: "services/elife-skill-mgr/skills/eskill-kb-creator" },
        { optional: "services/elife-skill-mgr/skills/eskill-direct-message" },
        { optional: "services/elife-skill-mgr/skills/eskill-ai-artist" },
        { optional: "services/elife-skill-mgr/skills/eskill-coupon" },
    ]
}

/*      outcome/
 * Set up the various avatar components needed (required and optional)
 * in the correct directory structures.
 */
function setupAvatarComponents() {
    let structure = avatarStructure()
    for(let i = 0;i < structure.length;i++) {
        let s = structure[i]
        if(s.required) if(!install(s)) return false
        if(s.dir) if(!mkdir(s.dir)) return false
        if(s.optional) install(s)
    }

    return true
}


/*      outcome/
 * Set up the environment variables so all the sub-components can access
 * them (the home location and the node number and setup COTEJS
 * partition environment variable
 */
function setupEnvironmentVariables(args) {
    shell.env['ELIFE_HOME'] = u.homeLoc()
    let nn = "0"
    if(args['node-num']) nn = args['node-num']
    if(isNaN(parseInt(nn))) {
        shell.echo(`node-num ${nn} is not a valid integer`)
        shell.exit(1)
    }
    shell.env["ELIFE_NODE_NUM"] = nn
    shell.env['COTE_ENV'] = partitionParam()
}

/*      understand/
 * Cote.js has a automated discovery service that allows it to find
 * matching microservices anywhere on the network that share the same
 * 'environment' parameter.
 *
 *      problem/
 * We do not want nodes that are near each other (on the same machine or
 * on the same network) to start responding to each other's microservice
 * requests.
 *
 *      way/
 * We returns reasonably-unique identifier that we can use to partition
 * cote.js microservice environments and prevent nodes from interfering
 * with each other.
 */
function partitionParam() {
    return shortid.generate()
}

/*      outcome/
 * Create the data and skill folders
 */
function setupHomeFolders() {
    mkdir(u.dataLoc())
    mkdir(u.skillLoc())
}

/*      outcome/
 * If we don't have a luminate password saved, get the user to add one
 * now.
 */
function setupWallet() {
    let p = path.join(u.dataLoc(), ".luminate-pw")
    if(shell.test("-f", p)) return

    let stellardir = "services/elife-stellar"
    shell.echo(`
===========================================================
Please go to "${stellardir}" and run
    node pw
to set up your avatar's wallet password before you continue
===========================================================
`)
    shell.exit(1)
}

/*      outcome/
 * If the user configuration file does not exist, create a template that
 * they can fill in.
 */
function setupUserConfig() {
    let cfg = path.join(u.dataLoc(), 'cfg.env')
    if(shell.test("-f", cfg)) return

    shell.echo(`\n\nCreating configuration file...`)
    shell.echo(`#       understand/
# We use environment variables to configure various skills and services.
# In order to pass the information to the required components we need to
# set them in this file.

# For Telegram Channel
TELEGRAM_TOKEN=

# For what-wine skill
MASHAPE_KEY=

# for AI Artist Skill
AIARTIST_HOST=
AIARTIST_PORT=
`).to(cfg)
    shell.echo(`Please edit this file: ${cfg}`)
    shell.echo(`To add your own TELEGRAM_TOKEN, etc...\n\n`)
}

function mkdir(d) {
    let r = shell.mkdir('-p', d)
    if(r.code) {
        shell.echo(`Failed to create directory: ${d}`)
        return false
    }
    return true
}

function install(what) {
    if(!what.required && !what.optional) return false
    let repo = what.required ? what.required : what.optional

    let type_ = what.required ? 'required' : 'optional'
    shell.echo(`Checking ${type_}: ${repo}`)

    if(!createRepo(repo)) return false
    if(!setupRepo(repo, what.postInstall)) return false

    return true
}

/*      outcome/
 * Checks if the repo exists otherwise goes to the directory path and
 * downloads it
 */
function createRepo(rp) {
    if(shell.test("-d", rp)) return true
    shell.echo(`Creating: ${rp}`)

    let dir = path.dirname(rp)
    let repo = path.basename(rp)

    let r

    r = shell.pushd('-q', dir)
    if(r.code) {
        shell.echo(`Failed to change directory to: ${dir}`)
        shell.popd('-q')
        return false
    }

    r = shell.exec(`git clone git@github.com:everlifeai/${repo}.git`)
    if(r.code) {
        shell.echo(`Failed to download git repo: ${repo}`)
        shell.popd('-q')
        return false
    }

    r = shell.popd('-q')
    if(r.code) {
        shell.echo(`Failed to return to base directory from creating repo: ${repo}`)
        return false
    }

    return true
}

/*      outcome/
 * Set up the node_modules and run any post install scripts
 */
function setupRepo(rp, postInstall) {
    if(shell.test("-d", path.join(rp,'node_modules'))) return true
    if(!shell.test("-f", path.join(rp,'package.json'))) return true
    shell.echo(`Setting up: ${rp}`)

    let r

    r = shell.pushd('-q', rp)
    if(r.code) {
        shell.echo(`Failed to change directory to: ${rp}`)
        return false
    }

    r = shell.exec(`yarn install`)
    if(r.code) {
        shell.echo(`Failed to yarn install in: ${rp}`)
        shell.popd('-q')
        return false
    }

    if(postInstall) {
        shell.echo(`Running post-install: ${postInstall}`)
        r = shell.exec(postInstall)
        if(r.code) {
            shell.echo(`Failed to run post-install: ${postInstall}`)
            shell.popd('-q')
            return false
        }
    }

    r = shell.popd('-q')
    if(r.code) {
        shell.echo(`Failed to return to base directory after setting up: ${rp}`)
        return false
    }

    return true
}

function startAvatar() {
    shell.exec(`yarn start`)
}

main()
