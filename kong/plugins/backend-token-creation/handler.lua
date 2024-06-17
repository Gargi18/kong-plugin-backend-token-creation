local kong = kong
local cjson = require "cjson"
local http = require "resty.http"
local jwtDec = require "resty.jwt"

local plugin = {
  PRIORITY = 10,
  VERSION = "0.1",
}

function plugin:access(plugin_conf)

   local httpc = http.new()
   local req_body, auth_header
   req_body = "grant_type=client_credentials&client_id=" .. plugin_conf.client_id .. "&client_secret=" .. plugin_conf.client_secret
   if plugin_conf.audience ~= nil then
    req_body = req_body .. "&audience=" .. plugin_conf.audience
   end
   if plugin_conf.scope ~= nil then
    req_body = req_body .. "&scope=" .. plugin_conf.scope
   end

   local res, err = httpc:request_uri(plugin_conf.token_url, {
     method = "POST",
     body = req_body,
     headers = {
       ["Accept"] = "application/json",
       ["Content-Type"] = "application/x-www-form-urlencoded"
     },
     ssl_verify = plugin_conf.ssl_verify
   })

   local body = res.body
   local json_okta_response = cjson.decode(body)
   local response_accesstoken =json_okta_response.access_token
   local expiry_ttl =json_okta_response.expires_in

   kong.log.debug("status " .. res.status)
   kong.log.debug("body " .. res.body) 

   if res.status == 200 then
    kong.service.request.add_header("Authorization", "Bearer " .. response_accesstoken)
    kong.service.request.add_header("TokenExpiry", expiry_ttl)
   else
    return kong.response.exit(401, "Unauthorized")
   end

--    kong.log.debug("keycloak body" .. body) 

  

end
-- return our plugin object
return plugin









