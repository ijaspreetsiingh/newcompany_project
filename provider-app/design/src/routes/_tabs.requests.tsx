import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import { CalendarDays, SlidersHorizontal, Search } from "lucide-react";
import { Avatar, Money, Pills, StatusChip } from "@/components/app/ui";
import { bookings } from "@/data/mock";

export const Route = createFileRoute("/_tabs/requests")({
  head: () => ({
    meta: [
      { title: "Booking requests — Ink Partner" },
      { name: "description", content: "Accept, track and assign incoming and repeat service bookings." },
      { property: "og:title", content: "Booking requests — Ink Partner" },
      { property: "og:description", content: "Accept, track and assign incoming and repeat service bookings." },
    ],
  }),
  component: Requests,
});

function Requests() {
  const [tab, setTab] = useState("All");
  const [status, setStatus] = useState("Any status");
  const [q, setQ] = useState("");

  const list = bookings.filter((b) => {
    const tabOk =
      tab === "All" || (tab === "Regular" ? b.type === "regular" : b.type === "repeat");
    const statusOk = status === "Any status" || b.status === status.toLowerCase();
    const qOk =
      q.trim() === "" ||
      (b.customer + b.service + b.code).toLowerCase().includes(q.toLowerCase());
    return tabOk && statusOk && qOk;
  });

  return (
    <div className="pb-6">
      <header className="sticky top-0 z-30 space-y-3 border-b border-border bg-background/90 px-4 pb-3 pt-4 backdrop-blur-xl">
        <div className="flex items-center gap-3">
          <h1 className="flex-1 font-display text-[22px] font-bold">Requests</h1>
          <Link to="/calendar" className="flex size-9 items-center justify-center rounded-full border border-border" aria-label="Calendar">
            <CalendarDays className="size-[17px]" />
          </Link>
          <button
            onClick={() =>
              setStatus((s) =>
                s === "Any status" ? "Pending" : s === "Pending" ? "Ongoing" : "Any status",
              )
            }
            className="flex size-9 items-center justify-center rounded-full border border-border"
            aria-label="Filter"
          >
            <SlidersHorizontal className="size-[17px]" />
          </button>
        </div>
        <div className="flex items-center gap-2 rounded-full border border-border bg-card px-3.5 py-2.5">
          <Search className="size-4 text-muted-foreground" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search customer, service or ID"
            className="w-full bg-transparent text-[13px] outline-none placeholder:text-muted-foreground"
          />
        </div>
        <Pills items={["All", "Regular", "Repeat"]} value={tab} onChange={setTab} />
        {status !== "Any status" ? (
          <p className="text-[11px] text-muted-foreground">Filter: {status}</p>
        ) : null}
      </header>

      <div className="space-y-3 px-4 pt-4">
        {list.map((b) => (
          <Link
            key={b.id}
            to="/booking/$id"
            params={{ id: b.id }}
            className="ink-card block p-4 active:scale-[0.995]"
          >
            <div className="flex items-start gap-3">
              <Avatar name={b.customer} />
              <div className="min-w-0 flex-1">
                <div className="flex items-center gap-2">
                  <p className="truncate text-[14px] font-bold">{b.customer}</p>
                  <span className="text-[10px] text-muted-foreground">{b.code}</span>
                </div>
                <p className="truncate text-[12.5px] text-muted-foreground">{b.service}</p>
              </div>
              <StatusChip status={b.status} />
            </div>
            <div className="mt-3 flex items-center justify-between border-t border-border pt-3">
              <p className="text-[12px] text-muted-foreground">
                {b.date} · {b.time}
              </p>
              <Money value={b.amount} className="text-[15px] font-bold" />
            </div>
            {b.status === "pending" ? (
              <div className="mt-3 grid grid-cols-2 gap-2">
                <span className="rounded-full bg-foreground py-2 text-center text-[12px] font-semibold text-background">
                  Accept
                </span>
                <span className="rounded-full border border-border py-2 text-center text-[12px] font-semibold">
                  Decline
                </span>
              </div>
            ) : null}
          </Link>
        ))}
        {list.length === 0 ? (
          <div className="ink-card p-8 text-center text-[13px] text-muted-foreground">
            No bookings match this filter.
          </div>
        ) : null}
      </div>
    </div>
  );
}
