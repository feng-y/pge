# PGE Complexity Optimization Playbook

Use this as a menu of safe transformations. Do not apply any transformation unless the correctness invariant is explicit and testable.

## Common Transformations

### Nested lookup loops

Signal: for each item in A, scan all of B to find matching records.

Preferred fix: build a map/grouping from B once, then do O(1) or O(k) lookups.

Complexity: commonly `O(a*b)` -> `O(a+b)`.

Correctness checks:
- Are duplicate keys possible?
- Did the original pick first match, last match, or all matches?
- Is output ordering observable?
- Is key normalization required?
- Are missing values represented the same way?

### Repeated membership checks

Signal: `includes`, `indexOf`, `find`, `x in list`, `in_array`, or `contains` inside a loop.

Preferred fix: build a set/map once, only if equality semantics are stable.

Complexity: commonly `O(n*m)` -> `O(n+m)`.

Correctness checks:
- Does equality change after conversion?
- Are objects compared by identity, value, normalized key, or custom comparator?
- Are duplicates meaningful?

### Sorting inside loops

Signal: `sort`, `sorted`, or equivalent inside repeated work.

Preferred fix: sort once outside the loop, maintain a heap, use binary insertion/search, or defer sorting until the final output.

Complexity: often `O(n^2 log n)` -> `O(n log n)` or `O(n log k)`.

Correctness checks:
- Is each intermediate sorted state externally visible?
- Does comparator depend on loop-local state?
- Is stable sort required?

### Pairwise comparisons

Signal: compare every pair to find overlaps, nearest values, conflicts, ranges, graph connectivity, or collisions.

Preferred fixes:
- sort + two pointers
- sweep line for intervals
- hash/spatial bucketing for local-neighborhood checks
- union-find for connectivity
- interval tree or indexed structure when query/update mix requires it

Correctness checks:
- Boundary inclusivity: `<` vs `<=`
- Duplicate and tie handling
- Output order
- Floating point precision or time-zone semantics

### Recomputing derived data in render paths

Signal: filter, sort, group, reduce, or expensive transform during every UI render.

Preferred fixes:
- memoized derived values with complete dependencies
- selectors/loaders/server-side preparation
- virtualization for large lists
- stable callbacks/props only when child renders are measurably affected

Correctness checks:
- Dependency arrays include every semantic input.
- Memoization does not hide mutation of mutable inputs.
- UI still updates after data changes.

### N+1 database or API calls

Signal: query, fetch, request, ORM lookup, or file/network operation inside a loop.

Preferred fixes:
- bulk fetch by IDs and join in memory
- joins/preloads/includes/dataloaders
- batched API endpoints
- cache with correct invalidation

Correctness checks:
- Preserve authorization, tenancy, soft-delete, filters, ordering, pagination, retry, and error behavior.
- Preserve missing-record behavior.
- Do not fetch records prior logic would not be allowed to observe.

## What Not To Do

- Do not optimize cold paths based only on static shape.
- Do not replace clear linear code with clever code for tiny bounded inputs.
- Do not cache without invalidation.
- Do not change ordering, grouping, deduplication, or null handling unless requested.
- Do not trade `O(n)` for `O(n log n)` unless it removes a larger bottleneck or enables batching.
- Do not claim speedup without measurement or a defensible complexity reduction.
