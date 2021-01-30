package = "org.conman.parsers.url.gopher"
version = "2.0.0-3"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/urlgopher-2.0.0/url/gopher.lua",
  md5 = "072ac6a2f1b8370128a1c0bdfd80ec66",
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license = "LGPL3+",
  summary = [[Parse "gopher:" URLs]],
  detailed = [[
	Parse "gopher:" URLs into a Lua table.  This can only handle
	"gopher:" URLs.  If you need to parse more than just "gopher:" URLs,
	then you can include, for example, "org.conman.parsers.url.url" and
	merge the two:

		gopher = require "org.conman.parsers.url.gopher"

		url = require "org.conman.parsers.url.url"

		url = gopher + url

	It really is that simple.
  	]],
}

dependencies =
{
  "lua >= 5,1, <= 5.4",
  "lpeg >= 1.0.0",
  "org.conman.parsers.abnf >= 1.0.0",
  "org.conman.parsers.ip-text >= 1.0.0",
  "org.conman.const.gopher-types >= 1.0.0",
}

build =
{
  type = "none",
  copy_directories = {},
  install =
  {
    lua =
    {
      ['org.conman.parsers.url.gopher'] = "gopher.lua"
    }
  }
}
