import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import {
  Area,
  AreaChart,
  Cell,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
} from "recharts";
import { Bell, MessageSquare, Sparkles, ArrowUpRight, X } from "lucide-react";
import {
  Avatar,
  Money,
  Pills,
  Section,
  Stat,
  StatusChip,
} from "@/components/app/ui";
import {
  activityDonut,
  bookings,
  earnings,
  provider,
  servicemen,
  topCards,
} from "@/data/mock";

export const Route = createFileRoute("/_tabs/")({
  head: () => ({
    meta: [
      { title: "Dashboard — Ink Partner" },
      { name: "description", content: "Today's bookings, earnings and team activity at a glance." },
      { property: "og:title", content: "Dashboard — Ink Partner" },
      { property: "og:description", content: "Today's bookings, earnings and team activity at a glance." },
    ],
  }),
  component: Dashboard,
});

function Dashboard() {
  const [range, setRange] = useState("This week");
  const [ribbon, setRibbon] = useState(true);

  return (
    <div className="space-y-7">
      <header className="sticky top-0 z-30 border-b border-border bg-background/85 px-4 py-3.5 backdrop-blur-xl">
        <div className="flex items-center gap-3">
          <span className="flex size-9 items-center justify-center rounded-xl bg-foreground font-display text-sm font-bold text-background">
            IP
          </span>
          <div className="min-w-0 flex-1">
            <p className="truncate text-[14px] font-bold leading-tight">{provider.business}</p>
            <p className="truncate text-[11px] text-muted-foreground">{provider.city}</p>
          </div>
          <Link to="/chat" className="flex size-9 items-center justify-center rounded-full border border-border" aria-label="Chat">
            <MessageSquare className="size-[17px]" />
          </Link>
          <Link to="/notifications" className="relative flex size-9 items-center justify-center rounded-full border border-border" aria-label="Notifications">
            <Bell className="size-[17px]" />
            <span className="absolute -right-0.5 -top-0.5 flex size-4 items-center justify-center rounded-full bg-foreground text-[9px] font-bold text-background">
              3
            </span>
          </Link>
        </div>
      </header>

      <div className="px-4">
        <div className="ink-surface relative overflow-hidden p-5">
          <div className="absolute -right-10 -top-10 size-36 rounded-full bg-white/10 blur-2xl" />
          <p className="eyebrow text-white/55">Overview · 29 Sep</p>
          <h1 className="mt-2 font-display text-[26px] font-bold leading-tight">Dashboard</h1>
          <p className="mt-1 text-[12px] text-white/65">
            Rating {provider.rating} · {provider.reviews} reviews
          </p>
          <div className="mt-5 flex items-end justify-between">
            <div>
              <p className="text-[11px] text-white/60">Earnings this week</p>
              <p className="font-display text-3xl font-bold">
                ₹{earnings.total.toLocaleString("en-IN")}
              </p>
            </div>
            <Link
              to="/reports"
              className="flex items-center gap-1.5 rounded-full bg-white/15 px-3.5 py-2 text-[12px] font-semibold backdrop-blur"
            >
              <Sparkles className="size-3.5" /> Insights
            </Link>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3 px-4">
        {topCards.map((c) => (
          <Stat key={c.label} label={c.label} value={c.value} delta={c.delta} />
        ))}
      </div>

      <Section title="Earnings statistics" action="Reports" actionTo="/reports">
        <div className="ink-card p-4">
          <Pills
            items={["This week", "This month", "This year"]}
            value={range}
            onChange={setRange}
          />
          <div className="mt-4 h-40">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={earnings.series} margin={{ left: 0, right: 0, top: 6, bottom: 0 }}>
                <defs>
                  <linearGradient id="inkFill" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="var(--color-chart-1)" stopOpacity={0.35} />
                    <stop offset="100%" stopColor="var(--color-chart-1)" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis
                  dataKey="label"
                  tickLine={false}
                  axisLine={false}
                  tick={{ fontSize: 10, fill: "var(--color-muted-foreground)" }}
                />
                <Tooltip
                  cursor={{ stroke: "var(--color-border)" }}
                  contentStyle={{
                    borderRadius: 12,
                    border: "1px solid var(--color-border)",
                    fontSize: 12,
                  }}
                />
                <Area
                  type="monotone"
                  dataKey="previous"
                  stroke="var(--color-chart-4)"
                  strokeDasharray="4 4"
                  fill="transparent"
                  strokeWidth={1.5}
                />
                <Area
                  type="monotone"
                  dataKey="current"
                  stroke="var(--color-chart-1)"
                  strokeWidth={2.4}
                  fill="url(#inkFill)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
          <div className="mt-2 flex items-center gap-4 text-[11px] text-muted-foreground">
            <span className="flex items-center gap-1.5">
              <span className="h-0.5 w-4 bg-foreground" /> Current
            </span>
            <span className="flex items-center gap-1.5">
              <span className="h-0.5 w-4 bg-border" /> Previous
            </span>
          </div>
        </div>
      </Section>

      <Section title="Recent activity" action="View all" actionTo="/requests">
        <div className="ink-card overflow-hidden">
          <div className="flex items-center gap-4 border-b border-border p-4">
            <div className="h-24 w-24">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={activityDonut}
                    dataKey="value"
                    innerRadius={28}
                    outerRadius={44}
                    paddingAngle={3}
                    stroke="none"
                  >
                    {activityDonut.map((_, i) => (
                      <Cell key={i} fill={i === 0 ? "var(--color-chart-1)" : "var(--color-chart-4)"} />
                    ))}
                  </Pie>
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="space-y-2 text-[12px]">
              {activityDonut.map((d, i) => (
                <div key={d.name} className="flex items-center gap-2">
                  <span
                    className="size-2.5 rounded-sm"
                    style={{ background: i === 0 ? "var(--color-chart-1)" : "var(--color-chart-4)" }}
                  />
                  <span className="font-semibold">{d.name} bookings</span>
                  <span className="text-muted-foreground">{d.value}%</span>
                </div>
              ))}
            </div>
          </div>
          {bookings.slice(0, 3).map((b) => (
            <Link
              key={b.id}
              to="/booking/$id"
              params={{ id: b.id }}
              className="flex items-center gap-3 border-b border-border px-4 py-3 last:border-0 active:bg-secondary"
            >
              <Avatar name={b.customer} size={38} />
              <div className="min-w-0 flex-1">
                <p className="truncate text-[13.5px] font-semibold">{b.service}</p>
                <p className="truncate text-[11.5px] text-muted-foreground">
                  {b.customer} · {b.time}
                </p>
              </div>
              <div className="text-right">
                <Money value={b.amount} className="block text-[13px] font-bold" />
                <StatusChip status={b.status} />
              </div>
            </Link>
          ))}
        </div>
      </Section>

      <Section title="Advertisements" action="Create" actionTo="/ads">
        <div className="no-scrollbar flex gap-3 overflow-x-auto pb-1">
          {["Monsoon cleaning 20% off", "AC service combo ₹999", "Refer & earn ₹500"].map((ad) => (
            <div key={ad} className="ink-card w-[230px] shrink-0 p-4">
              <p className="eyebrow">Running campaign</p>
              <p className="mt-2 text-[14px] font-bold leading-snug">{ad}</p>
              <p className="mt-3 flex items-center gap-1 text-[11px] text-muted-foreground">
                1,248 views <ArrowUpRight className="size-3" />
              </p>
            </div>
          ))}
        </div>
      </Section>

      <Section title="My subscription" action="Manage" actionTo="/plan">
        <Link to="/plan" className="ink-card flex items-center gap-4 p-4">
          <div className="flex-1">
            <p className="eyebrow">Current plan</p>
            <p className="mt-1.5 font-display text-lg font-bold">{provider.plan}</p>
            <p className="text-[12px] text-muted-foreground">
              {provider.planDaysLeft} days left · renews 17 Oct
            </p>
          </div>
          <div className="rounded-full bg-foreground px-4 py-2 text-[12px] font-semibold text-background">
            Renew
          </div>
        </Link>
      </Section>

      <Section title="Service men" action="View all" actionTo="/servicemen">
        <div className="no-scrollbar flex gap-3 overflow-x-auto pb-1">
          {servicemen.map((s) => (
            <Link
              key={s.id}
              to="/servicemen"
              className="ink-card w-[150px] shrink-0 p-4 text-center"
            >
              <div className="flex justify-center">
                <Avatar name={s.name} size={46} />
              </div>
              <p className="mt-2.5 truncate text-[13px] font-bold">{s.name}</p>
              <p className="truncate text-[11px] text-muted-foreground">{s.role}</p>
              <p className="mt-2 inline-block rounded-full border border-border px-2 py-0.5 text-[10px] font-semibold">
                {s.status}
              </p>
            </Link>
          ))}
        </div>
      </Section>

      {ribbon ? (
        <div className="fixed bottom-24 left-1/2 z-30 w-[calc(100%-2rem)] max-w-[428px] -translate-x-1/2 rounded-xl bg-destructive px-4 py-3 text-destructive-foreground shadow-[var(--shadow-float)]">
          <div className="flex items-center gap-3">
            <p className="flex-1 text-[12px] font-semibold">
              Trial ends in {provider.trialEndsIn} days — upgrade to keep bidding active.
            </p>
            <Link to="/plan" className="rounded-full bg-white/20 px-3 py-1.5 text-[11px] font-bold">
              Upgrade
            </Link>
            <button onClick={() => setRibbon(false)} aria-label="Dismiss">
              <X className="size-4" />
            </button>
          </div>
        </div>
      ) : null}
    </div>
  );
}
