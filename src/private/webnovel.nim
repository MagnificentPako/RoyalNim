import httpclient
     , xmltree
     , htmlparser
     , streams
     , strutils
     , nimquery
     , sequtils
     , re
     , options
     , json
     , tables
     , cookies
     , strtabs
     , ./provider

const mainurl    = "https://www.webnovel.com"
const chapterUrl = "https://www.webnovel.com/apiajax/chapter/GetChapterList?_csrfToken=$1&bookId=$2"
const contentUrl = "https://www.webnovel.com/apiajax/chapter/GetContent?_csrfToken=$1&bookId=$2&chapterId=$3"

type 
    WebnovelCom* = ref object of Provider
        csrf: string

proc newWebnovelCom*(): WebnovelCom =
    new result
    let client = newHttpClient()
    let res = client.get(mainurl)
    close(client)
    let cookies = parseCookies(res.headers.table["set-cookie"].foldl(a & "\n" & b))
    result.csrf = cookies["_csrfToken"]

method getChapter*(this: WebnovelCom, bookId: string, chapterId: string): Chapter =
    let client = newHttpClient()
    let data = parseJson(client.getContent(contentUrl % [this.csrf, bookId, chapterId]))

    let title   = data["data"]["chapterInfo"]["chapterName"].getStr()
    let id      = data["data"]["chapterInfo"]["chapterId"].getStr()
    var content = data["data"]["chapterInfo"]["content"].getStr()
    content = "<p>$1</p>" % (content.replace("\r\n", "</p><p>"))

    let chapter: Chapter = (title: title, content: content, id: id)
    this.afterChapter(chapter)

    close(client)

    result = chapter

method getFiction*(this: WebnovelCom, bookId: string): Fiction = 
    let client = newHttpClient()
    let data = parseJson(client.getContent(chapterUrl % [this.csrf, bookId]))

    let chapters = data["data"]["chapterItems"].getElems()
    let title = data["data"]["bookInfo"]["bookName"].getStr()
    let author = parseJson(client.getContent(contentUrl % [this.csrf, bookId, chapters[0]["chapterId"].getStr()]))["data"]["bookInfo"]["authorName"].getStr()

    let fictionInfo = (title: title, author: author)

    this.onFiction(fictionInfo)

    result = (info: fictionInfo, chapters: chapters.map( proc(a: auto): Chapter =
        result = this.getChapter(bookId, a["chapterId"].getStr())    
    ))