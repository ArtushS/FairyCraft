interface CounterEntry {
  count: number;
  windowStartedAt: number;
  touchedAt: number;
}

export class BoundedRateCounter {
  private readonly map = new Map<string, CounterEntry>();

  constructor(
    private readonly ttlMs: number,
    private readonly cap: number,
  ) {}

  private prune(now: number): void {
    for (const [key, entry] of this.map.entries()) {
      if (now - entry.touchedAt > this.ttlMs) {
        this.map.delete(key);
      }
    }

    if (this.map.size <= this.cap) {
      return;
    }

    const overflow = this.map.size - this.cap;
    const oldest = [...this.map.entries()]
      .sort((a, b) => a[1].touchedAt - b[1].touchedAt)
      .slice(0, overflow);

    for (const [key] of oldest) {
      this.map.delete(key);
    }
  }

  consume(key: string | undefined, limitPerMinute: number): boolean {
    if (!key) {
      return true;
    }

    const now = Date.now();
    this.prune(now);

    const entry = this.map.get(key);
    if (!entry || now - entry.windowStartedAt >= 60_000) {
      this.map.set(key, { count: 1, windowStartedAt: now, touchedAt: now });
      return true;
    }

    entry.count += 1;
    entry.touchedAt = now;
    this.map.set(key, entry);
    return entry.count <= limitPerMinute;
  }

  size(): number {
    return this.map.size;
  }
}
