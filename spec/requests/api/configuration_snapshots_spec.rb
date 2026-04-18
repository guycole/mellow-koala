require "rails_helper"

RSpec.describe "Api::ConfigurationSnapshots", type: :request do
  let(:raw_token) { "super-secret-token-123" }
  let(:component) { create(:component, ingest_token: raw_token) }
  let(:auth_headers) { { "Authorization" => "Bearer #{raw_token}", "Content-Type" => "application/json" } }
  let(:valid_payload) do
    {
      snapshot_id: "cfg-0001",
      captured_at: "2026-04-18T06:00:00Z",
      payload: { version: "1.2.3", config: { mode: "active" } }
    }
  end

  describe "POST /api/components/:component_id/configuration_snapshots" do
    context "with valid auth and payload" do
      it "returns 201 and stores the snapshot" do
        post "/api/components/#{component.component_id}/configuration_snapshots",
             params: valid_payload.to_json,
             headers: auth_headers

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["status"]).to eq("accepted")
        expect(body["snapshot_id"]).to eq("cfg-0001")
        expect(ConfigurationSnapshot.count).to eq(1)
      end
    end

    context "with idempotent retry" do
      it "returns 200 on replay and does not duplicate" do
        create(:configuration_snapshot, component: component, snapshot_id: "cfg-0001")

        post "/api/components/#{component.component_id}/configuration_snapshots",
             params: valid_payload.to_json,
             headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(ConfigurationSnapshot.count).to eq(1)
      end
    end

    context "with missing authentication" do
      it "returns 401" do
        post "/api/components/#{component.component_id}/configuration_snapshots",
             params: valid_payload.to_json,
             headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid token" do
      it "returns 403" do
        post "/api/components/#{component.component_id}/configuration_snapshots",
             params: valid_payload.to_json,
             headers: { "Authorization" => "Bearer wrong-token", "Content-Type" => "application/json" }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when token belongs to a different component" do
      let(:other_component) { create(:component) }

      it "returns 403" do
        post "/api/components/#{other_component.component_id}/configuration_snapshots",
             params: valid_payload.to_json,
             headers: auth_headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "with missing payload" do
      it "returns 400 with error message" do
        post "/api/components/#{component.component_id}/configuration_snapshots",
             params: { snapshot_id: "cfg-bad" }.to_json,
             headers: auth_headers

        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body.dig("error", "message")).to be_present
      end
    end

    context "with missing snapshot_id" do
      it "returns 400" do
        post "/api/components/#{component.component_id}/configuration_snapshots",
             params: { payload: { version: "1.0" } }.to_json,
             headers: auth_headers

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
