# StringEncrypt — Ruby Web API SDK

Ruby SDK for [StringEncrypt](https://www.stringencrypt.com).

API: https://www.stringencrypt.com/api.php

Author: Bartosz Wójcik / PELock — https://www.pelock.com

## Installation

This gem is not published on RubyGems. Build it locally:

```bash
gem build stringencrypt.gemspec
gem install stringencrypt-*.gem
```

Or from a clone without installing:

```ruby
$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require "stringencrypt"
```

Uses Ruby stdlib `Net::HTTP` only (no Faraday).

## Usage

```ruby
require "stringencrypt"

client = StringEncrypt.new("YOUR-API-KEY-HERE") # empty = demo
client.set_language(StringEncrypt::Language::RUBY)
result = client.encrypt_string("Hello!", "$label")

if result && result["error"] == StringEncrypt::ErrorCode::SUCCESS
  puts result["source"]
end
```

See `examples/`.

POST field `code` is the activation key. Commands: `encrypt`, `is_demo`, `info`.
Boolean fields are sent as `1`/`0` (PHP `http_build_query` style).
Uses `application/x-www-form-urlencoded` (not multipart).

## License

Apache-2.0. Copyright Bartosz Wójcik / PELock.
