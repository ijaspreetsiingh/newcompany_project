import { createFileRoute, Link } from "@tanstack/react-router";
import { Check, Plus } from "lucide-react";
import { categories } from "@/data/mock";

export const Route = createFileRoute("/_tabs/services")({
  head: () => ({
    meta: [
      { title: "Service catalog — Ink Partner" },
      { name: "description", content: "Manage subscribed categories, sub-categories and service pricing." },
      { property: "og:title", content: "Service catalog — Ink Partner" },
      { property: "og:description", content: "Manage subscribed categories, sub-categories and service pricing." },
    ],
  }),
  component: Services,
});

function Services() {
  return (
    <div className="pb-8">
      <header className="sticky top-0 z-30 border-b border-border bg-background/90 px-4 pb-3 pt-4 backdrop-blur-xl">
        <h1 className="font-display text-[22px] font-bold">Services</h1>
        <p className="text-[12px] text-muted-foreground">
          {categories.filter((c) => c.subscribed).length} of {categories.length} categories subscribed
        </p>
      </header>

      <div className="grid grid-cols-2 gap-3 px-4 pt-4">
        {categories.map((c) => (
          <Link
            key={c.name}
            to="/category/$name"
            params={{ name: c.name }}
            className="ink-card relative flex h-[128px] flex-col justify-between p-4"
          >
            <span
              className={`inline-flex size-7 items-center justify-center rounded-full ${
                c.subscribed ? "bg-foreground text-background" : "border border-border text-muted-foreground"
              }`}
            >
              {c.subscribed ? <Check className="size-3.5" /> : <Plus className="size-3.5" />}
            </span>
            <div>
              <p className="text-[14px] font-bold leading-tight">{c.name}</p>
              <p className="mt-1 text-[11px] text-muted-foreground">
                {c.subs} sub-categories · {c.services} services
              </p>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
