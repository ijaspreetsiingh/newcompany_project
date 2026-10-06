import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import { Avatar, Pills, TopBar } from "@/components/app/ui";
import { chats } from "@/data/mock";

export const Route = createFileRoute("/_tabs/chat")({
  head: () => ({
    meta: [
      { title: "Inbox — Ink Partner" },
      { name: "description", content: "Conversations with customers and your service team." },
      { property: "og:title", content: "Inbox — Ink Partner" },
      { property: "og:description", content: "Conversations with customers and your service team." },
    ],
  }),
  component: Inbox,
});

function Inbox() {
  const [tab, setTab] = useState("All");
  const list = chats.filter((c) => tab === "All" || c.type === tab.replace(/s$/, ""));

  return (
    <div className="space-y-4 pb-8">
      <TopBar title="Inbox" subtitle={`${chats.length} conversations`} back="/more" />
      <div className="px-4">
        <Pills items={["All", "Customers", "Servicemen"]} value={tab} onChange={setTab} />
      </div>
      <div className="ink-card mx-4 divide-y divide-border overflow-hidden">
        {list.map((c) => (
          <Link
            key={c.id}
            to="/chat/$id"
            params={{ id: c.id }}
            className="flex items-center gap-3 p-3.5 active:bg-secondary"
          >
            <Avatar name={c.name} size={44} />
            <div className="min-w-0 flex-1">
              <p className="truncate text-[14px] font-semibold">{c.name}</p>
              <p className="truncate text-[12px] text-muted-foreground">{c.last}</p>
            </div>
            <div className="shrink-0 text-right">
              <p className="text-[10.5px] text-muted-foreground">{c.time}</p>
              {c.unread ? (
                <span className="mt-1 inline-flex size-5 items-center justify-center rounded-full bg-foreground text-[10px] font-bold text-background">
                  {c.unread}
                </span>
              ) : null}
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
