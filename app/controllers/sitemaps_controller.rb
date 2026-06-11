class SitemapsController < ApplicationController
  skip_before_action :require_authentication

  def show
    skip_authorization
    @base_url = request.base_url
    respond_to :xml
  end
end
