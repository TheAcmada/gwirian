require "rails_helper"

RSpec.describe "Api::V1::ScenarioExecutions", type: :request do
  let(:workspace) { create(:workspace) }
  let(:user) { create(:user) }
  let!(:workspace_member) { create(:workspace_member, :with_api_token, user: user, workspace: workspace) }
  let(:project) { create(:project, workspace: workspace) }
  let(:feature) { create(:feature, project: project) }
  let(:scenario) { create(:scenario, feature: feature) }

  describe "GET /api/v1/projects/:project_id/features/:feature_id/scenarios/:scenario_id/scenario_executions" do
    context "without authentication" do
      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions"
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with invalid token" do
      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", headers: api_headers("invalid_token")
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with expired token" do
      let(:expired_workspace) { create(:workspace) }
      let(:expired_user) { create(:user) }
      let!(:expired_workspace_member) { create(:workspace_member, :with_expired_api_token, user: expired_user, workspace: expired_workspace) }

      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", headers: api_headers(expired_workspace_member.api_token)
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      let!(:member) { create(:project_member, project: project, email: user.email_address,) }
      let!(:execution1) { create(:scenario_execution, scenario: scenario, status: "passed", executed_at: 3.days.ago, user: user) }
      let!(:execution2) { create(:scenario_execution, scenario: scenario, status: "failed", executed_at: 2.days.ago, user: user) }
      let!(:execution3) { create(:scenario_execution, scenario: scenario, status: "pending", executed_at: 1.day.ago, user: user) }

      it "returns scenario executions for scenario" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response.length).to eq(3)
      end

      it "returns scenario executions ordered by executed_at desc" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:ok)
        statuses = json_response.map { |e| e["status"] }
        expect(statuses).to eq([ "pending", "failed", "passed" ])
      end

      it "returns correct JSON structure" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:ok)
        execution = json_response.first
        expect(execution).to have_key("id")
        expect(execution).to have_key("scenario_id")
        expect(execution).to have_key("user_id")
        expect(execution).to have_key("status")
        expect(execution).to have_key("notes")
        expect(execution).to have_key("executed_at")
        expect(execution).to have_key("tag_list")
        expect(execution).to have_key("created_at")
        expect(execution).to have_key("updated_at")
      end

      context "when project does not exist" do
        it "returns 404" do
          get "/api/v1/projects/99999/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Project not found")
        end
      end

      context "when feature does not exist" do
        it "returns 404" do
          get "/api/v1/projects/#{project.id}/features/99999/scenarios/#{scenario.id}/scenario_executions", headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Feature not found")
        end
      end

      context "when scenario does not exist" do
        it "returns 404" do
          get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/99999/scenario_executions", headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Scenario not found")
        end
      end

      context "when user is not a member of the project" do
        let(:other_workspace) { create(:workspace) }
        let(:other_user) { create(:user) }
        let!(:other_workspace_member) { create(:workspace_member, :with_api_token, user: other_user, workspace: other_workspace) }
        let(:other_project) { create(:project, workspace: other_workspace) }
        let(:other_feature) { create(:feature, project: other_project) }
        let(:other_scenario) { create(:scenario, feature: other_feature) }
        let!(:other_execution) { create(:scenario_execution, scenario: other_scenario, user: other_user) }

        it "returns 404" do
          get "/api/v1/projects/#{other_project.id}/features/#{other_feature.id}/scenarios/#{other_scenario.id}/scenario_executions", headers: api_headers(other_workspace_member.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Project not found")
        end
      end
    end
  end

  describe "GET /api/v1/projects/:project_id/features/:feature_id/scenarios/:scenario_id/scenario_executions/:id" do
    let!(:member) { create(:project_member, project: project, email: user.email_address,) }
    let(:scenario_execution) { create(:scenario_execution, scenario: scenario, status: "passed", notes: "Test notes", executed_at: Time.current, user: user) }

    context "without authentication" do
      it "returns unauthorized" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}"
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      it "returns scenario execution details" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response["id"]).to eq(scenario_execution.id)
        expect(json_response["status"]).to eq("passed")
        expect(json_response["notes"]).to eq("Test notes")
        expect(json_response["scenario_id"]).to eq(scenario.id)
        expect(json_response["user_id"]).to eq(user.id)
      end

      it "returns correct JSON structure" do
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key("id")
        expect(json_response).to have_key("scenario_id")
        expect(json_response).to have_key("user_id")
        expect(json_response).to have_key("status")
        expect(json_response).to have_key("notes")
        expect(json_response).to have_key("executed_at")
        expect(json_response).to have_key("tag_list")
        expect(json_response).to have_key("created_at")
        expect(json_response).to have_key("updated_at")
      end

      it "returns tag_list when execution has tags" do
        scenario_execution.tag_list = "e2e, smoke"
        scenario_execution.save!
        get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", headers: api_headers(workspace_member.api_token)
        expect(response).to have_http_status(:ok)
        expect(json_response["tag_list"]).to contain_exactly("e2e", "smoke")
      end

      context "when scenario execution does not exist" do
        it "returns 404" do
          get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/99999", headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Scenario execution not found")
        end
      end

      context "when scenario execution belongs to different scenario" do
        let(:other_scenario) { create(:scenario, feature: feature) }
        let(:other_execution) { create(:scenario_execution, scenario: other_scenario, user: user) }

        it "returns 404" do
          get "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{other_execution.id}", headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:not_found)
          expect(json_response["error"]).to eq("Scenario execution not found")
        end
      end
    end
  end

  describe "POST /api/v1/projects/:project_id/features/:feature_id/scenarios/:scenario_id/scenario_executions" do
    let(:valid_params) do
      {
        scenario_execution: {
          status: "passed",
          notes: "Execution notes",
          executed_at: Time.current.iso8601
        }
      }
    end

    context "without authentication" do
      it "returns unauthorized" do
        post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", params: valid_params
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      context "as viewer" do
        let!(:viewer_member) { create(:project_member, project: project, email: user.email_address, role: "viewer",) }

        it "returns 403 forbidden" do
          post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", params: valid_params, headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:forbidden)
          expect(json_response["error"]).to eq("Access denied")
        end
      end

      context "as editor" do
        let!(:editor_member) { create(:project_member, project: project, email: user.email_address, role: "editor",) }

        it "successfully creates scenario execution with valid params" do
          expect {
            post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", params: valid_params, headers: api_headers(workspace_member.api_token)
          }.to change(ScenarioExecution, :count).by(1)
          expect(response).to have_http_status(:created)
        end

        it "returns 201 with created scenario execution" do
          post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", params: valid_params, headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:created)
          expect(json_response["status"]).to eq("passed")
          expect(json_response["notes"]).to eq("Execution notes")
          expect(json_response["scenario_id"]).to eq(scenario.id)
          expect(json_response["user_id"]).to eq(user.id)
          expect(json_response).to have_key("tag_list")
        end

        it "creates scenario execution with tag_list" do
          params_with_tags = valid_params.deep_dup
          params_with_tags[:scenario_execution][:tag_list] = "e2e, v1.2.3"
          post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", params: params_with_tags, headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:created)
          expect(json_response["tag_list"]).to contain_exactly("e2e", "v1.2.3")
        end

        it "automatically sets user_id to current_user" do
          post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", params: valid_params, headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:created)
          execution = ScenarioExecution.find(json_response["id"])
          expect(execution.user_id).to eq(user.id)
        end

        context "with validation errors" do
          it "defaults to pending status when status is not provided" do
            invalid_params = { scenario_execution: { notes: "Notes", executed_at: Time.current.iso8601 } }
            post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", params: invalid_params, headers: api_headers(workspace_member.api_token)
            expect(response).to have_http_status(:created)
            expect(json_response["status"]).to eq("pending")
          end

          it "fails with invalid status" do
            invalid_params = { scenario_execution: { status: "invalid", executed_at: Time.current.iso8601 } }
            post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", params: invalid_params, headers: api_headers(workspace_member.api_token)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response["errors"]).to be_present
          end

          it "fails with missing executed_at" do
            invalid_params = { scenario_execution: { status: "passed" } }
            post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", params: invalid_params, headers: api_headers(workspace_member.api_token)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response["errors"]).to be_present
            expect(json_response["errors"]).to include("Executed at can't be blank")
          end
        end

        context "when project does not exist" do
          it "returns 404" do
            post "/api/v1/projects/99999/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", params: valid_params, headers: api_headers(workspace_member.api_token)
            expect(response).to have_http_status(:not_found)
            expect(json_response["error"]).to eq("Project not found")
          end
        end

        context "when scenario does not exist" do
          it "returns 404" do
            post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/99999/scenario_executions", params: valid_params, headers: api_headers(workspace_member.api_token)
            expect(response).to have_http_status(:not_found)
            expect(json_response["error"]).to eq("Scenario not found")
          end
        end
      end

      context "as administrator" do
        let!(:admin_member) { create(:project_member, project: project, email: user.email_address, role: "administrator",) }

        it "successfully creates scenario execution" do
          expect {
            post "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions", params: valid_params, headers: api_headers(workspace_member.api_token)
          }.to change(ScenarioExecution, :count).by(1)
          expect(response).to have_http_status(:created)
        end
      end
    end
  end

  describe "PATCH /api/v1/projects/:project_id/features/:feature_id/scenarios/:scenario_id/scenario_executions/:id" do
    let(:scenario_execution) { create(:scenario_execution, scenario: scenario, status: "pending", notes: "Original notes", executed_at: Time.current, user: user) }
    let(:update_params) do
      {
        scenario_execution: {
          status: "passed",
          notes: "Updated notes",
          executed_at: 1.hour.ago.iso8601
        }
      }
    end

    context "without authentication" do
      it "returns unauthorized" do
        patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", params: update_params
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      context "as viewer" do
        let!(:viewer_member) { create(:project_member, project: project, email: user.email_address, role: "viewer",) }

        it "returns 403 forbidden" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", params: update_params, headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:forbidden)
          expect(json_response["error"]).to eq("Access denied")
        end
      end

      context "as editor" do
        let!(:editor_member) { create(:project_member, project: project, email: user.email_address, role: "editor",) }

        it "successfully updates scenario execution with valid params" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", params: update_params, headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:ok)
          scenario_execution.reload
          expect(scenario_execution.status).to eq("passed")
          expect(scenario_execution.notes).to eq("Updated notes")
        end

        it "returns updated scenario execution JSON" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", params: update_params, headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:ok)
          expect(json_response["status"]).to eq("passed")
          expect(json_response["notes"]).to eq("Updated notes")
          expect(json_response).to have_key("tag_list")
        end

        it "updates scenario execution with tag_list" do
          params_with_tags = update_params.deep_dup
          params_with_tags[:scenario_execution][:tag_list] = "e2e, bugfix-123"
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", params: params_with_tags, headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:ok)
          expect(json_response["tag_list"]).to contain_exactly("e2e", "bugfix-123")
        end

        context "with validation errors" do
          it "fails with invalid status" do
            invalid_params = { scenario_execution: { status: "invalid" } }
            patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", params: invalid_params, headers: api_headers(workspace_member.api_token)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response["errors"]).to be_present
          end

          it "fails with missing executed_at" do
            invalid_params = { scenario_execution: { executed_at: nil } }
            patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", params: invalid_params, headers: api_headers(workspace_member.api_token)
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response["errors"]).to be_present
          end
        end

        context "when scenario execution does not exist" do
          it "returns 404" do
            patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/99999", params: update_params, headers: api_headers(workspace_member.api_token)
            expect(response).to have_http_status(:not_found)
            expect(json_response["error"]).to eq("Scenario execution not found")
          end
        end
      end

      context "as administrator" do
        let!(:admin_member) { create(:project_member, project: project, email: user.email_address, role: "administrator",) }

        it "successfully updates scenario execution" do
          patch "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", params: update_params, headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:ok)
          scenario_execution.reload
          expect(scenario_execution.status).to eq("passed")
        end
      end
    end
  end

  describe "DELETE /api/v1/projects/:project_id/features/:feature_id/scenarios/:scenario_id/scenario_executions/:id" do
    let!(:scenario_execution) { create(:scenario_execution, scenario: scenario, user: user) }

    context "without authentication" do
      it "returns unauthorized" do
        delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}"
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to eq("Unauthorized")
      end
    end

    context "with valid authentication" do
      context "as viewer" do
        let!(:viewer_member) { create(:project_member, project: project, email: user.email_address, role: "viewer",) }

        it "returns 403 forbidden" do
          delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:forbidden)
          expect(json_response["error"]).to eq("Access denied")
        end
      end

      context "as editor" do
        let!(:editor_member) { create(:project_member, project: project, email: user.email_address, role: "editor",) }

        it "successfully deletes scenario execution" do
          expect {
            delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", headers: api_headers(workspace_member.api_token)
          }.to change(ScenarioExecution, :count).by(-1)
          expect(response).to have_http_status(:ok)
        end

        it "returns success message" do
          delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", headers: api_headers(workspace_member.api_token)
          expect(response).to have_http_status(:ok)
          expect(json_response["message"]).to eq("Scenario execution deleted successfully")
        end

        it "scenario execution is actually deleted from database" do
          execution_id = scenario_execution.id
          delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", headers: api_headers(workspace_member.api_token)
          expect(ScenarioExecution.find_by(id: execution_id)).to be_nil
        end

        context "when scenario execution does not exist" do
          it "returns 404" do
            delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/99999", headers: api_headers(workspace_member.api_token)
            expect(response).to have_http_status(:not_found)
            expect(json_response["error"]).to eq("Scenario execution not found")
          end
        end
      end

      context "as administrator" do
        let!(:admin_member) { create(:project_member, project: project, email: user.email_address, role: "administrator",) }

        it "successfully deletes scenario execution" do
          expect {
            delete "/api/v1/projects/#{project.id}/features/#{feature.id}/scenarios/#{scenario.id}/scenario_executions/#{scenario_execution.id}", headers: api_headers(workspace_member.api_token)
          }.to change(ScenarioExecution, :count).by(-1)
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
