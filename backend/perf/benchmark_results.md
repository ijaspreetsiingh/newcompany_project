# Phase 2 â€“ Baseline Benchmark Results

## Endpoint: api/v1/auth/login

- Requests: 200
- Total time: 606.52 s
- RPS: 0.33
- Latency (s): P50=2.577 P95=5.719 P99=11.566
## Endpoint: api/v1/serviceman/login

- Requests: 200
- Total time: 484 s
- RPS: 0.41
- Latency (s): P50=2.244 P95=3.785 P99=6.957
## Endpoint: api/v1/serviceman/dashboard

- Requests: 200
- Total time: 493.48 s
- RPS: 0.41
- Latency (s): P50=2.293 P95=4.439 P99=7.616
## Endpoint: api/v1/provider/serviceman/list

- Requests: 200
- Total time: 711.33 s
- RPS: 0.28
- Latency (s): P50=2.832 P95=7.939 P99=20.919

## Resource Utilization

- Redis hits: 0
- Redis misses: 0
- Total Redis commands processed: 0

*Note: This benchmark records latency and Redis usage; DBâ€‘query metrics need inâ€‘app instrumentation.*
