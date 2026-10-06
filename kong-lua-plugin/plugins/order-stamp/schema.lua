local typedefs = require "kong.db.schema.typedefs"

return {
  name = "order-stamp",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { header_name = { type = "string", default = "X-Order-Stamp" } },
          { message = { type = "string", required = true } },
        },
    } },
  },
}
