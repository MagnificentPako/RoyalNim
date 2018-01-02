import httpclient
     , ./provider
     , xmltree
     , htmlparser
     , streams
     , strutils
     , nimquery
     , sequtils
     , re

type 
    RoyalRoadL* = ref object of Provider

method getFictionInfo*(this: RoyalRoadL, id: string): FictionInfo =
    let client = newHttpClient()
    defer: client.close()
    let url = "http://royalroadl.com/fiction/$1".format(id)
    let xml = parseHtml(newStringStream(client.getContent(url)))
    let author = xml.querySelector("span[property='name']").innerText()
    let title  = xml.querySelector("h1[property='name']").innerText()

    let chapters = xml.querySelectorAll("tbody > tr").map(proc(a: XmlNode): string = 
        var matches: array[1, string]
        let curl = a.attr "data-url"

        if curl.match(re"^/fiction/.+/.+/chapter/(.+)/.+$", matches, 0):
            result = matches[0]
        else:
            result = ""
    )

    let fictionInfo = (title: title, author: author, chapters: chapters)
    this.onFiction(fictionInfo)
    result = fictionInfo

method getChapter*(this: RoyalRoadL, id: string): Chapter =
    let client = newHttpClient()
    let url = "http://royalroadl.com/fiction/chapter/$1".format(id)
    let xml = parseHtml( newStringStream(client.getContent(url)))
    let chapter_content = xml.querySelector(".chapter-content")
    let chapter_title   = xml.querySelector("div .col-md-5 > h1")
    let chapter = (title: chapter_title.innerText(), content: $chapter_content, id: id)
    this.afterChapter(chapter)
    httpclient.close(client)
    result = chapter

method getFiction*(this: RoyalRoadL, id: string): Fiction =
    let client = newHttpClient()
    defer: client.close()

    let info = this.getFictionInfo(id)

    result = ( info: info
             , chapters: info.chapters.map(proc(a: string): Chapter = this.getChapter(a))
             )