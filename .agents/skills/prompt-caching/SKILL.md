---
name: prompt-caching
description: "Master prompt caching strategies to reduce latency and costs. Covers cache-aware prompting, structure-optimization for Anthropic and Gemini, and dynamic content management."
risk: unknown
source: community
---
# Prompt Caching

> **Philosophy:** Optimize the architecture of your prompts to maximize reuse. Caching is not just about speed; it's about making complex, large-context agents commercially viable.

## Core Principles
1. **Consistency is Key**: Any change in the prefix breaks the cache.
2. **Static First**: Put static content (system instructions, tool definitions, many-shot examples) at the beginning.
3. **Dynamic Last**: Put highly variable content (user query, current time) at the very end.
4. **Structural awareness**: Design your prompt segments (nodes) to align with provider-specific caching boundaries (e.g., Anthropic's 1024 token increments).

---

## Provider-Specific Strategies

### Anthropic (Claude)
- **Cache breakpoints**: Tag segments with `cache_control: {"type": "ephemeral"}`.
- **Limit**: Currently supports up to 4 breakpoints.
- **Minimums**: Only caches segments larger than 1024 tokens (variable by model).
- **TTL**: Cache typically lives for 5 minutes of inactivity.

### Google (Gemini)
- **Fixed TTL**: Set specific duration for cache.
- **Token counts**: Works best with large context (Context Caching).
- **Cost model**: Pay for storage per hour, save on input tokens.

---

## Optimization Patterns

### 1. The Many-Shot Pattern
Load 50-100 high-quality examples into a static block at the beginning. This allows the model to deeply understand the task without paying the full input token cost on every subsequent turn.

### 2. The Library Pattern
For RAG or large codebase agents, put the entire "Reference Library" or "Code Context" into a cached block. Update it only when the library changes, not for every user query.

### 3. The Toolchain Pattern
If using many tools, place all tool definitions in the first cached block. This is especially useful for agents with 20+ tools where definitions can exceed 2k tokens.

---

## Anti-patterns
- **Dynamic prefixes**: Putting `Current Time: {{time}}` at the top of the system prompt. This invalidates everything below it.
- **Frequent small updates**: Changing a single sentence in the middle of a 20k token prompt breaks the cache for everything following that sentence.
- **Under-using context**: If you are paying for the cache, leverage it. Don't prune context as aggressively if it fits in the cached block.

---

## Caching Checklist
- [ ] Is the system prompt completely static?
- [ ] Are tool definitions separated from dynamic user data?
- [ ] For RAG: Is the shared context placed before the user question?
- [ ] Am I using the correct prompt marker/API parameter for this provider?
- [ ] Is the static segment large enough (>1024 tokens) to trigger caching benefits?
- [ ] am I monitoring cache hit/miss rates in logs?
