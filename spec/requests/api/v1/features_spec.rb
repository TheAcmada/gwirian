require "rails_helper"

RSpec.describe "Api::V1::Features", type: :request do
  let(:user) { create(:user, :with_api_token) }
  let(:project) { create(:project) }

  describe "GET /api/v1/projects/:project_id/features" do
    context "without authentication" do
      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features"
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with invalid token" do
      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features", headers: api_headers("invalid_token")
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with expired token" do
      let(:expired_user) { create(:user, :with_expired_api_token) }

      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features", headers: api_headers(expired_user.api_token)
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      let!(:member) { create(:project_member, project: project, email: user.email_address, ) }
      let!(:feature1) { create(:feature, project: project, title: "Feature A") }
      let!(:feature2) { create(:feature, project: project, title: "Feature B") }
      let!(:feature3) { create(:feature, project: project, title: "Feature C") }

      it "returns features for project" do
        get "/api/v1/projects/#{project.id}/features", headers: api_headers(user.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to eq(3)
      end

      it "returns features ordered by title" do
        get "/api/v1/projects/#{project.id}/features", headers: api_headers(user.api_token)
        expect(response).to have_http_status(:ok)
        titles = json_response.map { |f| f["title"] }
        expect(titles).to eq([ "Feature A", "Feature B", "Feature C" ])
      end

      it "returns correct JSON structure" do
        get "/api/v1/projects/#{project.id}/features", headers: api_headers(user.api_token)
        expect(response).to have_http_status(:ok)
        feature = json_response.first
        expect(feature).to have_key("id")
        expect(feature).to have_key("title")
        expect(feature).to have_key("description")
        expect(feature).to have_key("created_at")
        expect(feature).to have_key("updated_at")
        expect(feature).to have_key("project_id")
      end

      context "when project does not exist" do
        it "returns 404" do
          get "/api/v1/projects/99999/features", headers: api_headers(user.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Project not found")
        end
      end

      context "when user is not a member of the project" do
        let(:other_user) { create(:user, :with_api_token) }
        let(:other_project) { create(:project) }
        let!(:other_feature) { create(:feature, project: other_project) }

        it "returns 404" do
          get "/api/v1/projects/#{other_project.id}/features", headers: api_headers(other_user.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Project not found")
        end
      end
    end
  end

  describe "GET /api/v1/projects/:project_id/features/:id" do
    let!(:member) { create(:project_member, project: project, email: user.email_address, ) }
    let(:feature) { create(:feature, project: project, title: "Test Feature", description: "Test Description") }

    context "without authentication" do
      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}"
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      it "returns feature details" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}", headers: api_headers(user.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response["id"]).to eq(feature.id)
        expect(json_response["title"]).to eq("Test Feature")
        expect(json_response["description"]).to eq("Test Description")
        expect(json_response["project_id"]).to eq(project.id)
      end

      it "returns correct JSON structure" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}", headers: api_headers(user.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key("id")
        expect(json_response).to have_key("title")
        expect(json_response).to have_key("description")
        expect(json_response).to have_key("created_at")
        expect(json_response).to have_key("updated_at")
        expect(json_response).to have_key("project_id")
      end

      context "when feature does not exist" do
        it "returns 404" do
          get "/api/v1/projects/#{project.id}/features/99999", headers: api_headers(user.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Feature not found")
        end
      end

      context "when feature belongs to different project" do
        let(:other_project) { create(:project) }
        let(:other_feature) { create(:feature, project: other_project) }
        let!(:other_member) { create(:project_member, project: other_project, email: user.email_address, ) }

        it "returns 404" do
          get "/api/v1/projects/#{project.id}/features/#{other_feature.id}", headers: api_headers(user.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Feature not found")
        end
      end
    end
  end

  describe "POST /api/v1/projects/:project_id/features" do
    let(:valid_params) do
      {
        feature: {
          title: "New Feature",
          description: "New Feature Description",
          tag_list: "tag1, tag2"
        }
      }
    end

    context "without authentication" do
      it "returns unauthorized" do
        post "/api/v1/projects/#{project.id}/features", params: valid_params
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      context "as viewer" do
        let!(:viewer_member) { create(:project_member, project: project, email: user.email_address, role: "viewer", ) }

        it "returns 403 forbidden" do
          post "/api/v1/projects/#{project.id}/features", params: valid_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:forbidden)
          expect(json_response["error"]).to eq("Access denied")
        end
      end

      context "as editor" do
        let!(:editor_member) { create(:project_member, project: project, email: user.email_address, role: "editor", ) }

        it "successfully creates feature with valid params" do
          expect {
            post "/api/v1/projects/#{project.id}/features", params: valid_params, headers: api_headers(user.api_token)
          }.to change(Feature, :count).by(1)
          expect(response).to have_http_status(:created)
        end

        it "returns 201 with created feature" do
          post "/api/v1/projects/#{project.id}/features", params: valid_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:created)
          expect(json_response["title"]).to eq("New Feature")
          expect(json_response["description"]).to eq("New Feature Description")
          expect(json_response["project_id"]).to eq(project.id)
        end

        it "handles tag_list parameter" do
          post "/api/v1/projects/#{project.id}/features", params: valid_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:created)
          feature = Feature.find(json_response["id"])
          expect(feature.tag_list).to contain_exactly("tag1", "tag2")
        end

        context "with validation errors" do
          it "fails with missing title" do
            invalid_params = { feature: { description: "Description only" } }
            post "/api/v1/projects/#{project.id}/features", params: invalid_params, headers: api_headers(user.api_token)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response["errors"]).to be_present
            expect(json_response["errors"]).to include("Title can't be blank")
          end

          it "fails with too long description" do
            long_description = "a" * 1001
            invalid_params = { feature: { title: "Title", description: long_description } }
            post "/api/v1/projects/#{project.id}/features", params: invalid_params, headers: api_headers(user.api_token)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response["errors"]).to be_present
          end
        end

        context "when project does not exist" do
          it "returns 404" do
            post "/api/v1/projects/99999/features", params: valid_params, headers: api_headers(user.api_token)
            expect(response).to have_http_status(:not_found)
            expect(json_response["error"]).to eq("Project not found")
          end
        end
      end

      context "as administrator" do
        let!(:admin_member) { create(:project_member, project: project, email: user.email_address, role: "administrator", ) }

        it "successfully creates feature" do
          expect {
            post "/api/v1/projects/#{project.id}/features", params: valid_params, headers: api_headers(user.api_token)
          }.to change(Feature, :count).by(1)
          expect(response).to have_http_status(:created)
        end
      end
    end
  end

  describe "PATCH /api/v1/projects/:project_id/features/:id" do
    let(:feature) { create(:feature, project: project, title: "Original Title", description: "Original Description") }
    let(:update_params) do
      {
        feature: {
          title: "Updated Title",
          description: "Updated Description",
          tag_list: "updated_tag1, updated_tag2"
        }
      }
    end

    context "without authentication" do
      it "returns unauthorized" do
        patch "/api/v1/projects/#{project.id}/features/#{feature.id}", params: update_params
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      context "as viewer" do
        let!(:viewer_member) { create(:project_member, project: project, email: user.email_address, role: "viewer", ) }

        it "returns 403 forbidden" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}", params: update_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:forbidden)
          expect(json_response["error"]).to eq("Access denied")
        end
      end

      context "as editor" do
        let!(:editor_member) { create(:project_member, project: project, email: user.email_address, role: "editor", ) }

        it "successfully updates feature with valid params" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}", params: update_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:ok)
          feature.reload
          expect(feature.title).to eq("Updated Title")
          expect(feature.description).to eq("Updated Description")
        end

        it "returns updated feature JSON" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}", params: update_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:ok)
          expect(json_response["title"]).to eq("Updated Title")
          expect(json_response["description"]).to eq("Updated Description")
        end

        it "handles tag_list parameter" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}", params: update_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:ok)
          feature.reload
          expect(feature.tag_list).to contain_exactly("updated_tag1", "updated_tag2")
        end

        context "with validation errors" do
          it "fails with missing title" do
            invalid_params = { feature: { title: "" } }
            patch "/api/v1/projects/#{project.id}/features/#{feature.id}", params: invalid_params, headers: api_headers(user.api_token)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response["errors"]).to be_present
            expect(json_response["errors"]).to include("Title can't be blank")
          end
        end

        context "when feature does not exist" do
          it "returns 404" do
            patch "/api/v1/projects/#{project.id}/features/99999", params: update_params, headers: api_headers(user.api_token)
            expect(response).to have_http_status(:not_found)
            expect(json_response["error"]).to eq("Feature not found")
          end
        end
      end

      context "as administrator" do
        let!(:admin_member) { create(:project_member, project: project, email: user.email_address, role: "administrator", ) }

        it "successfully updates feature" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}", params: update_params, headers: api_headers(user.api_token)
          expect(response).to have_http_status(:ok)
          feature.reload
          expect(feature.title).to eq("Updated Title")
        end
      end
    end
  end

  describe "DELETE /api/v1/projects/:project_id/features/:id" do
    let!(:feature) { create(:feature, project: project) }

    context "without authentication" do
      it "returns unauthorized" do
        delete "/api/v1/projects/#{project.id}/features/#{feature.id}"
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      context "as viewer" do
        let!(:viewer_member) { create(:project_member, project: project, email: user.email_address, role: "viewer", ) }

        it "returns 403 forbidden" do
          delete "/api/v1/projects/#{project.id}/features/#{feature.id}", headers: api_headers(user.api_token)
          expect(response).to have_http_status(:forbidden)
          expect(json_response["error"]).to eq("Access denied")
        end
      end

      context "as editor" do
        let!(:editor_member) { create(:project_member, project: project, email: user.email_address, role: "editor", ) }

        it "successfully deletes feature" do
          expect {
            delete "/api/v1/projects/#{project.id}/features/#{feature.id}", headers: api_headers(user.api_token)
          }.to change(Feature, :count).by(-1)
          expect(response).to have_http_status(:ok)
        end

        it "returns success message" do
          delete "/api/v1/projects/#{project.id}/features/#{feature.id}", headers: api_headers(user.api_token)
          expect(response).to have_http_status(:ok)
          expect(json_response["message"]).to eq("Feature deleted successfully")
        end

        it "feature is actually deleted from database" do
          feature_id = feature.id
          delete "/api/v1/projects/#{project.id}/features/#{feature.id}", headers: api_headers(user.api_token)
          expect(Feature.find_by(id: feature_id)).to be_nil
        end

        context "when feature does not exist" do
          it "returns 404" do
            delete "/api/v1/projects/#{project.id}/features/99999", headers: api_headers(user.api_token)
            expect(response).to have_http_status(:not_found)
            expect(json_response["error"]).to eq("Feature not found")
          end
        end
      end

      context "as administrator" do
        let!(:admin_member) { create(:project_member, project: project, email: user.email_address, role: "administrator", ) }

        it "successfully deletes feature" do
          expect {
            delete "/api/v1/projects/#{project.id}/features/#{feature.id}", headers: api_headers(user.api_token)
          }.to change(Feature, :count).by(-1)
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
