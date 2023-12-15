local kong = kong
local cjson = require "cjson"
local http = require "resty.http"

local plugin = {
  PRIORITY = 10,
  VERSION = "0.1",
}

function plugin:access(plugin_conf)

   local httpc = http.new()
   local res, err = httpc:request_uri(plugin_conf.server_url, {
     method = "POST",
     body = "grant_type=client_credentials&client_id=" .. plugin_conf.client_id .. "&client_secret=" .. plugin_conf.client_secret .. "&scope=" .. plugin_conf.scope,
     headers = {
       ["Accept"] = "application/json",
       ["Content-Type"] = "application/x-www-form-urlencoded",
     },
     ssl_verify = false
   })

   local body = res.body
   local json_okta_response = cjson.decode(body)

   if res.status == 200 then
    kong.service.request.add_header("Authorization", "Bearer " .. json_okta_response.access_token)
   else
    return kong.response.exit(401, "Unauthorized")
   end

--    kong.log.debug("keycloak body" .. body) 

  

end
-- return our plugin object
return plugin









