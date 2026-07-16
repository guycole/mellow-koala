require "rails_helper"
require Rails.root.join("lib/importer_config")

RSpec.describe ImporterConfig do
  describe ".resolve_config" do
    let(:collector_id) { "mellow-hyena-uat" }
    let(:credentials_path) { Tempfile.create("importer-config") }

    before do
      credentials_path.write(<<~TEXT)
        MELLOW_HYENA_UAT_TOKEN=file-collector-token
        MELLOW_KOALA_TOKEN=file-generic-token
        MELLOW_KOALA_URL=http://file-host:3000
      TEXT
      credentials_path.flush
    end

    after do
      credentials_path.close!
    end

    it "prefers the collector-specific environment token" do
      token, url = described_class.resolve_config(
        collector_id,
        env: {
          "MELLOW_HYENA_UAT_TOKEN" => "env-collector-token",
          "MELLOW_KOALA_TOKEN" => "env-generic-token"
        },
        credentials_path: credentials_path.path
      )

      expect(token).to eq("env-collector-token")
      expect(url).to eq("http://file-host:3000")
    end

    it "falls back to the generic environment token" do
      token, = described_class.resolve_config(
        collector_id,
        env: { "MELLOW_KOALA_TOKEN" => "env-generic-token" },
        credentials_path: credentials_path.path
      )

      expect(token).to eq("env-generic-token")
    end

    it "prefers the collector-specific credentials token over a generic environment token" do
      token, = described_class.resolve_config(
        collector_id,
        env: { "MELLOW_KOALA_TOKEN" => "env-generic-token" },
        credentials_path: credentials_path.path
      )

      expect(token).to eq("file-collector-token")
    end

    it "falls back to the collector-specific credentials token before the generic file token" do
      token, url = described_class.resolve_config(
        collector_id,
        env: {},
        credentials_path: credentials_path.path
      )

      expect(token).to eq("file-collector-token")
      expect(url).to eq("http://file-host:3000")
    end

    it "returns the default URL when none is configured" do
      empty_credentials = Tempfile.create("importer-config-empty")

      token, url = described_class.resolve_config(
        collector_id,
        env: {},
        credentials_path: empty_credentials.path
      )

      expect(token).to be_nil
      expect(url).to eq("http://localhost:3000")
    ensure
      empty_credentials.close!
    end
  end

  describe ".token_env_key" do
    it "builds a collector-specific token key" do
      expect(described_class.token_env_key("mellow-hyena-uat")).to eq("MELLOW_HYENA_UAT_TOKEN")
    end
  end
end