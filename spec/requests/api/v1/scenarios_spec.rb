require "rails_helper"

RSpec.describe "Api::V1::Scenarios", type: :request do
  let(:user) { create(:user, :with_api_token) }
  let(:project) { create(:project) }
  let(:feature) { create(:feature, project: project) }

  describe "GET /api/v1/projects/:project_id/features/:feature_id/scenarios" do
    context "without authentication" do
      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios"
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with invalid token" do
      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios", headers: api_headers("invalid_token")
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with expired token" do
      let(:expired_user) { create(:user, :with_expired_api_token) }

      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios", headers: api_headers(expired_user.api_token)
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      let!(:member) { create(:project_member, project: project, email: user.email_address, invitation_accepted: true) }
      let!(:scenario1) { create(:scenario, feature: feature, title: "Scenario A", position: 1) }
      let!(:scenario2) { create(:scenario, feature: feature, title: "Scenario B", position: 2) }
      let!(:scenario3) { create(:scenario, feature: feature, title: "Scenario C", position: 3) }

      it "returns scenarios for feature" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios", headers: api_headers(user.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to eq(3)
      end

      it "returns scenarios ordered by position" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios", headers: api_headers(user.api_token)
        expect(response).to have_http_status(:ok)
        titles = json_response.map { |s| s["title"] }
        expect(titles).to eq([ "Scenario A", "Scenario B", "Scenario C" ])
      end

      it "returns correct JSON structure" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios", headers: api_headers(user.api_token)
        expect(response).to have_http_status(:ok)
        scenario = json_response.first
        expect(scenario).to have_key("id")
        expect(scenario).to have_key("title")
        expect(scenario).to have_key("given")
        expect(scenario).to have_key("when")
        expect(scenario).to have_key("then")
        expect(scenario).to have_key("position")
        expect(scenario).to have_key("feature_id")
        expect(scenario).to have_key("created_at")
        expect(scenario).to have_key("updated_at")
      end

      context "when project does not exist" do
        it "returns 404" do
          get "/api/v1/projects/99999/features/#{feature.id}/scenarios", headers: api_headers(user.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Project not found")
        end
      end

      context "when feature does not exist" do
        it "returns 404" do
          get "/api/v1/projects/#{project.id}/features/99999/scenarios", headers: api_headers(user.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Feature not found")
        end
      end

      context "when user is not a member of the project" do
        let(:other_user) { create(:user, :with_api_token) }
        let(:other_project) { create(:project) }
        let(:other_feature) { create(:feature, project: other_project) }
        let!(:other_scenario) { create(:scenario, feature: other_feature) }

        it "returns 404" do
          get "/api/v1/projects/#{other_project.id}/features/#{other_feature.id}/scenarios", headers: api_headers(other_user.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Project not found")
        end
      end
    end
  end

  describe "GET /api/v1/projects/:project_id/features/:feature_id/scenarios/:id" do
    let!(:member) { create(:project_member, project: project, email: user.email_address, invitation_accepted: true) }
    let(:scenario) { create(:scenario, feature: feature, title: "Test Scenario", given: "Given context", when: "When action", then: "Then result") }

    context "without authentication" do
      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}"
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      it "returns scenario details" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", headers: api_headers(user.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response["id"]).to eq(scenario.id)
        expect(json_response["title"]).to eq("Test Scenario")
        expect(json_response["given"]).to eq("Given context")
        expect(json_response["when"]).to eq("When action")
        expect(json_response["then"]).to eq("Then result")
        expect(json_response["feature_id"]).to eq(feature.id)
      end

      it "returns correct JSON structure" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", headers: api_headers(user.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key("id")
        expect(json_response).to have_key("title")
        expect(json_response).to have_key("given")
        expect(json_response).to have_key("when")
        expect(json_response).to have_key("then")
        expect(json_response).to have_key("position")
        expect(json_response).to have_key("feature_id")
        expect(json_response).to have_key("created_at")
        expect(json_response).to have_key("updated_at")
      end

      context "when scenario does not exist" do
        it "returns 404" do
          get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/99999", headers: api_headers(user.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Scenario not found")
        end
      end

      context "when scenario belongs to different feature" do
        let(:other_feature) { create(:feature, project: project) }
        let(:other_scenario) { create(:scenario, feature: other_feature) }

        it "returns 404" do
          get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{other_scenario.id}", headers: api_headers(user.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Scenario not found")
        end
      end
    end
  end

  describe "POST /api/v1/projects/:project_id/features/:feature_id/scenarios" do
    let(:valid_params) do
      {
        scenario: {
          title: "New Scenario",
          given: "Given something",
          when: "When something happens",
          then: "Then something should happen"
        }
      }
    end

    context "without authentication" do
      it "returns unauthorized" do
        post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios", params: valid_params
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      context "as viewer" do
        let!(:viewer_member) { create(:project_member, project: project, email: user.email_address, role: "viewer", invitation_accepted: true) }

        it "returns 403 forbidden" do
          post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios", params: valid_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:forbidden)
          expect(json_response["error"]).to eq("Access denied")
        end
      end

      context "as editor" do
        let!(:editor_member) { create(:project_member, project: project, email: user.email_address, role: "editor", invitation_accepted: true) }

        it "successfully creates scenario with valid params" do
          expect {
            post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios", params: valid_params, headers: api_headers(user.api_token)
          }.to change(Scenario, :count).by(1)
          expect(response).to have_http_status(:created)
        end

        it "returns 201 with created scenario" do
          post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios", params: valid_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:created)
          expect(json_response["title"]).to eq("New Scenario")
          expect(json_response["given"]).to eq("Given something")
          expect(json_response["when"]).to eq("When something happens")
          expect(json_response["then"]).to eq("Then something should happen")
          expect(json_response["feature_id"]).to eq(feature.id)
        end

        context "with validation errors" do
          it "fails with missing title" do
            invalid_params = { scenario: { given: "Given something" } }
            post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios", params: invalid_params, headers: api_headers(user.api_token)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response["errors"]).to be_present
            expect(json_response["errors"]).to include("Title can't be blank")
          end
        end

        context "when project does not exist" do
          it "returns 404" do
            post "/api/v1/projects/99999/features/#{feature.id}/scenarios", params: valid_params, headers: api_headers(user.api_token)
            expect(response).to have_http_status(:not_found)
            expect(json_response["error"]).to eq("Project not found")
          end
        end

        context "when feature does not exist" do
          it "returns 404" do
            post "/api/v1/projects/#{project.id}/features/99999/scenarios", params: valid_params, headers: api_headers(user.api_token)
            expect(response).to have_http_status(:not_found)
            expect(json_response["error"]).to eq("Feature not found")
          end
        end
      end

      context "as administrator" do
        let!(:admin_member) { create(:project_member, project: project, email: user.email_address, role: "administrator", invitation_accepted: true) }

        it "successfully creates scenario" do
          expect {
            post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios", params: valid_params, headers: api_headers(user.api_token)
          }.to change(Scenario, :count).by(1)
          expect(response).to have_http_status(:created)
        end
      end
    end
  end

  describe "PATCH /api/v1/projects/:project_id/features/:feature_id/scenarios/:id" do
    let(:scenario) { create(:scenario, feature: feature, title: "Original Title", given: "Original Given", when: "Original When", then: "Original Then") }
    let(:update_params) do
      {
        scenario: {
          title: "Updated Title",
          given: "Updated Given",
          when: "Updated When",
          then: "Updated Then"
        }
      }
    end

    context "without authentication" do
      it "returns unauthorized" do
        patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", params: update_params
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      context "as viewer" do
        let!(:viewer_member) { create(:project_member, project: project, email: user.email_address, role: "viewer", invitation_accepted: true) }

        it "returns 403 forbidden" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", params: update_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:forbidden)
          expect(json_response["error"]).to eq("Access denied")
        end
      end

      context "as editor" do
        let!(:editor_member) { create(:project_member, project: project, email: user.email_address, role: "editor", invitation_accepted: true) }

        it "successfully updates scenario with valid params" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", params: update_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:ok)
          scenario.reload
          expect(scenario.title).to eq("Updated Title")
          expect(scenario.given).to eq("Updated Given")
          expect(scenario.when).to eq("Updated When")
          expect(scenario.then).to eq("Updated Then")
        end

        it "returns updated scenario JSON" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", params: update_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:ok)
          expect(json_response["title"]).to eq("Updated Title")
          expect(json_response["given"]).to eq("Updated Given")
          expect(json_response["when"]).to eq("Updated When")
          expect(json_response["then"]).to eq("Updated Then")
        end

        context "with validation errors" do
          it "fails with missing title" do
            invalid_params = { scenario: { title: "" } }
            patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", params: invalid_params, headers: api_headers(user.api_token)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response["errors"]).to be_present
            expect(json_response["errors"]).to include("Title can't be blank")
          end
        end

        context "when scenario does not exist" do
          it "returns 404" do
            patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/99999", params: update_params, headers: api_headers(user.api_token)
            expect(response).to have_http_status(:not_found)
            expect(json_response["error"]).to eq("Scenario not found")
          end
        end
      end

      context "as administrator" do
        let!(:admin_member) { create(:project_member, project: project, email: user.email_address, role: "administrator", invitation_accepted: true) }

        it "successfully updates scenario" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", params: update_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:ok)
          scenario.reload
          expect(scenario.title).to eq("Updated Title")
        end
      end
    end
  end

  describe "DELETE /api/v1/projects/:project_id/features/:feature_id/scenarios/:id" do
    let!(:scenario) { create(:scenario, feature: feature) }

    context "without authentication" do
      it "returns unauthorized" do
        delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}"
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      context "as viewer" do
        let!(:viewer_member) { create(:project_member, project: project, email: user.email_address, role: "viewer", invitation_accepted: true) }

        it "returns 403 forbidden" do
          delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", headers: api_headers(user.api_token)
          expect(response).to have_http_status(:forbidden)
          expect(json_response["error"]).to eq("Access denied")
        end
      end

      context "as editor" do
        let!(:editor_member) { create(:project_member, project: project, email: user.email_address, role: "editor", invitation_accepted: true) }

        it "successfully deletes scenario" do
          expect {
            delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", headers: api_headers(user.api_token)
          }.to change(Scenario, :count).by(-1)
          expect(response).to have_http_status(:ok)
        end

        it "returns success message" do
          delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", headers: api_headers(user.api_token)
          expect(response).to have_http_status(:ok)
          expect(json_response["message"]).to eq("Scenario deleted successfully")
        end

        it "scenario is actually deleted from database" do
          scenario_id = scenario.id
          delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", headers: api_headers(user.api_token)
          expect(Scenario.find_by(id: scenario_id)).to be_nil
        end

        context "when scenario does not exist" do
          it "returns 404" do
            delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/99999", headers: api_headers(user.api_token)
            expect(response).to have_http_status(:not_found)
            expect(json_response["error"]).to eq("Scenario not found")
          end
        end
      end

      context "as administrator" do
        let!(:admin_member) { create(:project_member, project: project, email: user.email_address, role: "administrator", invitation_accepted: true) }

        it "successfully deletes scenario" do
          expect {
            delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}", headers: api_headers(user.api_token)
          }.to change(Scenario, :count).by(-1)
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
