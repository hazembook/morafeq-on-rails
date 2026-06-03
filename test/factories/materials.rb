FactoryBot.define do
  factory :material do
    sequence(:title) { |n| "Material #{n}" }
    subject

    trait :with_file do
      after(:build) do |material|
        material.file.attach(
          io: StringIO.new("test content"),
          filename: "test.pdf",
          content_type: "application/pdf"
        )
      end
    end
  end
end
