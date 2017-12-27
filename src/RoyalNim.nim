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
     , options
     , "./private/provider"
     , "./private/royalroad"
     , "./private/webnovel"


const doc = """
RoyalNim

Usage:
    RoyalNim royalroad <id>
    RoyalNim webnovel.com <id>

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

proc main() =
    let args = docopt(doc, version = "RoyalNim 0.1")
    
    var fictionO: Option[Fiction] = none(Fiction)

    if args["royalroad"]:
        let provider = RoyalRoadL()
        fictionO = some(provider.getFiction("$1".format(args["<id>"])))
    elif args["webnovel.com"]:
        let provider = newWebnovelCom()
        fictionO = some(provider.getFiction("$1".format(args["<id>"])))
        
    try:
        let fiction = fictionO.get()
        createDir(fiction.info.title)
        setCurrentDir(fiction.info.title)
        var chapterOut = ""
        for chapter in fiction.chapters:
            chapterOut &= chapterTemplate.format(chapter.title, chapter.content)
        chapterOut = chapterOut.replace("nbsp&", " ").replace("amp;", " ")
        let handle = open("raw.html", fmWrite)
        write(handle, htmlTemplate.format(fiction.info.title, fiction.info.author, chapterOut))
        close(handle)
        discard execShellCmd("wkhtmltopdf $2 raw.html \"$1.pdf\"".format( fiction.info.title
                                                               , "-B 0 -L 0 -R 0 -T 0 --no-outline"
                                                               ))
        echo "Done."
    except:
        echo "FUCK YOU"
        discard

main()