FactoryBot.define do
  factory :collector do
    sequence(:collector_id) { |n| "mellow-collector-#{n}" }
    sequence(:display_name) { |n| "Mellow Collector #{n}" }
    sequence(:slug) { |n| "mellow-collector-#{n}" }
    ingest_token { "test-token-#{SecureRandom.hex(8)}" }
    description { "A mellow collector for testing" }
    collection_only { false }

    trait :collection_only do
      collection_only { true }
    end
  end
end
