const fs = require('fs')
const path = require('path')
const showdown = require('showdown')

const converter = new showdown.Converter()
converter.setFlavor('github')
converter.setOption('simpleLineBreaks', false)
converter.setOption('completeHTMLDocument', true)

/*      outcome/
 * Read all the `.md` files in the current directory and convert them to
 * HTML.
 */
function makeDocs() {
    fs.readdir('.', (err, files) => {
        if(err) console.error(err)
        else {
            let mds = files.filter((f) => path.extname(f) == '.md')
            mds.forEach(md2Html)
        }
    })
}

/*      outcome/
 * Read a Markdown file and convert it to an equivalent HTML markup.
 * Convert this into a valid HTML file and write it out.
 * using the markdown parser and converting any local `.md` links to
 * `.html`.
 */
function md2Html(md) {
    let name = md.replace(/\.md$/, '')
    let html = name + '.html'
    fs.readFile(md, 'utf8', (err, data) => {
        if(err) console.error(err)
        else {
            let o = converter.makeHtml(data)
            fs.writeFile(html, convert_to_html_1(o), (err) => {
                if(err) console.error(err)
                else console.log(`Generated ${html}`)
            })
        }
    })

    /*      outcome/
     * Convert the markup into HTML by converting links from markdown
     * files to HTML, adding the head, CSS, etc
     */
    function convert_to_html_1(mu) {
        let o = mu.replace(/href="(.*)\.md"/g, 'href=$1.html')
        let html = `
<!doctype html>
<html>
<head>
<title>${name}</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="github-markdown.css">
<style>
    .markdown-body {
        box-sizing: border-box;
        min-width: 200px;
        max-width: 980px;
        margin: 0 auto;
        padding: 45px;
        padding-top: 15px;
    }

    @media (max-width: 767px) {
        .markdown-body {
            padding: 15px;
        }
    }
</style>
</head>
<body class="markdown-body">
${o}
</body>
</html>
`
        return html
    }
}

makeDocs()
