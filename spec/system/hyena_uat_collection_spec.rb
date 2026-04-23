require "rails_helper"

RSpec.describe "Mellow Hyena UAT Collection View", type: :system do
  before { driven_by :rack_test }

  let(:collector) do
    create(:collector, :collection_only, collector_id: "mellow-hyena-uat",
           display_name: "Mellow Hyena-UAT", slug: "mellow-hyena-uat")
  end

  let(:z_time) { 1_706_505_957 }
  let(:expected_utc) { Time.at(z_time).utc.iso8601 }

  let(:base_payload) do
    {
      "platform"    => "rpi4c",
      "project"     => "hyena-uat",
      "zTime"       => z_time,
      "version"     => 1,
      "geoLoc"      => { "site" => "anderson1" },
      "observation" => [
        { "flight" => "N12345", "lat" => 40.5, "lon" => -122.5,
          "altitude" => 8500, "track" => 90, "speed" => 120, "adsbHex" => "b11111" }
      ],
      "adsbex" => [
        { "adsbHex" => "b11111", "registration" => "N12345", "model" => "C172",
          "flight" => "N12345", "category" => "A1", "emergency" => "none",
          "laddFlag" => false, "militaryFlag" => false, "piaFlag" => false, "wierdoFlag" => false }
      ]
    }
  end

  # US8 scenario 1: header fields displayed
  it "shows the observation time, beacon count, platform, and site" do
    create(:collection_snapshot, collector: collector, payload: base_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("Observation Time (UTC)")
    expect(page).to have_text(expected_utc)
    expect(page).to have_text("UAT Beacons Observed")
    expect(page).to have_text("1")
    expect(page).to have_text("anderson1")
    expect(page).to have_text("rpi4c")
  end

  # US8 scenario 2: observation table rendered
  it "shows the UAT observation table with required columns" do
    create(:collection_snapshot, collector: collector, payload: base_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("b11111")
    expect(page).to have_text("N12345")
    expect(page).to have_text("C172")
    expect(page).to have_text("8500")
    expect(page).to have_text("90")
  end

  # US8 scenario 3: adsbex enrichment lookup
  it "displays registration and model from adsbex when adsbHex matches" do
    create(:collection_snapshot, collector: collector, payload: base_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("N12345")
    expect(page).to have_text("C172")
  end

  # US8 scenario 4: unknown fallback when no adsbex entry
  it "displays 'unknown' for registration and model when no adsbex match" do
    payload_no_enrich = base_payload.merge(
      "observation" => [
        { "flight" => "UATUNK", "altitude" => 3000, "track" => 45,
          "speed" => 100, "adsbHex" => "aaaaaa" }
      ],
      "adsbex" => []
    )
    create(:collection_snapshot, collector: collector, payload: payload_no_enrich)
    visit collection_collector_path(collector)
    expect(page).to have_text("aaaaaa")
    expect(page).to have_text("unknown")
  end

  # US8 scenario 5: truncation to 15 observations
  it "shows only the first 15 observations when more than 15 are present" do
    many_obs = (1..20).map do |i|
      { "flight" => "UAT#{i.to_s.rjust(3, '0')}", "altitude" => 5000 + i,
        "track" => i * 5, "speed" => 150, "adsbHex" => "uat#{i.to_s.rjust(3, '0')}" }
    end
    big_payload = base_payload.merge("observation" => many_obs, "adsbex" => [])
    create(:collection_snapshot, collector: collector, payload: big_payload)
    visit collection_collector_path(collector)
    expect(page).to have_text("showing 15 of 20")
    expect(page).to have_text("UAT015")
    expect(page).not_to have_text("UAT016")
  end

  # US8 scenario 6: empty state
  it "shows an empty state when no Hyena UAT collection data exists" do
    visit collection_collector_path(collector)
    expect(page).to have_text("No collection data available yet")
  end
end
