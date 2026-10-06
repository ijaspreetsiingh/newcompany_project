import { createFileRoute, Link } from "@tanstack/react-router";
import { ChevronRight, LogOut, Star } from "lucide-react";
import { Avatar } from "@/components/app/ui";
import { moreMenu, provider } from "@/data/mock";

export const Route = createFileRoute("/_tabs/more")({
  head: () => ({
    meta: [
      { title: "More — Ink Partner" },
      { name: "description", content: "Profile, plan, payments, reports and support for your business." },
      { property: "og:title", content: "More — Ink Partner" },
      { property: "og:description", content: "Profile, plan, payments, reports and support for your business." },
    ],
  }),
  component: More,
});

const groups = ["Business", "Operations", "Money", "Settings", "Legal"] as const;

function More() {
  return (
    <div className="space-y-6 pb-8">
      <header className="sticky top-0 z-30 border-b border-border bg-background/90 px-4 pb-3 pt-4 backdrop-blur-xl">
        <h1 className="font-display text-[22px] font-bold">More</h1>
      </header>

      <div className="px-4">
        <Link to="/profile" className="ink-card flex items-center gap-3 p-4">
          <Avatar name={provider.owner} size={52} />
          <div className="min-w-0 flex-1">
            <p className="text-[15px] font-bold">{provider.business}</p>
            <p className="text-[12px] text-muted-foreground">{provider.owner} · {provider.city}</p>
            <p className="mt-1 flex items-center gap-1 text-[11.5px] font-semibold">
              <Star className="size-3 fill-foreground" /> {provider.rating} ({provider.reviews})
            </p>
          </div>
          <ChevronRight className="size-4 text-muted-foreground" />
        </Link>
      </div>

      {groups.map((group) => (
        <div key={group} className="px-4">
          <p className="eyebrow mb-2">{group}</p>
          <div className="ink-card divide-y divide-border overflow-hidden">
            {moreMenu
              .filter((m) => m.group === group)
              .map((m) => (
                <Link
                  key={m.label}
                  to={m.to}
                  className="flex items-center gap-3 px-4 py-3.5 active:bg-secondary"
                >
                  <span className="flex-1 text-[13.5px] font-semibold">{m.label}</span>
                  <ChevronRight className="size-4 text-muted-foreground" />
                </Link>
              ))}
          </div>
        </div>
      ))}

      <div className="px-4">
        <Link
          to="/signin"
          className="flex w-full items-center justify-center gap-2 rounded-full border border-border py-3.5 text-[13.5px] font-bold text-destructive"
        >
          <LogOut className="size-4" /> Logout
        </Link>
        <p className="mt-3 text-center text-[11px] text-muted-foreground">Ink Partner · v2.4.1</p>
      </div>
    </div>
  );
}
