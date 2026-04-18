require "rails_helper"

RSpec.describe Component, type: :model do
  it "is valid with required attributes" do
    expect(build(:component)).to be_valid
  end

  it "requires component_id" do
    expect(build(:component, component_id: nil)).not_to be_valid
  end

  it "requires display_name" do
    expect(build(:component, display_name: nil)).not_to be_valid
  end

  it "requires unique component_id" do
    create(:component, component_id: "dup-id")
    expect(build(:component, component_id: "dup-id")).not_to be_valid
  end

  it "auto-sets slug from display_name" do
    c = build(:component, slug: nil, display_name: "Mellow Hyena")
    c.valid?
    expect(c.slug).to eq("mellow-hyena")
  end

  describe ".authenticate_by_token" do
    let(:raw_token) { "my-secret" }
    let!(:component) { create(:component, component_id: "comp-1", ingest_token_digest: BCrypt::Password.create(raw_token)) }

    it "returns component on valid token" do
      expect(Component.authenticate_by_token("comp-1", raw_token)).to eq(component)
    end

    it "returns nil on wrong token" do
      expect(Component.authenticate_by_token("comp-1", "wrong")).to be_nil
    end

    it "returns nil when component_id not found" do
      expect(Component.authenticate_by_token("unknown", raw_token)).to be_nil
    end
  end

  describe "#stale?" do
    it "is stale when no config snapshots" do
      c = create(:component)
      expect(c.stale?).to be true
    end

    it "is not stale when recent config snapshot" do
      c = create(:component)
      create(:configuration_snapshot, component: c, received_at: 1.hour.ago)
      expect(c.stale?).to be false
    end
  end
end
