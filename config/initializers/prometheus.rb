require "prometheus/client"

# Multi-process support (e.g. Puma in cluster mode):
# Set PROMETHEUS_MULTIPROC_DIR to a writable directory so each worker
# writes its own files and the exporter aggregates them.
if (dir = ENV["PROMETHEUS_MULTIPROC_DIR"])
  Prometheus::Client.config.data_store =
    Prometheus::Client::DataStores::DirectFileStore.new(dir: dir)
end

registry = Prometheus::Client.registry

# Custom metrics — ingestion API events broken down by snapshot type and outcome
module AppMetrics
  INGESTION_TOTAL = Prometheus::Client.registry.counter(
    :mellow_koala_ingestion_total,
    docstring: "Total number of ingestion API requests",
    labels: %i[snapshot_type status]
  )

  def self.ingestion_total
    INGESTION_TOTAL
  end
end
