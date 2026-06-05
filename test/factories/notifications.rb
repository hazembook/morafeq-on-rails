FactoryBot.define do
  factory :notification do
    recipient { association(:user) }
    actor { association(:user) }
    action { "new_post" }
    notifiable { association(:post) }
  end
end
