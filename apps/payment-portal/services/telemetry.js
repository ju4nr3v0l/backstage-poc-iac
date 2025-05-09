// OpenTelemetry Tracing, Metrics and Logs Configuration
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-proto');
const { OTLPMetricExporter } = require('@opentelemetry/exporter-metrics-otlp-proto');
const { OTLPLogExporter } = require('@opentelemetry/exporter-logs-otlp-proto');
const { PeriodicExportingMetricReader } = require('@opentelemetry/sdk-metrics');
const { BatchLogRecordProcessor } = require('@opentelemetry/sdk-logs');
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');

// Configure the OTLP Exporter for Traces, Metrics and Logs
// Ensure your OTLP endpoint is configured (e.g., via environment variables)
// For local testing, you might use something like Jaeger or a local OpenTelemetry Collector
const otlpExporterOptions = {
  url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318', // Default to gRPC over HTTP
};

const traceExporter = new OTLPTraceExporter(otlpExporterOptions);
const metricExporter = new OTLPMetricExporter(otlpExporterOptions);
const logExporter = new OTLPLogExporter(otlpExporterOptions);

const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: process.env.SERVICE_NAME || 'payment-portal-app',
    [SemanticResourceAttributes.SERVICE_VERSION]: process.env.SERVICE_VERSION || '1.0.0',
  }),
  traceExporter,
  metricReader: new PeriodicExportingMetricReader({
    exporter: metricExporter,
    exportIntervalMillis: 10000, // Export metrics every 10 seconds
  }),
  logRecordProcessor: new BatchLogRecordProcessor(logExporter),
  instrumentations: [
    getNodeAutoInstrumentations({
      // disable fs instrumentation to reduce noise
      '@opentelemetry/instrumentation-fs': {
        enabled: false,
      },
    }),
  ],
});

async function startTelemetry() {
  try {
    await sdk.start();
    console.log('OpenTelemetry SDK started successfully.');

    // Graceful shutdown
    process.on('SIGTERM', () => {
      sdk.shutdown()
        .then(() => console.log('OpenTelemetry SDK shut down successfully.'))
        .catch((error) => console.error('Error shutting down OpenTelemetry SDK:', error))
        .finally(() => process.exit(0));
    });
  } catch (error) {
    console.error('Error starting OpenTelemetry SDK:', error);
  }
}

module.exports = { startTelemetry };