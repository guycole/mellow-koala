FactoryBot.define do
  factory :component do
    sequence(:component_id) { |n| "mellow-component-#{n}" }
    sequence(:display_name) { |n| "Mellow Component #{n}" }
    sequence(:slug) { |n| "mellow-component-#{n}" }
    ingest_token { "test-token-#{SecureRandom.hex(8)}" }
    description { "A mellow component for testing" }
    collector { false }

    trait :collector do
      collector { true }
    end
  end
end
