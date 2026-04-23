require "rails_helper"

RSpec.describe Collector, type: :model do
  it "is valid with required attributes" do
    expect(build(:collector)).to be_valid
  end

  it "requires collector_id" do
    expect(build(:collector, collector_id: nil)).not_to be_valid
  end

  it "requires display_name" do
    expect(build(:collector, display_name: nil)).not_to be_valid
  end

  it "requires unique collector_id" do
    create(:collector, collector_id: "dup-id")
    expect(build(:collector, collector_id: "dup-id")).not_to be_valid
  end

  it "auto-sets slug from display_name" do
    c = build(:collector, slug: nil, display_name: "Mellow Hyena-ADSB")
    c.valid?
    expect(c.slug).to eq("mellow-hyena-adsb")
  end

  describe ".authenticate_by_token" do
    let(:raw_token) { "my-secret" }
    let!(:collector) { create(:collector, collector_id: "col-1", ingest_token_digest: BCrypt::Password.create(raw_token)) }

    it "returns collector on valid token" do
      expect(Collector.authenticate_by_token("col-1", raw_token)).to eq(collector)
    end

    it "returns nil on wrong token" do
      expect(Collector.authenticate_by_token("col-1", "wrong")).to be_nil
    end

    it "returns nil when collector_id not found" do
      expect(Collector.authenticate_by_token("unknown", raw_token)).to be_nil
    end
  end

  describe "#stale?" do
    it "is stale when no config snapshots" do
      c = create(:collector)
      expect(c.stale?).to be true
    end

    it "is not stale when recent config snapshot" do
      c = create(:collector)
      create(:configuration_snapshot, collector: c, received_at: 1.hour.ago)
      expect(c.stale?).to be false
    end
  end
end
