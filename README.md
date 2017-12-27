# What
A simple tool downloading full novels/fanfictions from different sites. Either for reading them offline or if you simply don't like the site they are distributed on. Has some (IMO) sexy styling so, as long as your reader doesn't fuck with it, expect a good reading experience <3

# Why
I have no idea :^)

# Installation
I assume you know how to install Nim and Nimble for this.

Clone this repo and to `nimble build`. You should get a binary called `RoyalNim` which you could move to some other folder, I strongly encourage you to keep it in the RoyalNim folder though (it searches for the font next to the binary; it also saves the epub in a folder next to the binary). 

Then you can do `RoyalNim <provider> <id>` and it _should_ download the novel. In all cases applicable the _book_ id is meant, not the chapter id.

# Examples
```bash
# Will download "Everybody Loves Large Chests" from RRL
RoyalNim royalroad 8894

# Will download "Release That Witch" from Webnovel.com
RoyalNim webnovel.com 7931338406001705

# Will download "From Outside Eyes" from fanfiction.nmet
RoyalNim fanfiction.net 12660656
```

# Supported sites

- RoyalRoadL
- webnovel.com
- fanfiction.net

# Contribution
Sure, but don't hate me for
- Choosing Nim instead of [insert language here]
- My ugly code
:^)