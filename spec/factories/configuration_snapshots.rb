FactoryBot.define do
  factory :configuration_snapshot do
    collector
    sequence(:snapshot_id) { |n| "cfg-#{n.to_s.rjust(4, '0')}" }
    captured_at { 1.hour.ago }
    received_at { Time.current }
    status { "accepted" }
    payload { { "version" => "1.0.0", "config" => { "mode" => "active" } } }
  end
end
