
local typedefs      = require "kong.db.schema.typedefs"

return {
  name = "backend-token-creation",
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { server_url = { type = "string", required = true }, },
          { client_id = { type = "string", required = true }, },
          { client_secret = { type = "string", required = false }, },
          { scope = { type = "string", required = false }, },
        },
    }, },
  },
}