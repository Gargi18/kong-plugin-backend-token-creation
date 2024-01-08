local kong = kong
local cjson = require "cjson"
local http = require "resty.http"

local plugin = {
  PRIORITY = 10,
  VERSION = "0.1",
}

function plugin:access(plugin_conf)

   local scope = plugin_conf.scope
   if scope == nil then
    scope = ""
   end

   local httpc = http.new()
   local req_body, auth_header
   if plugin_conf.credentials_send_in == "body" then
    req_body = "grant_type=client_credentials&client_id=" .. plugin_conf.client_id .. "&client_secret=" .. plugin_conf.client_secret .. "&scope=" .. scope
   else
    req_body = "grant_type=client_credentials&scope=" .. scope
    auth_header = "Basic " .. ngx.encode_base64( plugin_conf.client_id .. ":" .. plugin_conf.client_secret)
   end

   local res, err = httpc:request_uri(plugin_conf.token_url, {
     method = "POST",
     body = req_body,
     headers = {
       ["Accept"] = "application/json",
       ["Content-Type"] = "application/x-www-form-urlencoded",
       ["Authorization"] = auth_header,
     },
     ssl_verify = plugin_conf.ssl_verify
   })

   local body = res.body
   local json_okta_response = cjson.decode(body)

   kong.log.debug("status " .. res.status)
   kong.log.debug("body " .. res.body) 

   if res.status == 200 then
    kong.service.request.add_header("Authorization", "Bearer " .. json_okta_response.access_token)
   else
    return kong.response.exit(401, "Unauthorized")
   end

--    kong.log.debug("keycloak body" .. body) 

  

end
-- return our plugin object
return plugin









