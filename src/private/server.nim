import jester, json, asyncdispatch, ./provider, ./royalroad, ./webnovel, ./fanfictionnet

let RRL = RoyalRoadL()
let WNC = newWebnovelCom()
let FFN = FanfictionNet()

proc startServer*() =
    routes:
        # RRL

        # general info about novel
        get "/rrl/@id":
            let info = RRL.getFictionInfo(@"id")
            resp infoToJson(info)

        # get a chapter
        get "/rrl/@bid/chapter/@cid":
            let chapter = RRL.getChapter(@"cid")
            resp chapterToJson(chapter)

        # WEBNOVEL
        get "/webnovel/@id":
            let info = WNC.getFictionInfo(@"id")
            resp infoToJson(info)

        get "/webnovel/@bid/chapter/@cid":
            let chapter = WNC.getChapter(@"bid", @"cid")
            resp chapterToJson(chapter)

        # FANFICTION.NET
        get "/ffn/@id":
            let info = FFN.getFictionInfo(@"id")
            resp infoToJson(info)

        get "/ffn/@bid/chapter/@cid":
            let chapter = FFN.getChapter(@"bid", @"cid")
            resp chapterToJson(chapter)

    runForever()