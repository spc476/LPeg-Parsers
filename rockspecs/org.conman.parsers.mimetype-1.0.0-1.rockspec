package = "org.conman.parsers.mimetype"
version = "1.0.0-1"
rockspec_format = "3.0"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/mimetype-1.0.0/mimetype.lua",
  md5 = "8f00bb5a3c4993dba3e1cdfc5be12631",
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  issues_url = "https://github.com/spc476/LPeg-Parsers/issues",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "Parse a MIME type, which can include parameters.",
  labels     = { 'lpeg' },
  detailed   = [[
	Parse the MIME type from RFC-2045.  This is the MIME type itself,
	not a complete header.
  ]],
}

dependencies =
{
  "lua >= 5.1, <= 5.4",
  "lpeg >= 1.0.0",
}

build =
{
  type = "none",
  copy_directories = {},
  install =
  {
    lua = 
    {
      ['org.conman.parsers.mimetype'] = "mimetype.lua"
    }
  }
}
