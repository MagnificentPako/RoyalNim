import httpclient
     , ./provider
     , xmltree
     , htmlparser
     , streams
     , strutils
     , nimquery
     , sequtils
     , re

const fanficUrl  = "https://www.fanfiction.net/s/$1"
const chapterUrl = "https://www.fanfiction.net/s/$1/$2" 

type FanfictionNet* = ref object of Provider

method getFictionInfo*(this: FanfictionNet, fictionId: string): FictionInfo =
    let client = newHttpClient()
    defer: close(client)
    let mainContent = client.getContent(fanficUrl % [fictionId])
    let mainDoc = parseHtml(newStringStream(mainContent))
    let title = mainDoc.querySelector("#profile_top > b").innerText()
    let author = mainDoc.querySelector("#profile_top > a").innerText()
    let fictionInfo: FictionInfo = (title: title, author: author, chapters: @[])
    this.onFiction(fictionInfo)
    result = fictionInfo

method getChapter*(this: FanfictionNet, fictionId: string, chapterId: string): Chapter =
    let client = newHttpClient()
    defer: close(client)
    let content = client.getContent(chapterUrl % [fictionId, chapterId])
    let doc = parseHtml(newStringStream(content))
    if content.find("id='storytext'") != -1:
        let chapterContent = $doc.querySelectorAll("#storytext > p")
        var chapSelect     = doc.querySelectorAll("#chap_select > option").filter(proc(a: auto): bool = 
            a.innerText().find("selected>") != -1
        )
        let chapSel = chapSelect.pop()
        let chapter        = (title: chapSel.innerText().replace("selected>", ""), content: chapterContent, id: chapSel.attr("value"))
        this.afterChapter(chapter)
        result = chapter
    else:
        result = (title: "", content: "", id: "")

method getFiction*(this: FanfictionNet, fictionId: string): Fiction =
    let info = this.getFictionInfo(fictionId)
    var chapters: seq[Chapter] = @[]
    var chapId = 1
    var chap = this.getChapter(fictionId, "1")
    while(chap.content != ""):
        chapters.add(chap)
        chap = this.getChapter(fictionId, intToStr(chapId))
        chapId += 1
    return (info: info, chapters: chapters)