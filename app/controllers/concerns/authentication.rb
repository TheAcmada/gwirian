module Authentication
  extend ActiveSupport::Concern
  include Authentication::ViaMagicLink

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      return nil unless cookies.signed[:session_id]
      session = Session.valid.find_by(id: cookies.signed[:session_id])
      # If session is expired, destroy it
      if session&.expired?
        session.destroy
        cookies.delete(:session_id)
        return nil
      end
      session
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      return_to = session.delete(:return_to_after_authenticating)
      return return_to if return_to.present?

      # Find user's default workspace
      workspace = default_workspace_for_user
      return root_url unless workspace

      "#{root_url}#{workspace.slug}/projects"
    end

    def default_workspace_for_user
      return nil unless Current.user

      # Find last accessed workspace (only current members)
      last_accessed = Current.user.workspace_members
                                  .current_member
                                  .where.not(last_accessed_at: nil)
                                  .order(last_accessed_at: :desc)
                                  .first&.workspace

      # Fall back to first current member workspace
      last_accessed || Current.user.workspace_members.current_member.first&.workspace
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
