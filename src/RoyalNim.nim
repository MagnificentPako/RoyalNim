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
     , "./private/fanfictionnet"
     , "./private/epub"
     , "./private/server"


const doc = """
RoyalNim

Usage:
    RoyalNim royalroad <id>
    RoyalNim webnovel.com <id>
    RoyalNim fanfiction.net <id>
    RoyalNim serve

Options:
    - --help    Show this screen.
    --version   Show version.
"""

proc handleScrape(args: auto) =
    var fictionO: Option[Fiction] = none(Fiction)

    if args["royalroad"]:
        let provider = RoyalRoadL()
        fictionO = some(provider.getFiction("$1".format(args["<id>"])))
    elif args["webnovel.com"]:
        let provider = newWebnovelCom()
        fictionO = some(provider.getFiction("$1".format(args["<id>"])))
    elif args["fanfiction.net"]:
        let provider = FanfictionNet()
        fictionO = some(provider.getFiction("$1".format(args["<id>"])))
        
    try:
        let fiction = fictionO.get()
        let doc = newEpub(fiction)
        createDir(fiction.info.title)
        setCurrentDir(fiction.info.title)
        doc.render(fiction.info.title & ".epub")
        echo "Done."
    except:
        echo "FUCK YOU"
        discard

proc main() =
    let args = docopt(doc, version = "RoyalNim 0.1")
    
    if args["serve"]:
        startServer()
    else:
        handleScrape(args)

main()