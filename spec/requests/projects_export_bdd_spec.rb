# frozen_string_literal: true

require "rails_helper"
require "zip"

RSpec.describe "Projects export BDD", type: :request do
  let(:workspace) { create(:workspace) }
  let(:user) { create(:user) }
  let!(:workspace_member) { create(:workspace_member, user: user, workspace: workspace) }
  let(:project) { create(:project, workspace: workspace, name: "Export Test") }
  let!(:project_member) { create(:project_member, project: project, email: user.email_address) }

  def export_bdd_url
    "/#{workspace.slug}/projects/#{project.id}/export_bdd"
  end

  context "when authenticated and member of the project" do
    before { sign_in_as(user) }

    it "returns 200 with a ZIP file" do
      get export_bdd_url
      expect(response).to have_http_status(:ok)
    end

    it "returns Content-Type application/zip" do
      get export_bdd_url
      expect(response.media_type).to eq("application/zip")
    end

    it "returns Content-Disposition attachment with zip filename" do
      get export_bdd_url
      expect(response.headers["Content-Disposition"]).to match(/attachment.*export-test\.zip/)
    end

    it "returns a valid ZIP body containing project_info and feature files" do
      create(:feature, project: project, title: "Login")
      get export_bdd_url
      expect(response).to have_http_status(:ok)
      buffer = response.body
      expect(buffer).to be_present
      expect(buffer.bytesize).to be > 0
      # Minimal ZIP magic bytes
      expect(buffer[0, 2]).to eq("PK")
      # Parse ZIP and collect entry names
      entries = []
      Zip::InputStream.open(StringIO.new(buffer)) do |z|
        while (entry = z.get_next_entry)
          entries << entry.name
        end
      end
      expect(entries).to include("project_info.md")
      expect(entries).to include("login.feature")
    end
  end

  context "when not authenticated" do
    it "redirects to login" do
      get export_bdd_url
      expect(response).to have_http_status(:redirect)
      expect(response.redirect_url).to match(%r{/session/new})
    end
  end

  context "when authenticated but not a project member" do
    let(:other_user) { create(:user) }
    before do
      create(:workspace_member, user: other_user, workspace: workspace)
      sign_in_as(other_user)
    end

    it "returns 404 (project not in accessible list)" do
      get export_bdd_url
      expect(response).to have_http_status(:not_found)
    end
  end
end
