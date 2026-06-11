class SitemapsController < ApplicationController
  skip_before_action :require_authentication
  skip_after_action :verify_authorized

  def show
    @base_url = request.base_url
    respond_to :xml
  end
end
