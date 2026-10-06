import { createFileRoute, notFound } from "@tanstack/react-router";
import { Phone, MapPin, FileText, UserPlus, Check } from "lucide-react";
import { Avatar, Money, Section, StatusChip, TopBar } from "@/components/app/ui";
import { bookings, servicemen } from "@/data/mock";

export const Route = createFileRoute("/_tabs/booking/$id")({
  head: () => ({
    meta: [
      { title: "Booking details — Ink Partner" },
      { name: "description", content: "Customer, service items, timeline and payment for this booking." },
      { property: "og:title", content: "Booking details — Ink Partner" },
      { property: "og:description", content: "Customer, service items, timeline and payment for this booking." },
      { name: "robots", content: "noindex" },
    ],
  }),
  component: BookingDetails,
});

const timeline = ["Requested", "Accepted", "Ongoing", "Completed"];

function BookingDetails() {
  const { id } = Route.useParams();
  const booking = bookings.find((b) => b.id === id);
  if (!booking) throw notFound();

  const stageIndex =
    booking.status === "completed"
      ? 3
      : booking.status === "ongoing"
        ? 2
        : booking.status === "accepted"
          ? 1
          : 0;

  return (
    <div className="space-y-6 pb-8">
      <TopBar title={booking.code} subtitle={booking.service} back="/requests" />

      <div className="px-4">
        <div className="ink-card p-4">
          <div className="flex items-center gap-3">
            <Avatar name={booking.customer} size={46} />
            <div className="min-w-0 flex-1">
              <p className="text-[15px] font-bold">{booking.customer}</p>
              <p className="text-[12px] text-muted-foreground">{booking.phone}</p>
            </div>
            <StatusChip status={booking.status} />
          </div>
          <div className="mt-4 grid grid-cols-2 gap-2">
            <button className="flex items-center justify-center gap-2 rounded-full border border-border py-2.5 text-[12.5px] font-semibold">
              <Phone className="size-4" /> Call
            </button>
            <button className="flex items-center justify-center gap-2 rounded-full border border-border py-2.5 text-[12.5px] font-semibold">
              <MapPin className="size-4" /> Navigate
            </button>
          </div>
        </div>
      </div>

      <Section title="Schedule & address">
        <div className="ink-card divide-y divide-border">
          <Row label="Date & time" value={`${booking.date} · ${booking.time}`} />
          <Row label="Address" value={booking.address} />
          <Row label="Booking type" value={booking.type === "repeat" ? "Repeat / recurring" : "Regular"} />
        </div>
      </Section>

      <Section title="Progress">
        <div className="ink-card p-4">
          {timeline.map((step, i) => (
            <div key={step} className="flex gap-3">
              <div className="flex flex-col items-center">
                <span
                  className={`flex size-6 items-center justify-center rounded-full border text-[10px] font-bold ${
                    i <= stageIndex
                      ? "border-transparent bg-foreground text-background"
                      : "border-border text-muted-foreground"
                  }`}
                >
                  {i <= stageIndex ? <Check className="size-3.5" /> : i + 1}
                </span>
                {i < timeline.length - 1 ? (
                  <span className={`h-8 w-px ${i < stageIndex ? "bg-foreground" : "bg-border"}`} />
                ) : null}
              </div>
              <div className="pb-1">
                <p className={`text-[13.5px] font-semibold ${i <= stageIndex ? "" : "text-muted-foreground"}`}>
                  {step}
                </p>
                <p className="text-[11px] text-muted-foreground">
                  {i <= stageIndex ? `${booking.date} · ${booking.time}` : "Pending"}
                </p>
              </div>
            </div>
          ))}
        </div>
      </Section>

      <Section title="Service items">
        <div className="ink-card p-4">
          {booking.items.map((item) => (
            <div key={item.name} className="flex justify-between border-b border-border py-2.5 first:pt-0 last:border-0 last:pb-0">
              <p className="text-[13px]">
                {item.name} <span className="text-muted-foreground">×{item.qty}</span>
              </p>
              <Money value={item.price * item.qty} className="text-[13px] font-semibold" />
            </div>
          ))}
          <div className="mt-3 flex justify-between border-t border-border pt-3">
            <p className="text-[13px] font-bold">Total ({booking.payment})</p>
            <Money value={booking.amount} className="text-[16px] font-bold" />
          </div>
        </div>
      </Section>

      <Section title="Assign serviceman">
        <div className="ink-card divide-y divide-border">
          {servicemen.slice(0, 3).map((s) => (
            <div key={s.id} className="flex items-center gap-3 p-3.5">
              <Avatar name={s.name} size={36} />
              <div className="min-w-0 flex-1">
                <p className="truncate text-[13.5px] font-semibold">{s.name}</p>
                <p className="truncate text-[11px] text-muted-foreground">
                  {s.role} · {s.status}
                </p>
              </div>
              <span
                className={`rounded-full px-3 py-1.5 text-[11px] font-semibold ${
                  booking.serviceman === s.name
                    ? "bg-foreground text-background"
                    : "border border-border"
                }`}
              >
                {booking.serviceman === s.name ? "Assigned" : "Assign"}
              </span>
            </div>
          ))}
        </div>
      </Section>

      <div className="space-y-2 px-4">
        <button className="flex w-full items-center justify-center gap-2 rounded-full bg-foreground py-3.5 text-[14px] font-bold text-background">
          {booking.status === "pending"
            ? "Accept booking"
            : booking.status === "accepted"
              ? "Start service"
              : booking.status === "ongoing"
                ? "Mark completed"
                : "Download invoice"}
        </button>
        <div className="grid grid-cols-2 gap-2">
          <button className="flex items-center justify-center gap-2 rounded-full border border-border py-3 text-[13px] font-semibold">
            <FileText className="size-4" /> Invoice
          </button>
          <button className="flex items-center justify-center gap-2 rounded-full border border-border py-3 text-[13px] font-semibold">
            <UserPlus className="size-4" /> Edit booking
          </button>
        </div>
        <button className="w-full rounded-full py-2 text-[12.5px] font-semibold text-destructive">
          Cancel booking
        </button>
      </div>
    </div>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-start justify-between gap-6 p-3.5">
      <p className="text-[12px] text-muted-foreground">{label}</p>
      <p className="text-right text-[13px] font-semibold">{value}</p>
    </div>
  );
}
