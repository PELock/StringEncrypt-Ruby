# frozen_string_literal: true

require "base64"
require "zlib"

class StringEncrypt
  DEFAULT_API_URL = "https://www.stringencrypt.com/api.php"
  USER_AGENT = "pelock/stringencrypt (+https://www.stringencrypt.com)"

  def initialize(api_key = "", prefer_curl = false)
    @api_key = api_key.to_s
    @prefer_curl = prefer_curl # ignored; Ruby client always uses Net::HTTP
    @decompress_encrypt_source = true
    reset_defaults(constructor: true)
  end

  def is_demo
    previous = @command
    self.command = Command::IS_DEMO
    result = send
    @command = previous
    result
  end

  def encrypt_file_contents(file_path, label)
    raw = File.binread(file_path)
    return false if raw.nil? || raw.empty?

    saved = snapshot_input
    self.command = Command::ENCRYPT
    set_bytes(raw)
    self.label = label
    result = send
    restore_input(saved)
    result
  rescue StandardError
    false
  end

  def encrypt_string(string, label)
    saved = snapshot_input
    self.command = Command::ENCRYPT
    set_string(string)
    self.label = label
    result = send
    restore_input(saved)
    result
  end

  attr_accessor :prefer_curl, :decompress_encrypt_source, :command, :label,
                :compression, :language, :highlight, :cmd_min, :cmd_max,
                :local, :unicode, :lang_locale, :ansi_encoding, :new_lines,
                :template, :return_template, :include_tags, :include_example,
                :include_debug_comments

  def set_command(command)
    @command = command
    self
  end

  def set_label(label)
    @label = label
    self
  end

  def set_string(string)
    @input_string = string
    @input_bytes = nil
    self
  end

  def set_bytes(bytes)
    @input_bytes = bytes
    @input_string = nil
    self
  end

  def set_compression(compression)
    @compression = compression
    self
  end

  def set_language(language)
    @language = language
    self
  end

  def set_highlight(highlight)
    @highlight = highlight
    self
  end

  def set_cmd_min(cmd_min)
    @cmd_min = cmd_min
    self
  end

  def set_cmd_max(cmd_max)
    @cmd_max = cmd_max
    self
  end

  def set_local(local)
    @local = local
    self
  end

  def set_unicode(unicode)
    @unicode = unicode
    self
  end

  def set_lang_locale(lang_locale)
    @lang_locale = lang_locale
    self
  end

  def set_ansi_encoding(ansi_encoding)
    @ansi_encoding = ansi_encoding
    self
  end

  def set_new_lines(new_lines)
    @new_lines = new_lines
    self
  end

  def set_template(template)
    @template = template
    self
  end

  def set_return_template(return_template)
    @return_template = return_template
    self
  end

  def set_include_tags(include_tags)
    @include_tags = include_tags
    self
  end

  def set_include_example(include_example)
    @include_example = include_example
    self
  end

  def set_include_debug_comments(include_debug_comments)
    @include_debug_comments = include_debug_comments
    self
  end

  def set_decompress_encrypt_source(decompress_encrypt_source)
    @decompress_encrypt_source = decompress_encrypt_source
    self
  end

  def reset
    reset_defaults(constructor: false)
    self
  end

  def to_request_array
    raise ArgumentError, "Command must be set (use set_command)." if @command.nil?

    case @command
    when Command::INFO then build_info_params
    when Command::IS_DEMO then build_is_demo_params
    when Command::ENCRYPT then build_encrypt_params
    else
      raise ArgumentError, "Unknown command: #{@command}"
    end
  end

  # PHP/JS `send()`. A Symbol first argument is forwarded to Object#send
  # so metaprogramming still works.
  def send(method_or_curl = :__http__, *args, &block)
    unless method_or_curl == :__http__ || method_or_curl == true || method_or_curl == false || method_or_curl.nil?
      return super(method_or_curl, *args, &block)
    end

    send_request
  rescue ArgumentError
    false
  end

  def send_request
    params = to_request_array
    raw = Http.post_urlencoded(DEFAULT_API_URL, params, user_agent: USER_AGENT)
    return false if raw.nil? || raw.empty?

    decoded = Http.parse_json(raw)
    return false unless decoded.is_a?(Hash)

    apply_decryptor_source_decompression(decoded)
  end

  private

  def reset_defaults(constructor:)
    @command = nil
    @label = constructor ? "Label" : "$label"
    @input_string = nil
    @input_bytes = nil
    @compression = false
    @language = Language::PHP
    @highlight = false
    @cmd_min = 1
    @cmd_max = 3
    @local = false
    @unicode = true
    @lang_locale = "en_US.utf8"
    @ansi_encoding = "WINDOWS-1250"
    @new_lines = NewLine::LF
    @template = nil
    @return_template = false
    @include_tags = false
    @include_example = false
    @include_debug_comments = false
  end

  def snapshot_input
    {
      command: @command,
      input_string: @input_string,
      input_bytes: @input_bytes,
      label: @label
    }
  end

  def restore_input(saved)
    @command = saved[:command]
    @input_string = saved[:input_string]
    @input_bytes = saved[:input_bytes]
    @label = saved[:label]
  end

  def build_info_params
    { "command" => Command::INFO, "code" => @api_key }
  end

  def build_is_demo_params
    { "command" => Command::IS_DEMO, "code" => @api_key }
  end

  def build_encrypt_params
    params = {
      "command" => Command::ENCRYPT,
      "code" => @api_key,
      "label" => @label,
      "compression" => @compression,
      "lang" => @language,
      "cmd_min" => @cmd_min,
      "cmd_max" => @cmd_max,
      "local" => @local,
      "unicode" => @unicode,
      "lang_locale" => @lang_locale,
      "ansi_encoding" => @ansi_encoding,
      "new_lines" => @new_lines,
      "return_template" => @return_template,
      "include_tags" => @include_tags,
      "include_example" => @include_example,
      "include_debug_comments" => @include_debug_comments
    }
    if !@input_string.nil?
      params["string"] = @input_string
    elsif !@input_bytes.nil?
      params["bytes"] = @input_bytes
    end
    params["highlight"] = @highlight unless @highlight == false
    params["template"] = @template unless @template.nil?
    params
  end

  def apply_decryptor_source_decompression(response)
    return response unless @command == Command::ENCRYPT && @compression && @decompress_encrypt_source
    return response unless response["error"] == ErrorCode::SUCCESS
    return response unless response["source"].is_a?(String)

    binary = Base64.decode64(response["source"])
    response["source"] = Zlib::Inflate.inflate(binary)
    response
  rescue StandardError
    response
  end
end
