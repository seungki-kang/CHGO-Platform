# R6 SDK & API-Major Compatibility Test Pack 1.0

Purpose: prevent silent /api/v1 ↔ /api/v2 switching and bind each SDK/client release to an explicit API major and OpenAPI source hash.

Current execution:
- Source/pack compatibility assertions: executed.
- Actual generated/handwritten SDK tests: NOT_RUN until SDK/client artifacts are supplied.

Key rule:
Product version and SDK version do not automatically determine API major. Each client/SDK must explicitly declare supported_api_major and source contract hash. No /api/latest.
