# frozen_string_literal: true

###############################################################################
#
# StringEncrypt — is_demo
#
# Version        : v1.0.1
# Language       : Ruby
# Author         : Bartosz Wójcik
# Web page       : https://www.pelock.com
#
###############################################################################

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "stringencrypt"

p StringEncrypt.new("YOUR-API-KEY-HERE").is_demo
