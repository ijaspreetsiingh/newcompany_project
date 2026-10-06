import { createFileRoute } from "@tanstack/react-router";
import { Plus, Search, Star } from "lucide-react";
import { Avatar, Section, TopBar } from "@/components/app/ui";
import { servicemen } from "@/data/mock";

export const Route = createFileRoute("/_tabs/servicemen")({
  head: () => ({
    meta: [
      { title: "Service men — Ink Partner" },
      { name: "description", content: "Your technicians, their duty status, ratings and zones." },
      { property: "og:title", content: "Service men — Ink Partner" },
      { property: "og:description", content: "Your technicians, their duty status, ratings and zones." },
    ],
  }),
  component: Servicemen,
});

function Servicemen() {
  return (
    <div className="space-y-5 pb-8">
      <TopBar
        title="Service men"
        subtitle={`${servicemen.length} team members`}
        back="/more"
        right={
          <span className="flex size-9 items-center justify-center rounded-full bg-foreground text-background">
            <Plus className="size-4" />
          </span>
        }
      />

      <div className="px-4">
        <div className="flex items-center gap-2 rounded-full border border-border bg-card px-3.5 py-2.5">
          <Search className="size-4 text-muted-foreground" />
          <input
            placeholder="Search technician"
            className="w-full bg-transparent text-[13px] outline-none placeholder:text-muted-foreground"
          />
        </div>
      </div>

      <div className="space-y-3 px-4">
        {servicemen.map((s) => (
          <div key={s.id} className="ink-card flex items-center gap-3 p-4">
            <Avatar name={s.name} size={46} />
            <div className="min-w-0 flex-1">
              <p className="truncate text-[14px] font-bold">{s.name}</p>
              <p className="truncate text-[11.5px] text-muted-foreground">{s.role} · {s.zone}</p>
              <p className="mt-1 flex items-center gap-3 text-[11px] text-muted-foreground">
                <span className="flex items-center gap-1">
                  <Star className="size-3 fill-foreground text-foreground" /> {s.rating}
                </span>
                <span>{s.jobs} jobs</span>
              </p>
            </div>
            <span className="rounded-full border border-border px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider">
              {s.status}
            </span>
          </div>
        ))}
      </div>

      <Section title="Auto-assign">
        <div className="ink-card divide-y divide-border">
          {[
            ["Auto-assign new bookings", true],
            ["Assign by nearest zone", true],
            ["Notify serviceman on assign", false],
          ].map(([label, on]) => (
            <div key={label as string} className="flex items-center justify-between p-3.5">
              <p className="text-[13px] font-semibold">{label as string}</p>
              <span className={`flex h-6 w-11 items-center rounded-full p-0.5 ${on ? "bg-foreground" : "bg-border"}`}>
                <span className={`size-5 rounded-full bg-background ${on ? "translate-x-5" : ""}`} />
              </span>
            </div>
          ))}
        </div>
      </Section>
    </div>
  );
}
