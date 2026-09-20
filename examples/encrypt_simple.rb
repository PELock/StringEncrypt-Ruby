# frozen_string_literal: true

###############################################################################
#
# StringEncrypt — encrypt a string
#
# Version        : v1.0.1
# Language       : Ruby
# Author         : Bartosz Wójcik
# Web page       : https://www.pelock.com
#
###############################################################################

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "stringencrypt"

client = StringEncrypt.new("YOUR-API-KEY-HERE")
result = client.encrypt_string("Hello!", "$label")

if result == false
  warn "Cannot connect to the API."
  exit 1
end

if result["error"] != StringEncrypt::ErrorCode::SUCCESS
  warn "API error: #{result["error"]}"
  exit 1
end

puts result["source"]
