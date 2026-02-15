require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /users/new" do
    it "returns success" do
      get "/users/new"
      expect(response).to have_http_status(:ok)
    end

    it "renders the new template" do
      get "/users/new"
      expect(response).to render_template(:new)
    end

    it "assigns a new user" do
      get "/users/new"
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "POST /users" do
    let(:valid_params) do
      {
        user: {
          email_address: "newuser@example.com"
        }
      }
    end

    context "with valid params" do
      it "creates a new user and redirects to magic link page" do
        expect {
          post "/users", params: valid_params
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(session_magic_link_path)
      end

      it "sends welcome email to the new user" do
        allow(UserMailer).to receive(:welcome).and_return(double(deliver_later: true))

        post "/users", params: valid_params
        user = User.find_by(email_address: "newuser@example.com")

        expect(UserMailer).to have_received(:welcome).with(user)
      end

      context "when signup notification email is configured" do
        before do
          signup_config = double(notify_email: "admin@example.com")
          allow(Rails.application.config).to receive(:signup).and_return(signup_config)
          allow(UserMailer).to receive(:signup_notification).and_return(double(deliver_later: true))
        end

        it "sends signup notification email" do
          post "/users", params: valid_params
          user = User.find_by(email_address: "newuser@example.com")
          expect(UserMailer).to have_received(:signup_notification).with(user)
        end
      end
    end

    context "with invalid params" do
      it "does not create a user with duplicate email" do
        create(:user, email_address: "existing@example.com")
        invalid_params = {
          user: {
            email_address: "existing@example.com"
          }
        }

        # Existing user should redirect to magic link (same flow)
        expect {
          post "/users", params: invalid_params
        }.not_to change(User, :count)

        expect(response).to redirect_to(session_magic_link_path)
      end

      it "does not create a user with invalid email format" do
        invalid_params = {
          user: {
            email_address: "not-an-email"
          }
        }

        expect {
          post "/users", params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end

      it "does not create a user with blank email" do
        invalid_params = {
          user: {
            email_address: ""
          }
        }

        expect {
          post "/users", params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end
    end

    context "with spam detection (honeypot)" do
      it "redirects with alert when nickname field is filled" do
        spam_params = valid_params.merge(user: valid_params[:user].merge(nickname: "spam"))
        post "/users", params: spam_params
        expect(response).to redirect_to(new_user_path)
        follow_redirect!
        expect(response.body).to include("Something went wrong")
      end
    end

    context "with rate limiting" do
      it "has rate limiting configured on create action" do
        post "/users", params: valid_params
        expect(response).to have_http_status(:redirect)
        expect(User.count).to eq(1)
      end
    end
  end

  describe "GET /users/:id/edit" do
    let(:user) { create(:user) }

    context "when authenticated" do
      before do
        sign_in_as(user)
      end

      it "returns success" do
        get "/users/#{user.id}/edit"
        expect(response).to have_http_status(:ok)
      end

      it "renders the edit template" do
        get "/users/#{user.id}/edit"
        expect(response).to render_template(:edit)
      end

      it "assigns the current user" do
        get "/users/#{user.id}/edit"
        expect(assigns(:user)).to eq(user)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get "/users/#{user.id}/edit"
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "PATCH /users/:id" do
    let(:user) { create(:user) }

    context "when authenticated" do
      before do
        sign_in_as(user)
      end

      context "with valid params" do
        let(:update_params) do
          {
            user: {
              email_address: "updated@example.com"
            }
          }
        end

        it "updates the user" do
          patch "/users/#{user.id}", params: update_params
          user.reload
          expect(user.email_address).to eq("updated@example.com")
        end

        it "redirects to edit path with success notice" do
          patch "/users/#{user.id}", params: update_params
          expect(response).to redirect_to(edit_user_path(user))
        end
      end

      context "with invalid params" do
        it "does not update the user with invalid email" do
          original_email = user.email_address
          invalid_params = {
            user: {
              email_address: "not-an-email"
            }
          }
          patch "/users/#{user.id}", params: invalid_params
          user.reload
          expect(user.email_address).to eq(original_email)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:edit)
        end
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        patch "/users/#{user.id}", params: { user: { email_address: "test@example.com" } }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "DELETE /users/:id" do
    let(:user) { create(:user) }

    it "returns 404 Not Found (route not implemented)" do
      sign_in_as(user)
      delete "/users/#{user.id}"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when not authenticated" do
      delete "/users/#{user.id}"
      expect(response).to have_http_status(:not_found)
    end
  end
end
