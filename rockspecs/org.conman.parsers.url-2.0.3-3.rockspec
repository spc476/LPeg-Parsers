package = "org.conman.parsers.url"
version = "2.0.3-3"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/url-2.0.3/url.lua",
  md5 = "e34da71c02b01331854804c7f5558e91",
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license = "LGPL3+",
  summary = [[Parse "http:", "https:", "file:" and "ftp:" URLs]],
  detailed = [[
  	Parse "http:", "https:", "file:" and "ftp:" URLs into a Lua table. 
  	It can handle other URLs but further processing may be required if
  	so.
  	]],
}

dependencies =
{
  "lua >= 5.1, <= 5.4",
  "lpeg >= 1.0.0",
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
      ['org.conman.parsers.url'] = "url.lua"
    }
  }
}
