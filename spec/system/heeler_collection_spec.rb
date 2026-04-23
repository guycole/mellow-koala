require "rails_helper"

RSpec.describe "Mellow Heeler Collection View", type: :system do
  before { driven_by :rack_test }

  let(:collector) do
    create(:collector, collector_id: "mellow-heeler", display_name: "Mellow Heeler", slug: "mellow-heeler")
  end

  let(:z_time) { 1_742_095_222 }
  let(:expected_utc) { Time.at(z_time).utc.iso8601 }

  let(:heeler_payload) do
    {
      "geoLoc"   => { "site" => "anderson1" },
      "platform" => "rpi3c",
      "project"  => "heeler",
      "version"  => 1,
      "wifi"     => [
        { "bssid" => "00:22:6b:81:03:d9", "capability" => "unknown",
          "frequency_mhz" => 2437, "signal_dbm" => -86, "ssid" => "braingang2" },
        { "bssid" => "aa:bb:cc:dd:ee:ff", "capability" => "wpa2",
          "frequency_mhz" => 5180, "signal_dbm" => -72, "ssid" => "coolnet" }
      ],
      "zTime" => z_time
    }
  end

  # US6 scenario 1: timestamp displayed
  it "shows the UTC observation timestamp from zTime" do
    create(:collection_snapshot, collector: collector, payload: heeler_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("Observation Time (UTC)")
    expect(page).to have_text(expected_utc)
  end

  # US6 scenario 2: AP beacon count displayed
  it "shows the count of WiFi AP beacons" do
    create(:collection_snapshot, collector: collector, payload: heeler_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("AP Beacons Observed")
    expect(page).to have_text("2")
  end

  # US6 scenario 3: AP beacon table with correct columns
  it "shows the WiFi AP beacon table with SSID, BSSID, frequency, and signal" do
    create(:collection_snapshot, collector: collector, payload: heeler_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("braingang2")
    expect(page).to have_text("00:22:6b:81:03:d9")
    expect(page).to have_text("2437")
    expect(page).to have_text("-86")
    expect(page).to have_text("coolnet")
    expect(page).to have_text("5180")
    expect(page).to have_text("-72")
  end

  # US6 scenario 4: truncation to 15 APs
  it "shows only the first 15 AP beacons when more than 15 are present" do
    many_wifi = (1..20).map do |i|
      { "bssid" => "aa:bb:cc:dd:ee:#{i.to_s.rjust(2, '0')}",
        "capability" => "unknown",
        "frequency_mhz" => 2400 + i,
        "signal_dbm" => -80,
        "ssid" => "network-#{i}" }
    end
    big_payload = heeler_payload.merge("wifi" => many_wifi)
    create(:collection_snapshot, collector: collector, payload: big_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("showing 15 of 20")
    expect(page).to have_text("network-15")
    expect(page).not_to have_text("network-16")
  end

  # US6 scenario 5: empty state when no collection data
  it "shows an empty state when no Heeler collection data exists" do
    visit collection_collector_path(collector)
    expect(page).to have_text("No collection data available yet")
  end
end
