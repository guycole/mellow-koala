require "rails_helper"

RSpec.describe ConfigurationSnapshot, type: :model do
  it "is valid with required attributes" do
    expect(build(:configuration_snapshot)).to be_valid
  end

  it "requires snapshot_id to be unique per collector" do
    c = create(:collector)
    create(:configuration_snapshot, collector: c, snapshot_id: "snap-1")
    dup = build(:configuration_snapshot, collector: c, snapshot_id: "snap-1")
    expect(dup).not_to be_valid
  end

  it "allows same snapshot_id for different collectors" do
    c1 = create(:collector)
    c2 = create(:collector)
    create(:configuration_snapshot, collector: c1, snapshot_id: "snap-1")
    expect(build(:configuration_snapshot, collector: c2, snapshot_id: "snap-1")).to be_valid
  end
end
