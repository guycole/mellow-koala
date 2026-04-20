require "rails_helper"

RSpec.describe "Component Details", type: :system do
  before { driven_by :rack_test }

  let(:component) { create(:component, display_name: "Mellow Hyena-ADSB", slug: "mellow-hyena-adsb") }

  it "shows latest config snapshot" do
    create(:configuration_snapshot, component: component,
           payload: { "version" => "2.0.0" })
    visit component_path(component)
    expect(page).to have_text("Mellow Hyena-ADSB")
    expect(page).to have_text("2.0.0")
  end

  it "shows empty state when no config snapshots" do
    visit component_path(component)
    expect(page).to have_text("No configuration snapshots available yet")
  end
end
