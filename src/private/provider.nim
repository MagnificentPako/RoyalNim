import colorize
     , strutils
     , json

type Chapter* = tuple
    title: string
    content: string
    id: string

type FictionInfo* = tuple
    title: string
    author: string
    chapters: seq[string]

type Fiction* = tuple
    info: FictionInfo
    chapters: seq[Chapter]

type 
    Provider* = ref object of RootObj

proc infoToJson*(info: FictionInfo): string =
    let jsonResponse = %*
                                {"title": info.title, "author": info.author, "chapters": info.chapters}
    var body = ""
    toUgly(body, jsonResponse)
    result = body

proc chapterToJson*(chapter: Chapter): string =
    let jsonResponse = %*
                                {"title": chapter.title, "content": chapter.content}
    var body = ""
    toUgly(body, jsonResponse)
    result = body

method afterChapter*(this: Provider, chapter: Chapter) {.base.} = 
    echo("Downloading ".fgGreen & "chapter " & ("\"$1\"" % chapter.title).fgLightMagenta)

method onFiction*(this: Provider, fiction: FictionInfo) {.base.} =
    echo("Downloading ".fgGreen & "\"$1\"".format(fiction.title).fgLightBlue & " by " & "\"$1\"".format(fiction.author).fgLightRed)

method getChapter*(this: Provider): Chapter {.base.} = (title: "", content: "", id: "")
method getFiction*(this: Provider): Fiction {.base.} = (info: (title: "", author: "", chapters: @[]), chapters: @[this.getChapter()])
method getFictionInfo*(this: Provider): FictionInfo {.base} = (title: "", author: "", chapters: @[])