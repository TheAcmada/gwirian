require "rails_helper"

RSpec.describe "Api::V1::Projects", type: :request do
  describe "GET /api/v1/projects" do
    context "without authentication" do
      it "returns unauthorized" do
        get "/api/v1/projects"
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with invalid token" do
      it "returns unauthorized" do
        get "/api/v1/projects", headers: api_headers("invalid_token")
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with expired token" do
      let(:workspace) { create(:workspace) }
      let(:user) { create(:user) }
      let!(:workspace_member) { create(:workspace_member, :with_expired_api_token, user: user, workspace: workspace) }

      it "returns unauthorized" do
        get "/api/v1/projects", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      let(:workspace) { create(:workspace) }
      let(:user) { create(:user) }
      let!(:workspace_member) { create(:workspace_member, :with_api_token, user: user, workspace: workspace) }
      let!(:project1) { create(:project, name: "Project 1", workspace: workspace) }
      let!(:project2) { create(:project, name: "Project 2", workspace: workspace) }
      let!(:other_project) { create(:project, name: "Other Project", workspace: workspace) }
      let!(:member1) { create(:project_member, project: project1, email: user.email_address, ) }
      let!(:member2) { create(:project_member, project: project2, email: user.email_address, ) }
      let!(:other_member) { create(:project_member, project: other_project, email: "other@example.com", ) }

      it "returns only projects where user is a member" do
        get "/api/v1/projects", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to eq(2)
        project_ids = json_response.map { |p| p["id"] }
        expect(project_ids).to contain_exactly(project1.id, project2.id)
      end

      it "returns correct JSON structure" do
        get "/api/v1/projects", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:ok)
        project = json_response.first
        expect(project).to have_key("id")
        expect(project).to have_key("name")
        expect(project).to have_key("description")
        expect(project).to have_key("created_at")
        expect(project).to have_key("updated_at")
        expect(project).not_to have_key("project_members")
      end

      it "excludes projects where user is not a member" do
        get "/api/v1/projects", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:ok)
        project_ids = json_response.map { |p| p["id"] }
        expect(project_ids).not_to include(other_project.id)
      end

      context "when user has no projects" do
        let(:workspace_without_projects) { create(:workspace) }
        let(:user_without_projects) { create(:user) }
        let!(:workspace_member_without_projects) { create(:workspace_member, :with_api_token, user: user_without_projects, workspace: workspace_without_projects) }

        it "returns empty array" do
          get "/api/v1/projects", headers: api_headers(workspace_member_without_projects.api_token)
          expect(response).to have_http_status(:ok)
          expect(json_response).to eq([])
        end
      end
    end
  end

  describe "GET /api/v1/projects/:project_id" do
    let(:workspace) { create(:workspace) }
    let(:user) { create(:user) }
    let!(:workspace_member) { create(:workspace_member, :with_api_token, user: user, workspace: workspace) }
    let(:project) { create(:project, name: "Test Project", description: "Test Description", workspace: workspace) }
    let!(:member) { create(:project_member, project: project, email: user.email_address, ) }

    context "without authentication" do
      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}"
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with invalid token" do
      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}", headers: api_headers("invalid_token")
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      it "returns project details for member" do
        get "/api/v1/projects/#{project.id}", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response["id"]).to eq(project.id)
        expect(json_response["name"]).to eq("Test Project")
        expect(json_response["description"]).to eq("Test Description")
      end

      it "returns correct JSON structure" do
        get "/api/v1/projects/#{project.id}", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key("id")
        expect(json_response).to have_key("name")
        expect(json_response).to have_key("description")
        expect(json_response).to have_key("created_at")
        expect(json_response).to have_key("updated_at")
        expect(json_response).not_to have_key("project_members")
      end

      context "when project does not exist" do
        it "returns 404" do
          get "/api/v1/projects/99999", headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Project not found")
        end
      end

      context "when user is not a member of the project" do
        let(:other_workspace) { create(:workspace) }
        let(:other_user) { create(:user) }
        let!(:other_workspace_member) { create(:workspace_member, :with_api_token, user: other_user, workspace: other_workspace) }
        let(:other_project) { create(:project, workspace: other_workspace) }

        it "returns 404" do
          get "/api/v1/projects/#{other_project.id}", headers: api_headers(other_workspace_member.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Project not found")
        end
      end
    end
  end
end
