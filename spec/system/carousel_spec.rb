require "rails_helper"

RSpec.describe "Carousel", type: :system do
  before { driven_by :rack_test }

  it "shows empty state when no collectors" do
    visit carousel_path
    expect(page).to have_text("No collectors available")
  end

  it "shows collector info in carousel" do
    collector = create(:collector, display_name: "Mellow Mastodon", slug: "mellow-mastodon")
    create(:configuration_snapshot, collector: collector)
    visit carousel_path
    expect(page).to have_text("Mellow Mastodon")
    expect(page).to have_text("Carousel")
  end

  it "cycles to next collector via index param" do
    c1 = create(:collector, display_name: "Collector A", slug: "collector-a")
    c2 = create(:collector, display_name: "Collector B", slug: "collector-b")
    create(:configuration_snapshot, collector: c1)
    create(:configuration_snapshot, collector: c2)

    visit carousel_path(index: 0)
    expect(page).to have_text("Collector A")

    visit carousel_path(index: 1)
    expect(page).to have_text("Collector B")
  end
end
