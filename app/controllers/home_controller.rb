class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    set_meta_tags title: t("home.title"), description: t("home.description")
    redirect_to feed_index_path if authenticated?
  end
end
