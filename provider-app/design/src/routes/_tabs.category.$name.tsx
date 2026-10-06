import { createFileRoute } from "@tanstack/react-router";
import { Star, Clock } from "lucide-react";
import { Money, Section, TopBar } from "@/components/app/ui";
import { servicesByCategory } from "@/data/mock";

export const Route = createFileRoute("/_tabs/category/$name")({
  head: () => ({
    meta: [
      { title: "Category services — Ink Partner" },
      { name: "description", content: "Service list with price, duration and availability toggles." },
      { property: "og:title", content: "Category services — Ink Partner" },
      { property: "og:description", content: "Service list with price, duration and availability toggles." },
      { name: "robots", content: "noindex" },
    ],
  }),
  component: CategoryPage,
});

function CategoryPage() {
  const { name } = Route.useParams();
  const list = servicesByCategory[name] ?? [];

  return (
    <div className="space-y-6 pb-8">
      <TopBar title={name} subtitle={`${list.length} services`} back="/services" />

      <Section title="Services">
        <div className="space-y-3">
          {list.map((s) => (
            <div key={s.name} className="ink-card p-4">
              <div className="flex items-start gap-3">
                <div className="flex size-14 shrink-0 items-center justify-center rounded-xl bg-secondary font-display text-lg font-bold">
                  {s.name[0]}
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-[14px] font-bold leading-snug">{s.name}</p>
                  <p className="mt-1 flex items-center gap-3 text-[11.5px] text-muted-foreground">
                    <span className="flex items-center gap-1">
                      <Clock className="size-3" /> {s.time}
                    </span>
                    <span className="flex items-center gap-1">
                      <Star className="size-3 fill-foreground" /> {s.rating}
                    </span>
                  </p>
                  <Money value={s.price} className="mt-1.5 block text-[15px] font-bold" />
                </div>
                <span
                  className={`mt-1 flex h-6 w-11 shrink-0 items-center rounded-full p-0.5 ${
                    s.active ? "bg-foreground" : "bg-border"
                  }`}
                >
                  <span
                    className={`size-5 rounded-full bg-background transition-transform ${
                      s.active ? "translate-x-5" : ""
                    }`}
                  />
                </span>
              </div>
            </div>
          ))}
          {list.length === 0 ? (
            <div className="ink-card p-8 text-center text-[13px] text-muted-foreground">
              Subscribe to this category to list services.
            </div>
          ) : null}
        </div>
      </Section>

      <Section title="FAQ">
        <div className="ink-card divide-y divide-border">
          {[
            ["Kya material provider deta hai?", "Haan, basic material service price me included hai."],
            ["Re-schedule kaise hoga?", "Booking details se date/time edit kar sakte ho, 4 ghante pehle."],
            ["Warranty milti hai?", "Repair services par 30 din ki service warranty milti hai."],
          ].map(([q, a]) => (
            <div key={q} className="p-3.5">
              <p className="text-[13px] font-semibold">{q}</p>
              <p className="mt-1 text-[12px] text-muted-foreground">{a}</p>
            </div>
          ))}
        </div>
      </Section>
    </div>
  );
}
