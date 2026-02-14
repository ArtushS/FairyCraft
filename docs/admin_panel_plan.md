# Admin Panel Plan

## Current MVP

- Login with Firebase email/password or mock mode.
- `Policy` tab:
  - reads `admin_policy/runtime`
  - writes `admin_policy/runtime`
- `Stats` tab:
  - reads `usage_daily`

## Near-term improvements

1. Policy UX
- Typed form instead of raw JSON editor
- Field-level validation and defaults
- Save history preview

2. Audit visibility
- Add table for `story_audit`
- Filters by route/action/uid/blockReason/date
- Export for incident review

3. Catalog management
- CRUD for `catalog/story_setup`
- Versioning (draft/published)

4. Operations
- Daily usage charts
- Rate-limit and policy violation counters
- Per-language and per-platform slices
