module Authentication
  extend ActiveSupport::Concern

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
    LAST_USED_REFRESH_INTERVAL = 5.minutes

    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
      if Current.session&.expired?
        Current.session.destroy
        cookies.delete(:session_id)
        Current.session = nil
      elsif Current.session && should_refresh_last_used?
        Current.session.update_column(:last_used_at, Time.current)
      end
      Current.session
    end

    def find_session_by_cookie
      if cookie = cookies.signed[:session_id]
        Session.find_by(token: cookie)
      end
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed[:session_id] = {
          value: session.token,
          expires: session.expires_at,
          httponly: true,
          same_site: :lax
        }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end

    def should_refresh_last_used?
      Current.session.last_used_at.nil? ||
        Current.session.last_used_at < LAST_USED_REFRESH_INTERVAL.ago
    end
end
