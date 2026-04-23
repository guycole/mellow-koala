require "rails_helper"

RSpec.describe "Collector Collection", type: :system do
  before { driven_by :rack_test }

  let(:collector) { create(:collector, display_name: "Mellow Hyena-ADSB", slug: "mellow-hyena-adsb") }

  it "shows latest collection snapshot" do
    create(:collection_snapshot, collector: collector,
           payload: { "collections" => [ { "name" => "items", "count" => 99 } ] })
    visit collection_collector_path(collector)
    expect(page).to have_text("Mellow Hyena-ADSB")
    expect(page).to have_text("99")
  end

  it "shows empty state when no collection data" do
    visit collection_collector_path(collector)
    expect(page).to have_text("No collection data available yet")
  end
end
