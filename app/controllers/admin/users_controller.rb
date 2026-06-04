module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :edit, :update, :destroy ]

    def index
      @users = User.order(:full_name)
    end

    def show
    end

    def new
      @user = User.new
    end

    def edit
    end

    def create
      @user = User.new(user_params)
      if @user.save
        log_audit("create", @user)
        redirect_to admin_users_path, notice: t("flash.admin.user_created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @user.update(user_params)
        log_audit("update", @user)
        redirect_to admin_users_path, notice: t("flash.admin.user_updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == Current.user
        redirect_to admin_users_path, alert: t("flash.admin.cannot_delete_self")
      else
        changes = @user.attributes.except("updated_at", "created_at", "password_digest").to_json
        @user.destroy
        log_audit("destroy", @user, changes)
        redirect_to admin_users_path, notice: t("flash.admin.user_deleted")
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      permitted = [ :full_name, :email_address, :role, :bio ]
      permitted << :password if params[:user][:password].present?
      params.require(:user).permit(permitted)
    end
  end
end
