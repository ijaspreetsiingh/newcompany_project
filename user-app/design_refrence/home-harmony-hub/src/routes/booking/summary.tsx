import { createFileRoute, Link, useNavigate } from '@tanstack/react-router';
import { useState } from 'react';
import { format, parseISO } from 'date-fns';
import { ArrowRight, CalendarDays, Clock3, Home, Info, MapPin } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { AppShell, Steps } from '@/components/app-shell';
import { useBooking } from '@/lib/booking-context';
import { getService, money } from '@/lib/services';

export const Route = createFileRoute('/booking/summary')({
  head: () => ({ meta: [
    { title: 'Review your booking | nest.' },
    { name: 'description', content: 'Review your selected home service, schedule and address before confirming.' },
    { property: 'og:title', content: 'Review your booking | nest.' },
    { property: 'og:description', content: 'One last look before your home service is booked.' },
    { property: 'og:type', content: 'website' },
    { name: 'twitter:card', content: 'summary_large_image' },
  ] }),
  component: Summary,
});

function Summary() {
  const { booking, update } = useBooking();
  const navigate = useNavigate();
  const [touched, setTouched] = useState(false);
  const service = getService(booking.serviceId);
  const ready = !!booking.date && !!booking.slot;
  const addressOk = booking.address.trim().length >= 10;
  const submit = () => { setTouched(true); if (!addressOk) { document.getElementById('address')?.focus(); return; } update({ confirmed: true }); navigate({ to: '/booking/tracker' }); };
  const cta = <Button onClick={submit} className="h-13 w-full rounded-2xl text-sm font-bold">Preview booking · {money(service.price)} <ArrowRight size={16} /></Button>;

  if (!ready) return (
    <AppShell back title="Review booking">
      <div className="mx-auto max-w-md px-4 py-24 text-center">
        <span className="mx-auto flex size-14 items-center justify-center rounded-full bg-secondary"><CalendarDays size={22} /></span>
        <h1 className="mt-4 font-display text-xl font-bold">Pick a service and slot first</h1>
        <p className="mt-1 text-sm text-muted-foreground">Choose a date and time to review your booking.</p>
        <Button asChild className="mt-6 rounded-full"><Link to="/services" search={{ q: '', category: '' }}>Explore services</Link></Button>
      </div>
    </AppShell>
  );

  return (
    <AppShell back title="Review booking" hideTabs footer={cta}>
      <div className="mx-auto max-w-5xl px-4 pt-5 md:px-8 md:pt-8">
        <Steps current={2} />
        <div className="mt-6 grid gap-6 lg:grid-cols-[minmax(0,1fr)_360px]">
          <div className="space-y-4">
            <section className="flex gap-4 rounded-2xl border border-border p-3">
              <img src={service.image} alt={service.name} width={1024} height={768} className="size-20 shrink-0 rounded-xl object-cover" />
              <div className="flex min-w-0 flex-col justify-center"><p className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">{service.category}</p><h2 className="font-display text-base font-bold">{service.name}</h2><p className="text-xs text-muted-foreground">{service.duration}</p></div>
            </section>

            <section className="rounded-2xl border border-border">
              <div className="flex items-center justify-between p-4 pb-0"><h3 className="text-sm font-bold">Schedule</h3><Link to="/services/$serviceId" params={{ serviceId: service.id }} className="text-xs font-bold underline underline-offset-4">Change</Link></div>
              <div className="grid grid-cols-2 gap-3 p-4">
                <div className="flex items-center gap-3 rounded-xl bg-secondary p-3"><CalendarDays size={18} /><div><p className="text-[11px] text-muted-foreground">Date</p><p className="text-sm font-bold">{format(parseISO(booking.date), 'EEE, d MMM')}</p></div></div>
                <div className="flex items-center gap-3 rounded-xl bg-secondary p-3"><Clock3 size={18} /><div><p className="text-[11px] text-muted-foreground">Time</p><p className="text-sm font-bold">{booking.slot}</p></div></div>
              </div>
            </section>

            <section className="rounded-2xl border border-border p-4">
              <h3 className="flex items-center gap-2 text-sm font-bold"><MapPin size={16} />Service address</h3>
              <label htmlFor="address" className="sr-only">Full address</label>
              <textarea id="address" rows={3} value={booking.address} onChange={e => update({ address: e.target.value })} onBlur={() => setTouched(true)} placeholder="House / flat no., building, street, area, landmark" className={`mt-3 w-full resize-none rounded-xl border bg-secondary p-3 text-sm outline-none placeholder:text-muted-foreground focus:border-foreground ${touched && !addressOk ? 'border-destructive' : 'border-transparent'}`} />
              {touched && !addressOk && <p className="mt-1.5 text-xs font-medium text-destructive">Please enter your full address (at least 10 characters).</p>}
              <div className="mt-3 flex gap-2">{['Home', 'Work', 'Other'].map((t, i) => <span key={t} className={`flex items-center gap-1 rounded-full border px-3 py-1 text-xs font-semibold ${i === 0 ? 'border-primary bg-primary text-primary-foreground' : 'border-border text-muted-foreground'}`}>{i === 0 && <Home size={12} />}{t}</span>)}</div>
            </section>

            <section className="rounded-2xl border border-border p-4">
              <label htmlFor="notes" className="text-sm font-bold">Note for the professional <span className="font-normal text-muted-foreground">(optional)</span></label>
              <textarea id="notes" rows={2} value={booking.instructions} onChange={e => update({ instructions: e.target.value })} placeholder="E.g. gate code, pets at home, parking info" className="mt-3 w-full resize-none rounded-xl border border-transparent bg-secondary p-3 text-sm outline-none placeholder:text-muted-foreground focus:border-foreground" />
            </section>
          </div>

          <aside className="h-fit space-y-4 lg:sticky lg:top-24">
            <section className="rounded-2xl border border-border p-4">
              <h3 className="text-sm font-bold">Payment summary</h3>
              <dl className="mt-4 space-y-3 text-sm">
                <div className="flex justify-between"><dt className="text-muted-foreground">Service charge</dt><dd className="font-semibold">{money(service.price)}</dd></div>
                <div className="flex justify-between"><dt className="text-muted-foreground">Visit fee</dt><dd className="font-semibold">Free</dd></div>
                <div className="flex justify-between border-t border-dashed border-border pt-3 text-base"><dt className="font-bold">Total</dt><dd className="font-extrabold">{money(service.price)}</dd></div>
              </dl>
              <p className="mt-3 text-xs text-muted-foreground">Pay after the service. Extra parts, if needed, are quoted before any work.</p>
            </section>
            <p className="flex gap-2 rounded-2xl bg-secondary p-4 text-xs text-muted-foreground"><Info size={16} className="shrink-0 text-foreground" />Preview only — no service request will be sent. Free cancellation up to 2 hours before the visit.</p>
            <div className="hidden lg:block">{cta}</div>
          </aside>
        </div>
      </div>
    </AppShell>
  );
}
