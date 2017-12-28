import colorize
     , strutils

type Chapter* = tuple
    title: string
    content: string
    id: string

type FictionInfo* = tuple
    title: string
    author: string

type Fiction* = tuple
    info: FictionInfo
    chapters: seq[Chapter]

type 
    Provider* = ref object of RootObj

method afterChapter*(this: Provider, chapter: Chapter) {.base.} = 
    echo("Downloading ".fgGreen & "chapter " & ("\"$1\"" % chapter.title).fgLightMagenta)

method onFiction*(this: Provider, fiction: FictionInfo) {.base.} =
    echo("Downloading ".fgGreen & "\"$1\"".format(fiction.title).fgLightBlue & " by " & "\"$1\"".format(fiction.author).fgLightRed)

method getChapter*(this: Provider): Chapter {.base.} = (title: "", content: "", id: "")
method getFiction*(this: Provider): Fiction {.base.} = (info: (title: "", author: ""), chapters: @[this.getChapter()])