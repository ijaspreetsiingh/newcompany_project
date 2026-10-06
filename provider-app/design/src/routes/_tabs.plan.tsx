import { createFileRoute } from "@tanstack/react-router";
import { Check } from "lucide-react";
import { Section, TopBar } from "@/components/app/ui";
import { plans, provider, transactions } from "@/data/mock";

export const Route = createFileRoute("/_tabs/plan")({
  head: () => ({
    meta: [
      { title: "Business plan — Ink Partner" },
      { name: "description", content: "Compare partner packages and manage your subscription." },
      { property: "og:title", content: "Business plan — Ink Partner" },
      { property: "og:description", content: "Compare partner packages and manage your subscription." },
    ],
  }),
  component: PlanPage,
});

function PlanPage() {
  return (
    <div className="space-y-6 pb-8">
      <TopBar title="Business plan" subtitle={`${provider.plan} · ${provider.planDaysLeft} days left`} back="/more" />

      <div className="space-y-3 px-4">
        {plans.map((p) => (
          <div
            key={p.name}
            className={`p-5 ${p.current ? "ink-surface" : "ink-card"}`}
          >
            <div className="flex items-start justify-between">
              <div>
                <p className={`eyebrow ${p.current ? "text-white/55" : ""}`}>{p.current ? "Current plan" : "Package"}</p>
                <p className="mt-1 font-display text-xl font-bold">{p.name}</p>
              </div>
              <p className="font-display text-2xl font-bold">
                ₹{p.price.toLocaleString("en-IN")}
                <span className={`text-[11px] font-medium ${p.current ? "text-white/60" : "text-muted-foreground"}`}>
                  /{p.period}
                </span>
              </p>
            </div>
            <ul className="mt-4 space-y-2">
              {p.features.map((f) => (
                <li key={f} className="flex items-center gap-2 text-[12.5px]">
                  <Check className="size-3.5 shrink-0" /> {f}
                </li>
              ))}
            </ul>
            <button
              className={`mt-5 w-full rounded-full py-3 text-[13px] font-bold ${
                p.current ? "bg-white/20" : "bg-foreground text-background"
              }`}
            >
              {p.current ? "Renew plan" : "Upgrade"}
            </button>
          </div>
        ))}
      </div>

      <Section title="Subscription history">
        <div className="ink-card divide-y divide-border overflow-hidden">
          {transactions
            .filter((t) => t.label.includes("Subscription"))
            .concat([{ id: "TXN-8604", label: "Subscription — Starter Plan", date: "22 Aug", amount: 499, type: "debit" }])
            .map((t) => (
              <div key={t.id} className="flex items-center justify-between p-3.5">
                <div>
                  <p className="text-[13px] font-semibold">{t.label}</p>
                  <p className="text-[10.5px] text-muted-foreground">{t.id} · {t.date}</p>
                </div>
                <span className="text-[13px] font-bold">₹{t.amount.toLocaleString("en-IN")}</span>
              </div>
            ))}
        </div>
      </Section>
    </div>
  );
}
