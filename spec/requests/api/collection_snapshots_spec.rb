require "rails_helper"

RSpec.describe "Api::CollectionSnapshots", type: :request do
  let(:raw_token) { "collection-token-abc" }
  let(:component) { create(:component, ingest_token: raw_token) }
  let(:auth_headers) { { "Authorization" => "Bearer #{raw_token}", "Content-Type" => "application/json" } }
  let(:valid_payload) do
    {
      snapshot_id: "col-0001",
      captured_at: "2026-04-18T06:00:00Z",
      payload: { collections: [{ name: "items", count: 42 }] }
    }
  end

  describe "POST /api/components/:component_id/collection_snapshots" do
    it "returns 201 on valid upload" do
      post "/api/components/#{component.component_id}/collection_snapshots",
           params: valid_payload.to_json,
           headers: auth_headers

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("accepted")
      expect(CollectionSnapshot.count).to eq(1)
    end

    it "returns 200 on idempotent retry" do
      create(:collection_snapshot, component: component, snapshot_id: "col-0001")

      post "/api/components/#{component.component_id}/collection_snapshots",
           params: valid_payload.to_json,
           headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(CollectionSnapshot.count).to eq(1)
    end

    it "returns 401 without auth" do
      post "/api/components/#{component.component_id}/collection_snapshots",
           params: valid_payload.to_json,
           headers: { "Content-Type" => "application/json" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 with wrong token" do
      post "/api/components/#{component.component_id}/collection_snapshots",
           params: valid_payload.to_json,
           headers: { "Authorization" => "Bearer bad-token", "Content-Type" => "application/json" }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
