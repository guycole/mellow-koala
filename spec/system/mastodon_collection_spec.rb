require "rails_helper"

RSpec.describe "Mellow Mastodon Collection View", type: :system do
  before { driven_by :rack_test }

  let(:collector) do
    create(:collector, :collection_only, collector_id: "mellow-mastodon",
           display_name: "Mellow Mastodon", slug: "mellow-mastodon")
  end

  let(:z_time) { 1_706_505_957 }
  let(:expected_utc) { Time.at(z_time).utc.iso8601 }

  let(:mastodon_payload) do
    {
      "platform" => "rpi4c",
      "project"  => "mastodon",
      "zTime"    => z_time,
      "version"  => 1,
      "geoLoc"   => { "site" => "anderson1" },
      "peakers"  => 7
    }
  end

  # US9 scenario 1: header fields displayed
  it "shows the observation time, peakers count, platform, and site" do
    create(:collection_snapshot, collector: collector, payload: mastodon_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("Observation Time (UTC)")
    expect(page).to have_text(expected_utc)
    expect(page).to have_text("Peakers")
    expect(page).to have_text("7")
    expect(page).to have_text("anderson1")
    expect(page).to have_text("rpi4c")
  end

  # US9 scenario 2: empty state
  it "shows an empty state when no Mastodon collection data exists" do
    visit collection_collector_path(collector)
    expect(page).to have_text("No collection data available yet")
  end
end
