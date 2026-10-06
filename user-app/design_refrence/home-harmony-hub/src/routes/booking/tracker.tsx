import { createFileRoute, Link } from '@tanstack/react-router';
import { useState } from 'react';
import { format, parseISO } from 'date-fns';
import { CalendarDays, Check, Clock3, Headphones, MapPin, MessageSquare, Phone, Star, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { AppShell } from '@/components/app-shell';
import { useBooking } from '@/lib/booking-context';
import { getService, money } from '@/lib/services';

export const Route = createFileRoute('/booking/tracker')({
  head: () => ({ meta: [
    { title: 'My bookings | nest.' },
    { name: 'description', content: 'Track the status of your home service booking with nest.' },
    { property: 'og:title', content: 'My bookings | nest.' },
    { property: 'og:description', content: 'See every step of your home service visit.' },
    { property: 'og:type', content: 'website' },
    { name: 'twitter:card', content: 'summary_large_image' },
  ] }),
  component: Tracker,
});

const steps = [
  { t: 'Booking placed', d: 'We’ve received your request' },
  { t: 'Professional assigned', d: 'Your pro will be confirmed soon' },
  { t: 'On the way', d: 'Live updates when your pro heads out' },
  { t: 'Service completed', d: 'Pay and rate your experience' },
];

function Tracker() {
  const { booking, reset } = useBooking();
  const [confirmCancel, setConfirmCancel] = useState(false);
  const service = getService(booking.serviceId);
  const current = 0;

  if (!booking.confirmed) return (
    <AppShell>
      <div className="mx-auto max-w-6xl px-4 pt-5 md:px-8 md:pt-10">
        <h1 className="font-display text-2xl font-extrabold md:text-4xl">My bookings</h1>
        <div className="mt-6 flex gap-2"><span className="rounded-full bg-primary px-4 py-1.5 text-xs font-semibold text-primary-foreground">Upcoming</span><span className="rounded-full border border-border px-4 py-1.5 text-xs font-semibold text-muted-foreground">Past</span></div>
        <div className="py-20 text-center">
          <span className="mx-auto flex size-16 items-center justify-center rounded-full bg-secondary"><CalendarDays size={24} /></span>
          <h2 className="mt-4 font-display text-lg font-bold">No upcoming bookings</h2>
          <p className="mx-auto mt-1 max-w-xs text-sm text-muted-foreground">When you book a service, you can track every step of it right here.</p>
          <Button asChild className="mt-6 rounded-full px-6"><Link to="/services" search={{ q: '', category: '' }}>Book a service</Link></Button>
        </div>
      </div>
    </AppShell>
  );

  return (
    <AppShell>
      <div className="mx-auto max-w-5xl px-4 pt-5 md:px-8 md:pt-10">
        <div className="flex items-center justify-between"><h1 className="font-display text-2xl font-extrabold md:text-4xl">Booking status</h1><span className="rounded-full bg-secondary px-3 py-1 text-[11px] font-bold uppercase tracking-wider">Preview</span></div>

        <div className="mt-5 grid gap-5 lg:grid-cols-[minmax(0,1fr)_360px]">
          <div className="space-y-4">
            <section className="rounded-3xl bg-primary p-5 text-primary-foreground">
              <p className="text-xs font-semibold opacity-70">Scheduled for</p>
              <p className="mt-1 font-display text-2xl font-extrabold">{format(parseISO(booking.date), 'EEEE, d MMM')}</p>
              <p className="mt-0.5 flex items-center gap-1.5 text-sm opacity-80"><Clock3 size={14} />{booking.slot} · {service.duration}</p>
              <div className="mt-5 flex items-center gap-3 rounded-2xl bg-primary-foreground/10 p-3">
                <span className="flex size-11 items-center justify-center rounded-full bg-background font-display text-sm font-extrabold text-foreground">RS</span>
                <div className="min-w-0 flex-1"><p className="text-sm font-bold">Rahul S.</p><p className="flex items-center gap-1 text-xs opacity-70"><Star size={11} fill="currentColor" />4.9 · 320+ jobs</p></div>
                <button aria-label="Message professional" className="flex size-10 items-center justify-center rounded-full bg-background text-foreground"><MessageSquare size={16} /></button>
                <button aria-label="Call professional" className="flex size-10 items-center justify-center rounded-full bg-background text-foreground"><Phone size={16} /></button>
              </div>
              <p className="mt-2 text-[11px] opacity-60">Sample professional shown for preview.</p>
            </section>

            <section className="rounded-2xl border border-border p-5">
              <h2 className="text-sm font-bold">Progress</h2>
              <ol className="mt-4">
                {steps.map((s, i) => { const done = i <= current; return (
                  <li key={s.t} className="relative flex gap-4 pb-6 last:pb-0">
                    {i < steps.length - 1 && <span className={`absolute left-[13px] top-7 h-[calc(100%-28px)] w-0.5 ${i < current ? 'bg-primary' : 'bg-border'}`} />}
                    <span className={`relative flex size-7 shrink-0 items-center justify-center rounded-full border-2 ${done ? 'border-primary bg-primary text-primary-foreground' : 'border-border bg-background'}`}>{done ? <Check size={14} /> : <span className="size-2 rounded-full bg-border" />}</span>
                    <div><p className={`text-sm font-bold ${done ? '' : 'text-muted-foreground'}`}>{s.t}</p><p className="text-xs text-muted-foreground">{s.d}</p></div>
                  </li>); })}
              </ol>
            </section>
          </div>

          <aside className="h-fit space-y-4 lg:sticky lg:top-24">
            <section className="rounded-2xl border border-border p-4">
              <div className="flex gap-3"><img src={service.image} alt={service.name} width={1024} height={768} className="size-14 rounded-xl object-cover" /><div><h3 className="font-display text-sm font-bold">{service.name}</h3><p className="text-xs text-muted-foreground">Total {money(service.price)} · Pay after service</p></div></div>
              <div className="mt-4 flex gap-2 border-t border-border pt-4 text-xs"><MapPin size={15} className="shrink-0" /><p className="text-muted-foreground">{booking.address}</p></div>
              {booking.instructions && <p className="mt-2 rounded-xl bg-secondary p-3 text-xs text-muted-foreground">“{booking.instructions}”</p>}
            </section>
            <div className="grid grid-cols-2 gap-2">
              <Button asChild variant="outline" className="h-11 rounded-xl"><Link to="/services/$serviceId" params={{ serviceId: service.id }}>Reschedule</Link></Button>
              <Button variant="outline" className="h-11 rounded-xl" onClick={() => setConfirmCancel(true)}>Cancel</Button>
            </div>
            <button className="flex w-full items-center gap-3 rounded-2xl bg-secondary p-4 text-left"><Headphones size={18} /><div><p className="text-sm font-bold">Need help?</p><p className="text-xs text-muted-foreground">Support available 8 AM – 10 PM</p></div></button>
          </aside>
        </div>
      </div>

      {confirmCancel && (
        <div className="fixed inset-0 z-50 flex items-end justify-center bg-foreground/40 p-0 sm:items-center sm:p-4" onClick={() => setConfirmCancel(false)}>
          <div role="dialog" aria-modal="true" aria-labelledby="cancel-title" className="w-full max-w-md rounded-t-3xl bg-background p-6 pb-[calc(1.5rem+env(safe-area-inset-bottom))] sm:rounded-3xl" onClick={e => e.stopPropagation()}>
            <div className="flex items-start justify-between"><h2 id="cancel-title" className="font-display text-lg font-bold">Cancel this booking?</h2><button aria-label="Close" onClick={() => setConfirmCancel(false)} className="flex size-8 items-center justify-center rounded-full bg-secondary"><X size={16} /></button></div>
            <p className="mt-2 text-sm text-muted-foreground">Your {service.name.toLowerCase()} on {format(parseISO(booking.date), 'd MMM')} at {booking.slot} will be cancelled. No charges apply.</p>
            <div className="mt-6 grid grid-cols-2 gap-2"><Button variant="outline" className="h-12 rounded-xl" onClick={() => setConfirmCancel(false)}>Keep booking</Button><Button variant="destructive" className="h-12 rounded-xl" onClick={() => { reset(); setConfirmCancel(false); }}>Yes, cancel</Button></div>
          </div>
        </div>
      )}
    </AppShell>
  );
}
