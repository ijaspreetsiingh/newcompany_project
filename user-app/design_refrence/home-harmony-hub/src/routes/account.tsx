import { createFileRoute, Link } from '@tanstack/react-router';
import { Bell, CalendarDays, ChevronRight, CircleHelp, FileText, LayoutGrid, MapPin, ShieldCheck, UserRound } from 'lucide-react';
import { AppShell } from '@/components/app-shell';
import { useBooking } from '@/lib/booking-context';

export const Route = createFileRoute('/account')({
  head: () => ({ meta: [
    { title: 'Account | nest.' },
    { name: 'description', content: 'Manage your nest. profile, saved address, bookings and support.' },
    { property: 'og:title', content: 'Account | nest.' },
    { property: 'og:description', content: 'Your profile, addresses and help in one place.' },
    { property: 'og:type', content: 'website' },
    { name: 'twitter:card', content: 'summary_large_image' },
  ] }),
  component: Account,
});

function Row({ icon: Icon, title, sub, to }: { icon: typeof Bell; title: string; sub?: string; to?: '/booking/tracker' | '/services' }) {
  const inner = <><span className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-secondary"><Icon size={18} /></span><div className="min-w-0 flex-1"><p className="text-sm font-semibold">{title}</p>{sub && <p className="truncate text-xs text-muted-foreground">{sub}</p>}</div><ChevronRight size={18} className="text-muted-foreground" /></>;
  const cls = 'flex w-full items-center gap-3 px-4 py-3.5 text-left transition-colors hover:bg-secondary/60';
  return to ? <Link to={to} search={to === '/services' ? { q: '', category: '' } : {}} className={cls}>{inner}</Link> : <button className={cls}>{inner}</button>;
}

function Account() {
  const { booking } = useBooking();
  return (
    <AppShell>
      <div className="mx-auto max-w-2xl px-4 pt-5 md:px-8 md:pt-10">
        <h1 className="font-display text-2xl font-extrabold md:text-4xl">Account</h1>
        <section className="mt-5 flex items-center gap-4 rounded-3xl bg-primary p-5 text-primary-foreground">
          <span className="flex size-14 items-center justify-center rounded-full bg-background text-foreground"><UserRound size={24} /></span>
          <div className="min-w-0 flex-1"><p className="font-display text-lg font-bold">Your profile</p><p className="text-xs opacity-70">Name and phone from your signed-in account</p></div>
        </section>
        <div className="mt-5 divide-y divide-border overflow-hidden rounded-2xl border border-border">
          <Row icon={CalendarDays} title="My bookings" sub={booking.confirmed ? '1 upcoming booking' : 'No upcoming bookings'} to="/booking/tracker" />
          <Row icon={MapPin} title="Saved addresses" sub={booking.address || 'Home · New Delhi'} />
          <Row icon={LayoutGrid} title="Browse services" to="/services" />
          <Row icon={Bell} title="Notifications" sub="Booking updates and reminders" />
        </div>
        <div className="mt-4 divide-y divide-border overflow-hidden rounded-2xl border border-border">
          <Row icon={CircleHelp} title="Help & support" sub="8 AM – 10 PM, every day" />
          <Row icon={ShieldCheck} title="Privacy & safety" />
          <Row icon={FileText} title="Terms & policies" />
        </div>
        <p className="mt-8 text-center text-xs text-muted-foreground">nest. · Home, handled. · v1.0</p>
      </div>
    </AppShell>
  );
}
