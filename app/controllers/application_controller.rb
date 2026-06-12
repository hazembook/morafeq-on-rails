class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :set_locale
  before_action :set_meta_tags_defaults

  def set_locale
    locale = params[:locale] || cookies[:locale] || session[:locale] || I18n.default_locale
    if I18n.available_locales.map(&:to_s).include?(locale.to_s)
      session[:locale] = locale.to_s
      cookies.permanent[:locale] = { value: locale.to_s, path: "/" }
      I18n.locale = locale.to_sym
    else
      session[:locale] = I18n.default_locale.to_s
      cookies.permanent[:locale] = { value: I18n.default_locale.to_s, path: "/" }
      I18n.locale = I18n.default_locale
    end
  end

  def current_user
    Current.user
  end

  private

  def user_not_authorized
    flash[:alert] = t("alerts.not_authorized")
    redirect_to root_path
  end

  def authorize_subject_show
    authorize @subject, :show?
  end

  def set_meta_tags_defaults
    set_meta_tags(
      site: t("app_name"),
      title: nil,
      description: t("og_description"),
      separator: "|",
      canonical: canonical_url,
      alternate: alternate_urls,
      og: {
        title: :full_title,
        description: :description,
        type: "website",
        url: request.original_url,
        image: {
          _: URI.join(request.base_url, "/morafeq-logo.png").to_s,
          width: 1024,
          height: 1024
        }
      },
      twitter: {
        card: "summary_large_image",
        image: URI.join(request.base_url, "/morafeq-logo.png").to_s
      }
    )
  end

  def canonical_url
    request.original_url.split("?").first
  end

  def alternate_urls
    result = {}
    I18n.available_locales.each do |locale|
      result[locale.to_s] = url_for(only_path: false, locale: locale)
    end
    result
  end
end
