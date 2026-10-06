import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { MapPin, Users } from "lucide-react";
import { Pills, TopBar } from "@/components/app/ui";
import { bids } from "@/data/mock";

export const Route = createFileRoute("/_tabs/bids")({
  head: () => ({
    meta: [
      { title: "Custom requests — Ink Partner" },
      { name: "description", content: "Customer posts open for bidding with offers and distance." },
      { property: "og:title", content: "Custom requests — Ink Partner" },
      { property: "og:description", content: "Customer posts open for bidding with offers and distance." },
    ],
  }),
  component: Bids,
});

function Bids() {
  const [tab, setTab] = useState("Open posts");

  return (
    <div className="space-y-5 pb-8">
      <TopBar title="Custom requests" subtitle="Bidding enabled on Growth Plan" back="/" />

      <div className="px-4">
        <Pills items={["Open posts", "My offers", "Awarded"]} value={tab} onChange={setTab} />
      </div>

      <div className="space-y-3 px-4">
        {bids.map((b) => (
          <div key={b.id} className="ink-card p-4">
            <div className="flex items-start justify-between gap-3">
              <div className="min-w-0">
                <p className="text-[14.5px] font-bold leading-snug">{b.title}</p>
                <p className="mt-0.5 text-[11.5px] text-muted-foreground">
                  {b.customer} · {b.posted}
                </p>
              </div>
              <span className="shrink-0 rounded-full border border-border px-2.5 py-1 text-[10px] font-bold">
                {b.budget}
              </span>
            </div>
            <p className="mt-2.5 text-[12.5px] text-muted-foreground">{b.note}</p>
            <div className="mt-3 flex items-center justify-between border-t border-border pt-3 text-[11.5px] text-muted-foreground">
              <span className="flex items-center gap-1.5">
                <MapPin className="size-3.5" /> {b.distance}
              </span>
              <span className="flex items-center gap-1.5">
                <Users className="size-3.5" /> {b.offers} offers
              </span>
            </div>
            <div className="mt-3 grid grid-cols-2 gap-2">
              <button className="rounded-full bg-foreground py-2.5 text-[12.5px] font-semibold text-background">
                {tab === "My offers" ? "Edit offer" : "Give offer"}
              </button>
              <button className="rounded-full border border-border py-2.5 text-[12.5px] font-semibold">
                See other offers
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
