require "rails_helper"

RSpec.describe "Index Overview", type: :system do
  before do
    driven_by :rack_test
  end

  it "shows empty state when no collectors exist" do
    visit root_path
    expect(page).to have_text("No collectors have reported configuration yet")
  end

  it "shows collector list with timestamps" do
    collector = create(:collector, display_name: "Mellow Hyena-ADSB")
    create(:configuration_snapshot, collector: collector, received_at: 1.hour.ago)
    visit root_path
    expect(page).to have_text("Mellow Hyena-ADSB")
  end

  it "marks stale collectors visually" do
    collector = create(:collector, display_name: "Stale One")
    create(:configuration_snapshot, collector: collector, received_at: 2.days.ago)
    visit root_path
    expect(page).to have_text("Stale")
  end

  it "marks fresh collectors visually" do
    collector = create(:collector, display_name: "Fresh One")
    create(:configuration_snapshot, collector: collector, received_at: 1.hour.ago)
    visit root_path
    expect(page).to have_text("Fresh")
  end
end
