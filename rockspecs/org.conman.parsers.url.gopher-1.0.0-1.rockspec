package = "org.conman.parsers.url.gopher"
version = "1.0.0-1"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/urlgopher-1.0.0/url/gopher.lua"
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license = "LGPL",
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
  "lua",
  "lpeg >= 1.0.1",
  "org.conman.parsers.abnf >= 1.0.0",
  "org.conman.parsers.ip-text >= 1.0.0",
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
