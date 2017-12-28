import zip/zipfiles
     , os
     , osproc
     , streams
     , xmltree
     , strtabs
     , nuuid
     , times
     , strutils
     , sequtils
     , ./provider

const css = """

@font-face {
    font-family: "Source Sans Pro";
    font-weight: normal;
    font-style: normal;
    src: url("ssp.otf");
}

* {
    background-color: #212121;
    color: #d3d3d3;
    font-family: "Source Sans Pro", sans-serif;
}
.chapter-title, a {
color: #b381b3;
}
.fiction-title, .fiction-author {
color: #f4b350;
padding: 8px;
padding-left: 0;
}
.fiction-author {
padding-left: 16px;
}

"""

type ChapterNameAssoc = tuple
    title: string
    file: string

type Epub* = ref object of RootObj
    fiction: Fiction
    uuid: string

proc newEpub*(fiction: Fiction): Epub =
    new result
    result.fiction = fiction
    result.uuid   = generateUUID()

method container(this: Epub): string =
    result = """<?xml version="1.0" encoding="UTF-8"?>
    <container
      xmlns="urn:oasis:names:tc:opendocument:xmlns:container"
      version="1.0">
      <rootfiles>
        <rootfile
          full-path="content.opf"
          media-type="application/oebps-package+xml"/>
      </rootfiles>
    </container>
    """

method content(this: Epub): string {.base.} =
    var i = 0
    var names: seq[ChapterNameAssoc] = @[]
    for ch in this.fiction.chapters.items():
        names.add((title: ch.title, file: "chapter" & intToStr(i)))
        i += 1
    result = """<?xml version="1.0" encoding="UTF-8"?>
    <package version="3.0"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:opf="http://www.idpf.org/2007/opf"
      xmlns="http://www.idpf.org/2007/opf"
      unique-identifier="Id">
      <metadata>
        <dc:identifier id="Id">$1</dc:identifier>
        <meta property="dcterms:modified">$2</meta>
        <dc:language>en</dc:language>
        <dc:title xml:lang="en">$3</dc:title>

      </metadata>
      <manifest>
        <item id="ssp" href="ssp.otf" media-type="application/vnd.ms-opentype" />
        <item id="style" href="style.css" media-type="text/css" />
        <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
        $4
      </manifest>
      <spine>
        <itemref idref="nav"/>
        $5
      </spine>
    </package>
    """ % [ generateUUID()
          , getTime().getLocalTime().format("yyyy-MM-dd'T'hh:mm:ss'Z'")
          , this.fiction.info.title
          , names.foldl(a & "<item id=\"" & b.file & "\" href=\"" & b.file & ".xhtml\" media-type=\"application/xhtml+xml\" />", "")
          , names.foldl(a & "<itemref idref=\"" & b.file & "\" />", "")
          ]

method nav(this: Epub): string =
    var i = 0
    var names: seq[ChapterNameAssoc] = @[]
    for ch in this.fiction.chapters.items():
        names.add((title: ch.title, file: "chapter" & intToStr(i)))
        i += 1
    result = """<?xml version="1.0" encoding="UTF-8" ?>
    <html xmlns="http://www.w3.org/1999/xhtml"
          xmlns:ops="http://www.idpf.org/2007/ops"
          xml:lang="en">
      <head>
        <title>ToC</title>
        <link href="style.css" rel="stylesheet" type="text/css" />
      </head>
      <body>
       <nav ops:type="toc">
        <h1 class="fiction-title">$1</h1>
        <ol>
          <li><a href="nav.xhtml">Toc</a></li>
          $3
        </ol>
    
      </nav>
     </body>
    </html>
    """ % [this.fiction.info.title, this.fiction.info.author, names.foldl(a & "<li><a href=\"" & b.file & ".xhtml\">" & b.title & "</a></li>", "") ]

method generateChapter(this: Epub, chapter: Chapter): string =
        """<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:ops="http://www.idpf.org/2007/ops"
      xml:lang="en">
  <head>
    <title>$1</title>
    <link href="style.css" rel="stylesheet" type="text/css" />
  </head>
  <body>
    <section ops:type="chapter">
      <h2 class="chapter-title">$1</h2>
      $2
    </section>
  </body>
</html>
        """ % [chapter.title, chapter.content]

method render*(this: Epub, path: string) {.base.} =
    var archive: ZipArchive
    discard archive.open(getCurrentDir() / path, fmWrite)
    archive.addFile("mimetype", newStringStream "application/epub+zip")
    archive.addFile("META-INF/container.xml", newStringStream(this.container))
    archive.addFile("content.opf", newStringStream(this.content))
    archive.addFile("nav.xhtml", newStringStream(this.nav))
    archive.addFile("ssp.otf", "../ssp.otf")
    archive.addFile("style.css", newStringStream css)
    var i = 0
    for ch in this.fiction.chapters.items():
        let name = "chapter" & intToStr(i)
        archive.addFile(name & ".xhtml", newStringStream this.generateChapter(ch))
        i += 1

    archive.close