require "rails_helper"

RSpec.describe "Index Overview", type: :system do
  before do
    driven_by :rack_test
  end

  it "shows empty state when no components exist" do
    visit root_path
    expect(page).to have_text("No components have reported configuration yet")
  end

  it "shows component list with timestamps" do
    component = create(:component, display_name: "Mellow Hyena-ADSB")
    create(:configuration_snapshot, component: component, received_at: 1.hour.ago)
    visit root_path
    expect(page).to have_text("Mellow Hyena-ADSB")
  end

  it "marks stale components visually" do
    component = create(:component, display_name: "Stale One")
    create(:configuration_snapshot, component: component, received_at: 2.days.ago)
    visit root_path
    expect(page).to have_text("Stale")
  end

  it "marks fresh components visually" do
    component = create(:component, display_name: "Fresh One")
    create(:configuration_snapshot, component: component, received_at: 1.hour.ago)
    visit root_path
    expect(page).to have_text("Fresh")
  end
end
