require "rails_helper"

RSpec.describe "Collector Details", type: :system do
  before { driven_by :rack_test }

  let(:collector) { create(:collector, display_name: "Mellow Hyena-ADSB", slug: "mellow-hyena-adsb") }

  it "shows latest config snapshot" do
    create(:configuration_snapshot, collector: collector,
           payload: { "version" => "2.0.0" })
    visit collector_path(collector)
    expect(page).to have_text("Mellow Hyena-ADSB")
    expect(page).to have_text("2.0.0")
  end

  it "shows empty state when no config snapshots" do
    visit collector_path(collector)
    expect(page).to have_text("No configuration snapshots available yet")
  end
end
