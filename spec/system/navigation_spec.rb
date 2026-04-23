require "rails_helper"

RSpec.describe "Left Navigation", type: :system do
  before { driven_by :rack_test }

  it "renders left nav on the index page" do
    visit root_path
    expect(page).to have_text("Mellow Koala")
  end

  it "shows collector links in nav when collectors exist" do
    create(:collector, display_name: "Mellow Heeler", slug: "mellow-heeler")
    visit root_path
    expect(page).to have_link("Details")
    expect(page).to have_link("Collection")
  end

  it "hides Details link for collection-only collectors" do
    create(:collector, :collection_only, display_name: "Mellow Heeler", slug: "mellow-heeler")
    visit root_path
    expect(page).not_to have_link("Details")
    expect(page).to have_link("Collection")
  end
end
