package = "org.conman.parsers.abnf"
version = "1.0.0-1"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/abnf-1.0.0/abnf.lua"
}

description =
{
  homepage   = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL",
  summary    = "The core BNF ruleset from RFC-5234",
  detailed   = [[
	The core BNF ruleset from RFC-5234.  This is used in a lot of 
	modern RFCs, so it makes sense to break these out.
  ]]
}

dependencies =
{
  "lua",
  "lpeg >= 0.12",
}

build =
{
  type = "none",
  copy_directories = {},
  install =
  {
    lua = 
    {
      ['org.conman.parsers.abnf'] = "abnf.lua"
    }
  }
}
