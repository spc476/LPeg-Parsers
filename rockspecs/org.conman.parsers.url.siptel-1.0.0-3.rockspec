package = "org.conman.parsers.url.siptel"
version = "1.0.0-3"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/urlsiptel-1.0.0/url/siptel.lua",
  md5 = "4ef7aa192765be6d33b8af08bbfc3205",
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license = "LGPL3+",
  summary = [[Parse sip:, sips: and tel: URIs]],
  detailed = [[
	Parse sip:, sips: and tel: URIs into a Lua table.  Given that the
	two are intertwined semantically, both are included in this module. 
	]],
}

dependencies =
{
  "lua >= 5,1, <= 5.4",
  "lpeg >= 1.0.0",
  "org.conman.parsers.abnf    >= 1.0.0",
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
      ['org.conman.parsers.url.siptel'] = "siptel.lua"
    }
  }
}
