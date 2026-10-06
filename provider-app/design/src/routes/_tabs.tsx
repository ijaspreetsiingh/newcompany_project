import { createFileRoute, Link, Outlet, useRouterState } from "@tanstack/react-router";
import { LayoutGrid, Inbox, Grid2x2, Menu, Plus } from "lucide-react";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/_tabs")({
  component: TabsLayout,
});

const tabs = [
  { to: "/", label: "Dashboard", icon: LayoutGrid },
  { to: "/requests", label: "Requests", icon: Inbox },
  { to: "/services", label: "Services", icon: Grid2x2 },
  { to: "/more", label: "More", icon: Menu },
] as const;

function TabsLayout() {
  const pathname = useRouterState({ select: (s) => s.location.pathname });

  const isActive = (to: string) => (to === "/" ? pathname === "/" : pathname.startsWith(to));

  return (
    <div className="mx-auto min-h-screen w-full max-w-[460px] bg-background pb-24 shadow-[0_0_60px_-30px_rgba(0,0,0,0.4)]">
      <Outlet />

      <nav className="fixed bottom-0 left-1/2 z-40 w-full max-w-[460px] -translate-x-1/2 border-t border-border bg-background/95 backdrop-blur-xl">
        <div className="relative grid grid-cols-5 items-end px-2 pb-3 pt-2">
          {tabs.slice(0, 2).map((t) => (
            <TabItem key={t.to} {...t} active={isActive(t.to)} />
          ))}

          <div className="flex justify-center">
            <Link
              to="/bids"
              aria-label="Custom requests"
              className="-mt-8 flex size-14 items-center justify-center rounded-full bg-foreground text-background shadow-[var(--shadow-float)] active:scale-95"
            >
              <Plus className="size-6" />
            </Link>
          </div>

          {tabs.slice(2).map((t) => (
            <TabItem key={t.to} {...t} active={isActive(t.to)} />
          ))}
        </div>
      </nav>
    </div>
  );
}

function TabItem({
  to,
  label,
  icon: Icon,
  active,
}: {
  to: string;
  label: string;
  icon: typeof LayoutGrid;
  active: boolean;
}) {
  return (
    <Link
      to={to}
      className={cn(
        "flex flex-col items-center gap-1 py-1 text-[10px] font-semibold tracking-wide",
        active ? "text-foreground" : "text-muted-foreground",
      )}
    >
      <Icon className={cn("size-[19px]", active && "stroke-[2.4]")} />
      {label}
      <span className={cn("h-1 w-1 rounded-full", active ? "bg-foreground" : "bg-transparent")} />
    </Link>
  );
}
