import { Link, type LinkProps } from "@tanstack/react-router";
import { ChevronLeft, ChevronRight } from "lucide-react";
import type { ReactNode } from "react";
import { cn } from "@/lib/utils";
import type { BookingStatus } from "@/data/mock";
import { statusLabel } from "@/data/mock";

export function TopBar({
  title,
  subtitle,
  back = "/",
  right,
}: {
  title: string;
  subtitle?: string;
  back?: NonNullable<LinkProps["to"]>;
  right?: ReactNode;
}) {
  return (
    <header className="sticky top-0 z-30 border-b border-border bg-background/85 backdrop-blur-xl">
      <div className="flex items-center gap-3 px-4 py-3.5">
        <Link
          to={back}
          className="flex size-9 shrink-0 items-center justify-center rounded-full border border-border bg-card"
          aria-label="Back"
        >
          <ChevronLeft className="size-4" />
        </Link>
        <div className="min-w-0 flex-1">
          <h1 className="truncate text-[17px] font-bold leading-tight">{title}</h1>
          {subtitle ? (
            <p className="truncate text-[11px] text-muted-foreground">{subtitle}</p>
          ) : null}
        </div>
        {right}
      </div>
    </header>
  );
}

export function Section({
  title,
  action,
  actionTo,
  children,
  className,
}: {
  title: string;
  action?: string;
  actionTo?: NonNullable<LinkProps["to"]>;
  children: ReactNode;
  className?: string;
}) {
  return (
    <section className={cn("px-4", className)}>
      <div className="mb-3 flex items-end justify-between">
        <h2 className="text-[15px] font-bold tracking-tight">{title}</h2>
        {action ? (
          actionTo ? (
            <Link to={actionTo} className="text-[12px] font-semibold text-muted-foreground underline underline-offset-4">
              {action}
            </Link>
          ) : (
            <span className="text-[12px] font-semibold text-muted-foreground">{action}</span>
          )
        ) : null}
      </div>
      {children}
    </section>
  );
}

const statusStyles: Record<BookingStatus, string> = {
  pending: "border-ink/25 bg-secondary text-foreground",
  accepted: "border-ink/25 bg-foreground/10 text-foreground",
  ongoing: "border-transparent bg-foreground text-background",
  completed: "border-ink/20 bg-card text-muted-foreground",
  canceled: "border-destructive/30 bg-destructive/10 text-destructive",
};

export function StatusChip({ status }: { status: BookingStatus }) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border px-2.5 py-1 text-[10px] font-bold uppercase tracking-[0.08em]",
        statusStyles[status],
      )}
    >
      {statusLabel[status]}
    </span>
  );
}

export function RowLink({
  title,
  meta,
  to,
  leading,
  trailing,
}: {
  title: string;
  meta?: string;
  to: NonNullable<LinkProps["to"]>;
  leading?: ReactNode;
  trailing?: ReactNode;
}) {
  return (
    <Link
      to={to}
      className="flex items-center gap-3 border-b border-border px-4 py-3.5 last:border-0 active:bg-secondary"
    >
      {leading}
      <div className="min-w-0 flex-1">
        <p className="truncate text-[14px] font-semibold">{title}</p>
        {meta ? <p className="truncate text-[12px] text-muted-foreground">{meta}</p> : null}
      </div>
      {trailing ?? <ChevronRight className="size-4 text-muted-foreground" />}
    </Link>
  );
}

export function Avatar({ name, size = 40 }: { name: string; size?: number }) {
  const initials = name
    .split(" ")
    .map((p) => p[0])
    .slice(0, 2)
    .join("");
  return (
    <span
      className="flex shrink-0 items-center justify-center rounded-full bg-foreground font-bold text-background"
      style={{ width: size, height: size, fontSize: size * 0.34 }}
    >
      {initials}
    </span>
  );
}

export function Money({ value, className }: { value: number; className?: string }) {
  return (
    <span className={cn("font-display tabular-nums", className)}>
      ₹{value.toLocaleString("en-IN")}
    </span>
  );
}

export function Stat({ label, value, delta }: { label: string; value: string; delta?: string }) {
  return (
    <div className="ink-card p-3.5">
      <p className="eyebrow">{label}</p>
      <p className="mt-2 font-display text-2xl font-bold leading-none">{value}</p>
      {delta ? <p className="mt-1.5 text-[11px] text-muted-foreground">{delta}</p> : null}
    </div>
  );
}

export function Pills({
  items,
  value,
  onChange,
}: {
  items: string[];
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <div className="no-scrollbar flex gap-2 overflow-x-auto">
      {items.map((item) => (
        <button
          key={item}
          onClick={() => onChange(item)}
          className={cn(
            "shrink-0 rounded-full border px-3.5 py-1.5 text-[12px] font-semibold transition-colors",
            value === item
              ? "border-transparent bg-foreground text-background"
              : "border-border bg-card text-muted-foreground",
          )}
        >
          {item}
        </button>
      ))}
    </div>
  );
}

export function EmptyState({ text }: { text: string }) {
  return (
    <div className="ink-card p-8 text-center text-[13px] text-muted-foreground">{text}</div>
  );
}
