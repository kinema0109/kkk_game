---
name: postgresql
description: "Design a PostgreSQL-specific schema. Covers best-practices, data types, indexing, constraints, performance patterns, and advanced features"
risk: unknown
source: community
---
# PostgreSQL Table Design

> **Philosophy:** Let the database do its job. Use the most specific types, strictly enforce constraints, and don't be afraid of modern Postgres features.

## General Design
- **Use Identity Columns**: Use `GENERATED ALWAYS AS IDENTITY` for primary keys. Avoid `SERIAL`.
- **Primary Keys**: Prefer `bigint` for auto-incrementing IDs or `uuid` (version 7 preferred for sortability) for distributed systems.
- **Naming Conventions**: Use `snake_case` for everything (tables, columns, indexes, constraints).
- **Singular vs. Plural**: Table names should be plural (e.g., `users`, `orders`).
- **Foreign Keys**: Always name FK columns using the singular of the referenced table followed by `_id` (e.g., `user_id`).
- **Audit Columns**: Include `created_at` and `updated_at` (with `timestamptz`). Use a trigger for `updated_at`.

---

## Data Types

### Do not use the following data types
- DO NOT use `timestamp` (without time zone); DO use `timestamptz` instead.
- DO NOT use `char(n)` or `varchar(n)`; DO use `text` instead.
- DO NOT use `money` type; DO use `numeric` instead.
- DO NOT use `timetz` type; DO use `timestamptz` instead.
- DO NOT use `timestamptz(0)` or any other precision specification; DO use `timestamptz` instead
- DO NOT use `serial` type; DO use `generated always as identity` instead.

### Recommended Data Types
- **Strings**: Always use `text`. PostgreSQL handles variable-length strings efficiently. If you need a length constraint, use a `CHECK` constraint.
- **Numbers**:
  - Use `bigint` for IDs.
  - Use `numeric` for financial / arbitrary precision data.
  - Use `double precision` for scientific data.
- **Dates & Times**: Always use `timestamptz`.
- **JSON**: Use `jsonb` for binary-stored JSON (supports indexing).
- **UUIDs**: Use `uuid`. Use `uuid_generate_v1mc()` or version 7 for better index performance.
- **Boolean**: Use `boolean`. Avoid `integer` (0/1).
- **Binary**: Use `bytea`.

---

## Constraints (Mandatory)
- **NOT NULL**: Almost every column should be `NOT NULL` unless there is a strong reason for it to be nullable.
- **Foreign Keys**: Always use `REFERENCES` with `ON DELETE CASCADE` or `ON DELETE SET NULL` as appropriate.
- **Unique**: Use `UNIQUE` constraints for natural keys (URLs, slugs, email).
- **Check Constraints**: Use `CHECK` constraints for business rules (e.g., `price > 0`, `status IN (...)`).

---

## Indexing Strategy
- **Primary/Unique Keys**: Automatically indexed.
- **Foreign Keys**: Always index foreign key columns to avoid full table scans on joins and deletes.
- **JSONB**: Use `GIN` indexes for JSONB columns if you need to query inside the JSON.
- **Partial Indexes**: Use `WHERE` clauses in indexes for common filtered queries (e.g., `WHERE deleted_at IS NULL`).
- **Covering Indexes**: Use `INCLUDE` to add non-indexed columns to an index for index-only scans.
- **Full Text Search**: Use `tsvector` with `GIN` indexes for text searches.

---

## Example Table Structure

```sql
CREATE TABLE users (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    public_id uuid DEFAULT gen_random_uuid() NOT NULL UNIQUE,
    email text NOT NULL UNIQUE CHECK (email ~* '^.+@.+\..+$'),
    full_name text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL
);

CREATE TABLE posts (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title text NOT NULL CHECK (length(title) < 255),
    slug text NOT NULL UNIQUE,
    content text NOT NULL,
    status text DEFAULT 'draft' NOT NULL CHECK (status IN ('draft', 'published', 'archived')),
    published_at timestamptz,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL
);

-- Index for FK
CREATE INDEX idx_posts_user_id ON posts (user_id);
-- Partial index for active posts
CREATE INDEX idx_posts_published ON posts (published_at) WHERE status = 'published';
-- GIN index for search in content
CREATE INDEX idx_posts_content_gin ON posts USING gin (to_tsvector('english', content));
```

---

## Performance Patterns
- **Batch Deletes**: Use `DELETE` in batches for large tables to avoid blocking.
- **Soft Deletes**: Use a `deleted_at timestamptz` column and a view or RLS to filter results.
- **Materialized Views**: Use for complex, slow-changing reports.
- **Partitioning**: Use for very large tables (logs, time-series data).

---

## Common Pitfalls to Avoid
- **Entity-Attribute-Value (EAV)**: Avoid this. Use `jsonb` or separate tables instead.
- **Storing Everything in JSON**: Statically typed columns are faster and safer. Use `jsonb` only for truly dynamic data.
- **Too Many Indexes**: Slows down writes. Index only what you query.
- **Enum Types**: Avoid native Postgres `ENUM` types for data that changes. Use a separate lookup table or a `CHECK` constraint instead.

---

## Quick Checklist before finalizing
- [ ] Uses `timestamptz` for all timestamps?
- [ ] Uses `text` instead of `varchar`?
- [ ] Are all FKs indexed?
- [ ] Are business rules enforced with `CHECK` constraints?
- [ ] Is there an `updated_at` trigger?
- [ ] Is any potential PII encrypted or restricted?
