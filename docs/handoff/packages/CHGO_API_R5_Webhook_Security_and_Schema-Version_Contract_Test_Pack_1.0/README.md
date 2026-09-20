# R5 Webhook Security & Schema-Version Contract Test Pack 1.0

Grounded in the current v2 Consolidated OpenAPI source.

Verified source facts:
- POST /headless/webhooks
- POST /integrations/vault/webhooks
- both require serviceCredential with webhook.manage
- both use RequestId and IdempotencyKey
- Vault webhook subscription is explicitly metadata-only and must not carry raw diary or secrets

The 20-case matrix also defines security requirements (signature, replay, schema-version handling, SSRF, retry, revocation) that require implementation/runtime evidence. They are test requirements, not claims that the current OpenAPI already specifies every mechanism.

Runtime tests remain skipped until a controlled dev/staging target and synthetic credentials are supplied.
