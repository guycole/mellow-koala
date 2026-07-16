module ImporterConfig
  module_function

  CREDENTIALS_FILE = File.join(Dir.home, ".mellow-koala", "credentials")
  DEFAULT_URL = "http://localhost:3000"

  def load_credentials_file(path = CREDENTIALS_FILE)
    return {} unless File.exist?(path)

    File.readlines(path, chomp: true).each_with_object({}) do |line, values|
      next if line.strip.empty? || line.start_with?("#")

      key, value = line.split("=", 2)
      values[key.strip] = value&.strip if key && value
    end
  end

  def token_env_key(collector_id)
    "#{collector_id.tr("-", "_").upcase}_TOKEN"
  end

  def resolve_config(collector_id, env: ENV, credentials_path: CREDENTIALS_FILE)
    credentials = load_credentials_file(credentials_path)
    collector_token_key = token_env_key(collector_id)

    token = env[collector_token_key] ||
      credentials[collector_token_key] ||
      env["MELLOW_KOALA_TOKEN"] ||
      credentials["MELLOW_KOALA_TOKEN"]

    url = env["MELLOW_KOALA_URL"] || credentials["MELLOW_KOALA_URL"] || DEFAULT_URL
    [token, url]
  end
end