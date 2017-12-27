# Package

version       = "0.1.0"
author        = "MagnificentPako"
description   = "RRL scraper"
license       = "MIT"
srcDir        = "src"
bin           = @["RoyalNim"]
skipExt       = @["nim"]

# Dependencies

requires "nim >= 0.17.2"
requires "nimquery >= 1.0.2"
requires "docopt"
requires "colorize"
requires "zip"