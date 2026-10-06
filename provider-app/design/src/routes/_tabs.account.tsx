import { createFileRoute, Link } from "@tanstack/react-router";
import { Bar, BarChart, Cell, Pie, PieChart, ResponsiveContainer, XAxis } from "recharts";
import { Money, Section, Stat, TopBar } from "@/components/app/ui";
import { accountDonut, earnings, transactions } from "@/data/mock";

export const Route = createFileRoute("/_tabs/account")({
  head: () => ({
    meta: [
      { title: "Account information — Ink Partner" },
      { name: "description", content: "Receivable, withdrawn and total earnings with transaction history." },
      { property: "og:title", content: "Account information — Ink Partner" },
      { property: "og:description", content: "Receivable, withdrawn and total earnings with transaction history." },
    ],
  }),
  component: Account,
});

const donutColors = ["var(--color-chart-1)", "var(--color-chart-2)", "var(--color-chart-3)", "var(--color-chart-5)"];

function Account() {
  return (
    <div className="space-y-6 pb-8">
      <TopBar title="Account information" subtitle="Updated just now" back="/more" />

      <div className="grid grid-cols-2 gap-3 px-4">
        <Stat label="Receivable" value="₹12,480" delta="from 4 bookings" />
        <Stat label="Pending withdraw" value="₹8,000" delta="1 request" />
        <Stat label="Withdrawn" value="₹1,42,000" delta="lifetime" />
        <Stat label="Total earning" value="₹1,84,600" delta="this year" />
      </div>

      <Section title="Booking breakdown">
        <div className="ink-card flex items-center gap-4 p-4">
          <div className="h-28 w-28">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={accountDonut} dataKey="value" innerRadius={32} outerRadius={50} paddingAngle={3} stroke="none">
                  {accountDonut.map((_, i) => (
                    <Cell key={i} fill={donutColors[i]} />
                  ))}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex-1 space-y-2">
            {accountDonut.map((d, i) => (
              <div key={d.name} className="flex items-center gap-2 text-[12px]">
                <span className="size-2.5 rounded-sm" style={{ background: donutColors[i] }} />
                <span className="flex-1 font-semibold">{d.name}</span>
                <span className="text-muted-foreground">{d.value}%</span>
              </div>
            ))}
          </div>
        </div>
      </Section>

      <Section title="Collect cash">
        <div className="ink-card flex items-center gap-4 p-4">
          <div className="flex-1">
            <p className="text-[13px] font-semibold">Cash in hand with team</p>
            <Money value={4300} className="mt-1 block text-2xl font-bold" />
            <p className="text-[11.5px] text-muted-foreground">Collected from 3 cash bookings</p>
          </div>
          <span className="rounded-full bg-foreground px-4 py-2.5 text-[12.5px] font-semibold text-background">
            Deposit
          </span>
        </div>
      </Section>

      <Section title="Transaction chart">
        <div className="ink-card p-4">
          <div className="h-36">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={earnings.series}>
                <XAxis dataKey="label" tickLine={false} axisLine={false} tick={{ fontSize: 10, fill: "var(--color-muted-foreground)" }} />
                <Bar dataKey="current" fill="var(--color-chart-1)" radius={[4, 4, 0, 0]} barSize={16} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </Section>

      <Section title="Recent transactions" action="Withdraw" actionTo="/withdraw">
        <div className="ink-card divide-y divide-border overflow-hidden">
          {transactions.map((t) => (
            <div key={t.id} className="flex items-center gap-3 p-3.5">
              <div className="min-w-0 flex-1">
                <p className="truncate text-[13.5px] font-semibold">{t.label}</p>
                <p className="text-[11px] text-muted-foreground">
                  {t.id} · {t.date}
                </p>
              </div>
              <span className={`text-[13.5px] font-bold ${t.type === "debit" ? "text-muted-foreground" : ""}`}>
                {t.type === "debit" ? "−" : "+"}₹{t.amount.toLocaleString("en-IN")}
              </span>
            </div>
          ))}
        </div>
      </Section>

      <div className="px-4">
        <Link to="/withdraw" className="block rounded-full bg-foreground py-3.5 text-center text-[14px] font-bold text-background">
          Request withdraw
        </Link>
      </div>
    </div>
  );
}
