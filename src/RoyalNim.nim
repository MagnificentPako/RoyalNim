import httpclient
     , nimquery
     , strutils
     , sequtils
     , docopt
     , xmltree
     , htmlparser
     , streams
     , re
     , os


const doc = """
RoyalNim

Usage:
    RoyalNim chapter <id>
    RoyalNim fiction <id>

Options:
    - --help    Show this screen.
    --version   Show version
"""

const htmlTemplate = """
<html>
    <head>
        <meta charset="utf8">
        <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro" rel="stylesheet"> 
        <style>
            * {
                font-family: "Source Sans Pro", sans-serif;
                background-color: #212121;
                color: #d3d3d3;
            }
            p {
                font-size: 18pt;
            }
            html {
                width: 80%;
                margin-right: 10%;
                margin-left: 10%;
                text-align: justify;
                height: 100%;
            }
            .fiction-content {
                padding: 20px;
                height: 100%;
            }
            .chapter-title {
                font-size: 22pt;
                color: #b381b3;
            }
            .fiction-title, .fiction-author {
                color: #f4b350;
                padding: 8px;
                padding-left: 0;
            .fiction-author {
                padding-left: 16px;
            }
            }
        </style>
    </head>
    <body>
    <div class="fiction-container">
    <span style="display: inline-block;">
    <h1 class="fiction-title" style="display: inline;">$1</h1> by 
    <h2 class="fiction-author" style="display: inline;">$2</h2></span>

        $3
    </div>
    </body>
</html>
"""

const chapterTemplate = """
<div class="chapter">
    <h2 class="chapter-title">$1</h2>
    $2
</div>
"""

type Chapter = tuple
    title: string
    content: string
    id: string

type Fiction = tuple
    title: string
    author: string
    chapters: seq[Chapter]

proc getChapter(id: string): Chapter =
    let client = newHttpClient()
    let url = "http://royalroadl.com/fiction/chapter/$1".format(id)
    let xml = parseHtml( newStringStream(client.getContent(url)))
    let chapter_content = xml.querySelector(".chapter-content")
    let chapter_title   = xml.querySelector("div .col-md-5 > h1")
    echo "Downloaded chapter \"$1\"" % chapter_title.innerText()
    httpclient.close(client)
    result = (title: chapter_title.innerText(), content: $chapter_content, id: id)

proc getFiction(id: string): Fiction =
    let client = newHttpClient()
    let url = "http://royalroadl.com/fiction/$1".format(id)
    let xml = parseHtml(newStringStream(client.getContent(url)))
    let author = xml.querySelector("span[property='name']").innerText()
    let title  = xml.querySelector("h1[property='name']").innerText()
    echo "Downloading \"$1\" by \"$2\"" % [title, author]
    let chapters = xml.querySelectorAll("tbody > tr").map(proc(a: XmlNode): string = 
        var matches: array[1, string]
        let curl = a.attr "data-url"

        if curl.match(re"^/fiction/.+/.+/chapter/(.+)/.+$", matches, 0):
            result = matches[0]
        else:
            result = ""
    )
    httpclient.close(client)
    result = ( title: title
             , author: author
             , chapters: chapters.map(proc(a: string): Chapter = getChapter(a))
             )

proc main() =
    let args    = docopt(doc, version = "RoyalNim 0.1")
    if args["chapter"]:
        echo "no"
    
    if args["fiction"]:
        let fiction = getFiction("$1".format(args["<id>"]))
        createDir(fiction.title)
        setCurrentDir(fiction.title)
        var chapterOut = ""
        for chapter in fiction.chapters:
            chapterOut &= chapterTemplate.format(chapter.title, chapter.content)
        chapterOut = chapterOut.replace("nbsp&", " ").replace("amp;", " ")
        let handle = open("raw.html", fmWrite)
        write(handle, htmlTemplate.format(fiction.title, fiction.author, chapterOut))
        close(handle)
        discard execShellCmd("wkhtmltopdf $2 raw.html \"$1.pdf\"".format( fiction.title
                                                               , "-B 0 -L 0 -R 0 -T 0 --no-outline"
                                                               ))
        echo "Done."

main()