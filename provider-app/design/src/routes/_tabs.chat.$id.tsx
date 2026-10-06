import { createFileRoute } from "@tanstack/react-router";
import { Paperclip, Send } from "lucide-react";
import { TopBar } from "@/components/app/ui";
import { chats, messages } from "@/data/mock";

export const Route = createFileRoute("/_tabs/chat/$id")({
  head: () => ({
    meta: [
      { title: "Conversation — Ink Partner" },
      { name: "description", content: "Chat with a customer or serviceman about a booking." },
      { property: "og:title", content: "Conversation — Ink Partner" },
      { property: "og:description", content: "Chat with a customer or serviceman about a booking." },
      { name: "robots", content: "noindex" },
    ],
  }),
  component: ChatDetails,
});

function ChatDetails() {
  const { id } = Route.useParams();
  const chat = chats.find((c) => c.id === id) ?? chats[0]!;

  return (
    <div className="flex min-h-screen flex-col">
      <TopBar title={chat.name} subtitle={`${chat.type} · online`} back="/chat" />

      <div className="flex-1 space-y-3 px-4 py-5">
        {messages.map((m, i) => (
          <div key={i} className={m.from === "me" ? "flex justify-end" : "flex justify-start"}>
            <div
              className={`max-w-[78%] rounded-2xl px-3.5 py-2.5 text-[13px] ${
                m.from === "me"
                  ? "rounded-br-sm bg-foreground text-background"
                  : "rounded-bl-sm border border-border bg-card"
              }`}
            >
              <p>{m.text}</p>
              <p
                className={`mt-1 text-right text-[10px] ${
                  m.from === "me" ? "text-background/60" : "text-muted-foreground"
                }`}
              >
                {m.time}
              </p>
            </div>
          </div>
        ))}
      </div>

      <div className="sticky bottom-24 mx-4 mb-4 flex items-center gap-2 rounded-full border border-border bg-card p-1.5 pl-4 shadow-[var(--shadow-card)]">
        <button aria-label="Attach">
          <Paperclip className="size-[18px] text-muted-foreground" />
        </button>
        <input
          placeholder="Type a message"
          className="flex-1 bg-transparent text-[13px] outline-none placeholder:text-muted-foreground"
        />
        <button
          aria-label="Send"
          className="flex size-9 items-center justify-center rounded-full bg-foreground text-background"
        >
          <Send className="size-4" />
        </button>
      </div>
    </div>
  );
}
