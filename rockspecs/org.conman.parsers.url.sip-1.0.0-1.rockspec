package = "org.conman.parsers.url.sip"
version = "1.0.0-1"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/urlsip-1.0.0/url/sip.lua"
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license = "LGPL",
  summary = [[Parse "sip:" URLs]],
  detailed = [[
	Parse "sip:" URIs into a Lua table.  This can only handle "sip:"
	URIs.  If you need to parse more than just "sip:" URIs, then you can
	include, for example, "org.conman.parsers.url.url" and merge the
	two:

		sip = require "org.conman.parsers.url.sip"

		url = require "org.conman.parsers.url.url"

		url = sip + url

	It really is that simple.
  	]],
}

dependencies =
{
  "lua",
  "lpeg >= 1.0.1",
  "org.conman.parsers.abnf    >= 1.0.0",
  "org.conman.parsers.ip-text >= 1.0.0",
  "org.conman.parsers.tel     >= 1.0.0",
}

build =
{
  type = "none",
  copy_directories = {},
  install =
  {
    lua =
    {
      ['org.conman.parsers.url.sip'] = "sip.lua"
    }
  }
}
