class CspController < ApplicationController
  skip_before_action :set_locale
  skip_before_action :verify_authenticity_token

  def violation_report
    violation = JSON.parse(request.body.read) rescue {}
    Rails.logger.warn("[CSP VIOLATION] #{violation.inspect}")
    render json: {}, status: :no_content
  end
end
