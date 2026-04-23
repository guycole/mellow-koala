require "rails_helper"

RSpec.describe "Mellow Hyena ADSB Collection View", type: :system do
  before { driven_by :rack_test }

  let(:collector) do
    create(:collector, :collection_only, collector_id: "mellow-hyena-adsb",
           display_name: "Mellow Hyena-ADSB", slug: "mellow-hyena-adsb")
  end

  let(:z_time) { 1_706_505_957 }
  let(:expected_utc) { Time.at(z_time).utc.iso8601 }

  let(:base_payload) do
    {
      "platform"    => "rpi4c",
      "project"     => "hyena-adsb",
      "zTime"       => z_time,
      "version"     => 1,
      "geoLoc"      => { "site" => "anderson1" },
      "observation" => [
        { "flight" => "SKW3695", "lat" => 40.921838, "lon" => -123.016725,
          "altitude" => 33000, "track" => 178, "speed" => 439, "adsbHex" => "a25925" }
      ],
      "adsbex" => [
        { "adsbHex" => "a25925", "registration" => "N250SY", "model" => "E75L",
          "flight" => "SKW3695", "category" => "A3", "emergency" => "none",
          "laddFlag" => false, "militaryFlag" => false, "piaFlag" => false, "wierdoFlag" => false }
      ]
    }
  end

  # US7 scenario 1: header fields displayed
  it "shows the observation time, beacon count, platform, and site" do
    create(:collection_snapshot, collector: collector, payload: base_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("Observation Time (UTC)")
    expect(page).to have_text(expected_utc)
    expect(page).to have_text("ADSB Beacons Observed")
    expect(page).to have_text("1")
    expect(page).to have_text("anderson1")
    expect(page).to have_text("rpi4c")
  end

  # US7 scenario 2: observation table rendered
  it "shows the ADSB observation table with required columns" do
    create(:collection_snapshot, collector: collector, payload: base_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("a25925")
    expect(page).to have_text("N250SY")
    expect(page).to have_text("E75L")
    expect(page).to have_text("SKW3695")
    expect(page).to have_text("33000")
    expect(page).to have_text("178")
  end

  # US7 scenario 3: adsbex enrichment lookup
  it "displays registration and model from adsbex when adsbHex matches" do
    create(:collection_snapshot, collector: collector, payload: base_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("N250SY")
    expect(page).to have_text("E75L")
  end

  # US7 scenario 4: unknown fallback when no adsbex entry
  it "displays 'unknown' for registration and model when no adsbex match" do
    payload_no_enrich = base_payload.merge(
      "observation" => [
        { "flight" => "UNK001", "altitude" => 5000, "track" => 90,
          "speed" => 200, "adsbHex" => "ffffff" }
      ],
      "adsbex" => []
    )
    create(:collection_snapshot, collector: collector, payload: payload_no_enrich)
    visit collection_collector_path(collector)
    expect(page).to have_text("ffffff")
    expect(page).to have_text("unknown")
  end

  # US7 scenario 5: truncation to 15 observations
  it "shows only the first 15 observations when more than 15 are present" do
    many_obs = (1..20).map do |i|
      { "flight" => "FLT#{i.to_s.rjust(3, '0')}", "altitude" => 10000 + i,
        "track" => i * 10, "speed" => 300, "adsbHex" => "hex#{i.to_s.rjust(3, '0')}" }
    end
    big_payload = base_payload.merge("observation" => many_obs, "adsbex" => [])
    create(:collection_snapshot, collector: collector, payload: big_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("showing 15 of 20")
    expect(page).to have_text("FLT015")
    expect(page).not_to have_text("FLT016")
  end

  # US7 scenario 6: empty state
  it "shows an empty state when no Hyena ADSB collection data exists" do
    visit collection_collector_path(collector)
    expect(page).to have_text("No collection data available yet")
  end
end
