# frozen_string_literal: true

###############################################################################
#
# StringEncrypt — info
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
client.set_command(StringEncrypt::Command::INFO)
p client.send
