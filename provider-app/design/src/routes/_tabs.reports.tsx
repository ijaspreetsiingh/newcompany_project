import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { Download } from "lucide-react";
import { Money, Pills, Section, Stat, TopBar } from "@/components/app/ui";
import { bookings, transactions } from "@/data/mock";

export const Route = createFileRoute("/_tabs/reports")({
  head: () => ({
    meta: [
      { title: "Reports — Ink Partner" },
      { name: "description", content: "Booking, business and transaction reports with export." },
      { property: "og:title", content: "Reports — Ink Partner" },
      { property: "og:description", content: "Booking, business and transaction reports with export." },
    ],
  }),
  component: Reports,
});

function Reports() {
  const [tab, setTab] = useState("Booking");

  return (
    <div className="space-y-5 pb-8">
      <TopBar
        title="Reports"
        subtitle="01 Sep – 29 Sep 2026"
        back="/more"
        right={
          <span className="flex size-9 items-center justify-center rounded-full border border-border">
            <Download className="size-4" />
          </span>
        }
      />

      <div className="px-4">
        <Pills items={["Booking", "Business", "Transaction"]} value={tab} onChange={setTab} />
      </div>

      {tab === "Booking" ? (
        <Section title="Booking report">
          <div className="ink-card overflow-hidden">
            <div className="grid grid-cols-[1fr_auto_auto] gap-3 border-b border-border bg-secondary px-4 py-2.5 text-[10.5px] font-bold uppercase tracking-wider text-muted-foreground">
              <span>Booking</span>
              <span>Status</span>
              <span className="text-right">Amount</span>
            </div>
            {bookings.map((b) => (
              <div key={b.id} className="grid grid-cols-[1fr_auto_auto] items-center gap-3 border-b border-border px-4 py-3 last:border-0">
                <div className="min-w-0">
                  <p className="truncate text-[13px] font-semibold">{b.service}</p>
                  <p className="text-[10.5px] text-muted-foreground">{b.code} · {b.date}</p>
                </div>
                <span className="text-[11px] capitalize text-muted-foreground">{b.status}</span>
                <Money value={b.amount} className="text-right text-[13px] font-bold" />
              </div>
            ))}
          </div>
        </Section>
      ) : null}

      {tab === "Business" ? (
        <>
          <div className="grid grid-cols-2 gap-3 px-4">
            <Stat label="Total bookings" value="268" delta="+12% MoM" />
            <Stat label="Avg ticket" value="₹1,412" delta="+₹90" />
            <Stat label="Repeat rate" value="34%" delta="93 customers" />
            <Stat label="Cancel rate" value="3%" delta="7 bookings" />
          </div>
          <Section title="Status distribution">
            <div className="ink-card space-y-3 p-4">
              {[
                ["Completed", 58, "bg-foreground"],
                ["Accepted", 24, "bg-ink-soft"],
                ["Ongoing", 12, "bg-muted-foreground"],
                ["Pending", 6, "bg-border"],
                ["Cancelled", 3, "bg-destructive"],
              ].map(([label, pct, color]) => (
                <div key={label as string}>
                  <div className="flex justify-between text-[12px] font-semibold">
                    <span>{label as string}</span>
                    <span className="text-muted-foreground">{pct as number}%</span>
                  </div>
                  <div className="mt-1.5 h-2 overflow-hidden rounded-full bg-secondary">
                    <div className={`h-full rounded-full ${color as string}`} style={{ width: `${pct as number}%` }} />
                  </div>
                </div>
              ))}
            </div>
          </Section>
        </>
      ) : null}

      {tab === "Transaction" ? (
        <>
          <div className="grid grid-cols-2 gap-3 px-4">
            <Stat label="Credits" value="₹1,84,600" />
            <Stat label="Debits" value="₹26,499" />
          </div>
          <Section title="Transaction report" action="Export CSV">
            <div className="ink-card divide-y divide-border overflow-hidden">
              {transactions.map((t) => (
                <div key={t.id} className="flex items-center gap-3 p-3.5">
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-[13px] font-semibold">{t.label}</p>
                    <p className="text-[10.5px] text-muted-foreground">{t.id} · {t.date}</p>
                  </div>
                  <span className="text-[13px] font-bold">
                    {t.type === "debit" ? "−" : "+"}₹{t.amount.toLocaleString("en-IN")}
                  </span>
                </div>
              ))}
            </div>
          </Section>
        </>
      ) : null}
    </div>
  );
}
