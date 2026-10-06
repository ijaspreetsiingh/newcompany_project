import { createFileRoute, Link } from "@tanstack/react-router";
import { Avatar, Money, Section, StatusChip, TopBar } from "@/components/app/ui";
import { bookings } from "@/data/mock";

export const Route = createFileRoute("/_tabs/calendar")({
  head: () => ({
    meta: [
      { title: "Booking calendar — Ink Partner" },
      { name: "description", content: "Month view of all scheduled, ongoing and cancelled jobs." },
      { property: "og:title", content: "Booking calendar — Ink Partner" },
      { property: "og:description", content: "Month view of all scheduled, ongoing and cancelled jobs." },
    ],
  }),
  component: CalendarPage,
});

const dots: Record<number, string[]> = {
  3: ["bg-foreground"],
  7: ["bg-foreground", "bg-muted-foreground"],
  12: ["bg-destructive"],
  15: ["bg-muted-foreground"],
  21: ["bg-foreground", "bg-destructive"],
  27: ["bg-muted-foreground", "bg-foreground"],
  28: ["bg-foreground"],
  29: ["bg-foreground", "bg-foreground", "bg-destructive"],
};

function CalendarPage() {
  const days = Array.from({ length: 30 }, (_, i) => i + 1);

  return (
    <div className="space-y-6 pb-8">
      <TopBar title="Booking calendar" subtitle="September 2026" back="/requests" />

      <div className="px-4">
        <div className="ink-card p-4">
          <div className="grid grid-cols-7 gap-1 text-center text-[10px] font-bold uppercase tracking-wider text-muted-foreground">
            {["S", "M", "T", "W", "T", "F", "S"].map((d, i) => (
              <span key={i}>{d}</span>
            ))}
          </div>
          <div className="mt-2 grid grid-cols-7 gap-1">
            {Array.from({ length: 2 }, (_, i) => (
              <span key={`p${i}`} />
            ))}
            {days.map((d) => (
              <div
                key={d}
                className={`flex aspect-square flex-col items-center justify-center rounded-lg text-[12.5px] font-semibold ${
                  d === 29 ? "bg-foreground text-background" : "text-foreground"
                }`}
              >
                {d}
                <span className="mt-1 flex h-1 gap-0.5">
                  {(dots[d] ?? []).map((c, i) => (
                    <span
                      key={i}
                      className={`size-1 rounded-full ${d === 29 ? "bg-background" : c}`}
                    />
                  ))}
                </span>
              </div>
            ))}
          </div>
          <div className="mt-4 flex flex-wrap gap-3 border-t border-border pt-3 text-[10.5px] text-muted-foreground">
            <Legend color="bg-foreground" label="Confirmed" />
            <Legend color="bg-muted-foreground" label="Completed" />
            <Legend color="bg-destructive" label="Cancelled" />
          </div>
        </div>
      </div>

      <Section title="29 September · 3 jobs">
        <div className="space-y-3">
          {bookings.slice(0, 3).map((b) => (
            <Link
              key={b.id}
              to="/booking/$id"
              params={{ id: b.id }}
              className="ink-card flex items-center gap-3 p-3.5"
            >
              <div className="w-14 shrink-0 text-center">
                <p className="font-display text-[13px] font-bold">{b.time.split(" ")[0]}</p>
                <p className="text-[10px] text-muted-foreground">{b.time.split(" ")[1]}</p>
              </div>
              <Avatar name={b.customer} size={36} />
              <div className="min-w-0 flex-1">
                <p className="truncate text-[13.5px] font-semibold">{b.service}</p>
                <p className="truncate text-[11.5px] text-muted-foreground">{b.customer}</p>
              </div>
              <div className="text-right">
                <Money value={b.amount} className="block text-[13px] font-bold" />
                <StatusChip status={b.status} />
              </div>
            </Link>
          ))}
        </div>
      </Section>
    </div>
  );
}

function Legend({ color, label }: { color: string; label: string }) {
  return (
    <span className="flex items-center gap-1.5">
      <span className={`size-2 rounded-full ${color}`} /> {label}
    </span>
  );
}
