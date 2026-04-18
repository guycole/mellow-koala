require "rails_helper"

RSpec.describe CollectionSnapshot, type: :model do
  it "is valid with required attributes" do
    expect(build(:collection_snapshot)).to be_valid
  end

  it "requires snapshot_id to be unique per component" do
    c = create(:component)
    create(:collection_snapshot, component: c, snapshot_id: "col-1")
    dup = build(:collection_snapshot, component: c, snapshot_id: "col-1")
    expect(dup).not_to be_valid
  end
end
