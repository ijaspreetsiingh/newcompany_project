import { createFileRoute } from "@tanstack/react-router";
import { Bell } from "lucide-react";
import { TopBar } from "@/components/app/ui";
import { notifications } from "@/data/mock";

export const Route = createFileRoute("/_tabs/notifications")({
  head: () => ({
    meta: [
      { title: "Notifications — Ink Partner" },
      { name: "description", content: "Booking alerts, payouts and plan reminders in one place." },
      { property: "og:title", content: "Notifications — Ink Partner" },
      { property: "og:description", content: "Booking alerts, payouts and plan reminders in one place." },
    ],
  }),
  component: Notifications,
});

function Notifications() {
  return (
    <div className="space-y-4 pb-8">
      <TopBar title="Notifications" subtitle="2 unseen" back="/" />
      <div className="ink-card mx-4 divide-y divide-border overflow-hidden">
        {notifications.map((n) => (
          <div key={n.title + n.time} className="flex gap-3 p-4">
            <span
              className={`flex size-9 shrink-0 items-center justify-center rounded-full ${
                n.unseen ? "bg-foreground text-background" : "border border-border text-muted-foreground"
              }`}
            >
              <Bell className="size-4" />
            </span>
            <div className="min-w-0 flex-1">
              <p className="text-[13.5px] font-semibold">{n.title}</p>
              <p className="truncate text-[12px] text-muted-foreground">{n.body}</p>
            </div>
            <p className="shrink-0 text-[10.5px] text-muted-foreground">{n.time}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
