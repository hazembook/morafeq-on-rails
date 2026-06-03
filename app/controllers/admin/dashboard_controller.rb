module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        colleges: College.count,
        departments: Department.count,
        subjects: Subject.count,
        users: User.count
      }
    end
  end
end
