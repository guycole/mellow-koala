require "rails_helper"

RSpec.describe "Left Navigation", type: :system do
  before { driven_by :rack_test }

  it "renders left nav on the index page" do
    visit root_path
    expect(page).to have_text("Mellow Koala")
  end

  it "shows component links in nav when components exist" do
    create(:component, display_name: "Mellow Heeler", slug: "mellow-heeler")
    visit root_path
    expect(page).to have_link("Details")
    expect(page).to have_link("Collection")
  end

  it "hides Details link for collector components" do
    create(:component, :collector, display_name: "Mellow Heeler", slug: "mellow-heeler")
    visit root_path
    expect(page).not_to have_link("Details")
    expect(page).to have_link("Collection")
  end
end
