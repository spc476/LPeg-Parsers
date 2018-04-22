package = "org.conman.parsers.url.tel"
version = "1.0.0-2"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/urltel-1.0.0/url/tel.lua"
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license = "LGPL",
  summary = [[Parse "tel:" URLs]],
  detailed = [[
	Parse "tel:" URIs into a Lua table.  This can only handle "tel:"
	URIs.  If you need to parse more than just "tel:" URIs, then you can
	include, for example, "org.conman.parsers.url.url" and merge the
	two:

		tel = require "org.conman.parsers.url.tel"

		url = require "org.conman.parsers.url.url"

		url = tel.tel + url

	It really is that simple.
  	]],
}

dependencies =
{
  "lua",
  "lpeg >= 1.0.1",
  "org.conman.parsers.abnf >= 1.0.0",
}

build =
{
  type = "none",
  copy_directories = {},
  install =
  {
    lua =
    {
      ['org.conman.parsers.url.tel'] = "tel.lua"
    }
  }
}
