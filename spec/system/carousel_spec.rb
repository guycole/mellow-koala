require "rails_helper"

RSpec.describe "Carousel", type: :system do
  before { driven_by :rack_test }

  it "shows empty state when no components" do
    visit carousel_path
    expect(page).to have_text("No components available")
  end

  it "shows component info in carousel" do
    component = create(:component, display_name: "Mellow Mastodon", slug: "mellow-mastodon")
    create(:configuration_snapshot, component: component)
    visit carousel_path
    expect(page).to have_text("Mellow Mastodon")
    expect(page).to have_text("Carousel")
  end

  it "cycles to next component via index param" do
    c1 = create(:component, display_name: "Component A", slug: "component-a")
    c2 = create(:component, display_name: "Component B", slug: "component-b")
    create(:configuration_snapshot, component: c1)
    create(:configuration_snapshot, component: c2)

    visit carousel_path(index: 0)
    expect(page).to have_text("Component A")

    visit carousel_path(index: 1)
    expect(page).to have_text("Component B")
  end
end
