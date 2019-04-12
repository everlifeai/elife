/* CoteJS Connection Checker */
'use strict'
const shell = require('shelljs')
const shortid = require('shortid')

/*      problem/
 * Many firewalls block cotejs connection mechanisms
 * and therefore the avartar will not work.
 *
 *      way/
 * We check if we can make a simple CoteJS connection
 * and, if we can, we exit so the user can proceed.
 * Otherwise (if it's taking a while), we show the user
 * a helpful message so they know what to do.
 */
function main() {
    shell.echo(`\n\nChecking Cote.js connection...`)

    setTimeout(() => {
        shell.echo(`
If this test does not exit then the microservices layer
is blocked and the Avatar's components will not be able
to communicate with each other.
In order to continue you need to configure your firewall
to allow the avatar's communication to work`)
    }, 3000)


    checkCoteConnection(() => {
        shell.echo('CoteJS Connection check passed - ok!')
    })
}

function checkCoteConnection(cb) {
    shell.env['COTE_ENV'] = shortid.generate()
    const cote = require('cote')({statusLogsEnabled:false})

    const resp = new cote.Responder({
        name: 'Cote Connection Check',
        key: 'everlife-cote-check',
    })
    resp.on('check', (req, cb) => {
        cb('ok')
    })

    const req = new cote.Requester({
        name: 'Cote Check Client',
        key: 'everlife-cote-check',
    })
    req.send({ type: 'check' }, (r) => {
        if(r == 'ok') cb()
        shell.exit()
    })
}

main()
