FactoryBot.define do
  factory :task_distribution do
    assigner { build(:user, :admin) }
    assignee { build(:user) }
  end
end
