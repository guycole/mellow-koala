FactoryBot.define do
  factory :collection_snapshot do
    component
    sequence(:snapshot_id) { |n| "col-#{n.to_s.rjust(4, '0')}" }
    captured_at { 1.hour.ago }
    received_at { Time.current }
    status { "accepted" }
    payload { { "collections" => [{ "name" => "items", "count" => 42 }] } }
  end
end
