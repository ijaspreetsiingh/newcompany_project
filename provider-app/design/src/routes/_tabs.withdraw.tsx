import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { Pills, Section, Stat, TopBar } from "@/components/app/ui";

export const Route = createFileRoute("/_tabs/withdraw")({
  head: () => ({
    meta: [
      { title: "Withdrawals — Ink Partner" },
      { name: "description", content: "Track paid and pending withdrawals and raise a new request." },
      { property: "og:title", content: "Withdrawals — Ink Partner" },
      { property: "og:description", content: "Track paid and pending withdrawals and raise a new request." },
    ],
  }),
  component: Withdraw,
});

const requests = [
  { id: "WD-3391", amount: 25000, date: "26 Sep 2026", method: "HDFC ****4421", paid: true },
  { id: "WD-3372", amount: 8000, date: "24 Sep 2026", method: "UPI — jaspreet@okhdfc", paid: false },
  { id: "WD-3350", amount: 15000, date: "18 Sep 2026", method: "HDFC ****4421", paid: true },
];

function Withdraw() {
  const [tab, setTab] = useState("All");
  const list = requests.filter((r) => tab === "All" || (tab === "Paid" ? r.paid : !r.paid));

  return (
    <div className="space-y-5 pb-8">
      <TopBar title="Withdraw" subtitle="Balance ₹12,480" back="/more" />

      <div className="grid grid-cols-2 gap-3 px-4">
        <Stat label="Available" value="₹12,480" />
        <Stat label="Pending" value="₹8,000" />
      </div>

      <Section title="New request">
        <div className="ink-card space-y-3 p-4">
          <div>
            <p className="eyebrow">Amount</p>
            <input
              defaultValue="5000"
              inputMode="numeric"
              className="mt-1 w-full border-b border-border bg-transparent pb-2 font-display text-2xl font-bold outline-none"
            />
          </div>
          <div>
            <p className="eyebrow">Method</p>
            <div className="mt-2 grid grid-cols-2 gap-2">
              {["Bank transfer", "UPI"].map((m, i) => (
                <span
                  key={m}
                  className={`rounded-full py-2.5 text-center text-[12.5px] font-semibold ${
                    i === 0 ? "bg-foreground text-background" : "border border-border"
                  }`}
                >
                  {m}
                </span>
              ))}
            </div>
          </div>
          <button className="w-full rounded-full bg-foreground py-3.5 text-[14px] font-bold text-background">
            Request withdraw
          </button>
        </div>
      </Section>

      <div className="px-4">
        <Pills items={["All", "Paid", "Unpaid"]} value={tab} onChange={setTab} />
      </div>

      <Section title="Withdraw list">
        <div className="ink-card divide-y divide-border overflow-hidden">
          {list.map((r) => (
            <div key={r.id} className="flex items-center gap-3 p-3.5">
              <div className="min-w-0 flex-1">
                <p className="text-[13.5px] font-semibold">₹{r.amount.toLocaleString("en-IN")}</p>
                <p className="truncate text-[11px] text-muted-foreground">{r.id} · {r.method} · {r.date}</p>
              </div>
              <span
                className={`rounded-full px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider ${
                  r.paid ? "bg-foreground text-background" : "border border-border text-muted-foreground"
                }`}
              >
                {r.paid ? "Paid" : "Pending"}
              </span>
            </div>
          ))}
        </div>
      </Section>
    </div>
  );
}
