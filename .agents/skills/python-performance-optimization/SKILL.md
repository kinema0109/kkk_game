---
name: python-performance-optimization
description: "Advanced Python performance optimization. Covers CPU profiling, memory management, async bottlenecks, N+1 query detection, and data structure efficiency."
risk: unknown
source: community
---
# Python Performance Optimization

> **Philosophy:** Measure twice, optimize once. Prioritize algorithmic efficiency and I/O bottlenecks before micro-optimizations.

## Core Pillars
1. **Profiling First**: Never optimize without data. Use real-world datasets for profiling.
2. **I/O is the Enemy**: 90% of web app performance issues are I/O bound (database, API calls).
3. **Data Structure Choice**: The difference between O(n) and O(1) is greater than any language-level optimization.
4. **Memory Consciousness**: Avoid leaks and excessive allocations in long-running processes.

---

## Profiling Toolbox

### CPU Profiling
```python
# Function-level (cProfile)
import cProfile
import pstats

def high_cpu_task(): ...

profiler = cProfile.Profile()
profiler.enable()
high_cpu_task()
profiler.disable()
stats = pstats.Stats(profiler).sort_stats('tottime')
stats.print_stats(10)
```

### Memory Profiling
- **tracemalloc**: Built-in, find where memory is allocated.
- **memory_profiler**: Line-by-line memory usage.
- **objgraph**: Find memory leaks by inspecting references.

### Async Profiling
- Use **py-spy** for non-intrusive profiling of running async applications.
- Identify blocking code in the event loop (no `await`).

---

## Optimization Techniques

### 1. Database & I/O
- **N+1 Queries**: Always use `select_related` (FKs) or `prefetch_related` (M2M) in Django ORM or `joinedload`/`selectinload` in SQLAlchemy.
- **Batching**: Use `bulk_create` and `bulk_update` instead of looping over records.
- **Connection Pooling**: Always ensure your app is using a connection pool (e.g., pgBouncer for Postgres).
- **Lazy Loading**: Avoid loading large fields (BLOBs/Text) unless needed (`.only()` or `.defer()`).

### 2. Algorithmic Efficiency
- **Set over List**: Using `in` on a `set` is O(1), on a `list` it's O(n).
- **List Comprehensions**: Faster than manual `for` loops with `.append()`.
- **Generators**: Use `yield` for processing large datasets without loading them entirely into memory.
- **Built-in Functions**: `sum()`, `max()`, `min()` are implemented in C and much faster than manual logic.

### 3. Concurrency Patterns
- **AsyncIO**: For I/O bound tasks (API calls, DB queries).
- **ProcessPoolExecutor**: For CPU-bound tasks (Parallel processing) to bypass the GIL.
- **ThreadPoolExecutor**: For I/O bound tasks using legacy sync libraries.

### 4. Special Tools
- **Numba/Cython**: For critical C-level performance in numeric/loop-heavy code.
- **Pydantic v2**: significantly faster serialization than v1 (written in Rust).
- **msgpack**: Faster alternative to JSON for internal service communication.

---

## Bottleneck Identification Guide

| Symptom | Probable Cause | Fix |
|---------|----------------|-----|
| Slow API response | Database N+1 or high latency | Profiling + joined loads |
| Event loop lag | Sync code in async view | Move to threadpool or use async library |
| High RAM usage | Loading too much data at once | Use generators / cursors |
| 100% CPU usage | Tight loop or heavy computation | Algorithmic fix or Multiprocessing |

---

## Performance Anti-patterns
- **Mixing sync/async**: Blocking the event loop kills performance.
- **Frequent String Concatenation**: Use `''.join(list)` instead of `+=` in loops.
- **Unnecessary Deepcopy**: `copy.deepcopy()` is extremely slow; use it only when strictly necessary.
- **Ignoring N+1**: The single most common cause of slow web applications.

---

## Decision Checklist
- [ ] Have you profiled the code with realistic data?
- [ ] Is the bottleneck I/O-bound or CPU-bound?
- [ ] Are there any N+1 database queries?
- [ ] Are you using the most efficient data structure (List vs Set vs Dict)?
- [ ] If using async, is there any blocking code?
- [ ] Is memory usage stable over thousands of iterations?
