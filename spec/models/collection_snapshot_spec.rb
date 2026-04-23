require "rails_helper"

RSpec.describe CollectionSnapshot, type: :model do
  it "is valid with required attributes" do
    expect(build(:collection_snapshot)).to be_valid
  end

  it "requires snapshot_id to be unique per collector" do
    c = create(:collector)
    create(:collection_snapshot, collector: c, snapshot_id: "col-1")
    dup = build(:collection_snapshot, collector: c, snapshot_id: "col-1")
    expect(dup).not_to be_valid
  end
end
