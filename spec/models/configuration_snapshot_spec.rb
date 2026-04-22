require "rails_helper"

RSpec.describe ConfigurationSnapshot, type: :model do
  it "is valid with required attributes" do
    expect(build(:configuration_snapshot)).to be_valid
  end

  it "requires snapshot_id to be unique per component" do
    c = create(:component)
    create(:configuration_snapshot, component: c, snapshot_id: "snap-1")
    dup = build(:configuration_snapshot, component: c, snapshot_id: "snap-1")
    expect(dup).not_to be_valid
  end

  it "allows same snapshot_id for different components" do
    c1 = create(:component)
    c2 = create(:component)
    create(:configuration_snapshot, component: c1, snapshot_id: "snap-1")
    expect(build(:configuration_snapshot, component: c2, snapshot_id: "snap-1")).to be_valid
  end
end
