import { createFileRoute, Link, useNavigate } from '@tanstack/react-router';
import { useState } from 'react';
import { addDays, format } from 'date-fns';
import { ArrowRight, BadgeCheck, Check, Clock3, ShieldCheck, Star } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { AppShell } from '@/components/app-shell';
import { useBooking } from '@/lib/booking-context';
import { money, services } from '@/lib/services';

export const Route = createFileRoute('/services/$serviceId')({
  head: ({ params }) => { const s = services.find(i => i.id === params.serviceId); return { meta: [
    { title: `${s?.name ?? 'Service'} | nest.` },
    { name: 'description', content: s?.detail ?? 'Explore home services at nest.' },
    { property: 'og:title', content: `${s?.name ?? 'Service'} | nest.` },
    { property: 'og:description', content: s?.description ?? 'Book trusted home services.' },
    { property: 'og:type', content: 'website' },
    { name: 'twitter:card', content: 'summary_large_image' },
  ] }; },
  component: Detail,
});

const slotGroups = [
  { label: 'Morning', slots: ['09:00 AM', '10:30 AM'] },
  { label: 'Afternoon', slots: ['12:00 PM', '01:30 PM'] },
  { label: 'Evening', slots: ['03:30 PM', '05:00 PM'] },
];

function slotPassed(dateKey: string, slot: string) {
  if (dateKey !== format(new Date(), 'yyyy-MM-dd')) return false;
  const [time, ampm] = slot.split(' ');
  const [h, m] = (time ?? '0:0').split(':').map(Number);
  const hour = ((h ?? 0) % 12) + (ampm === 'PM' ? 12 : 0);
  const now = new Date();
  return hour * 60 + (m ?? 0) <= now.getHours() * 60 + now.getMinutes() + 60;
}

function Detail() {
  const { serviceId } = Route.useParams();
  const service = services.find(s => s.id === serviceId);
  const { booking, update } = useBooking();
  const navigate = useNavigate();
  const [date, setDate] = useState(booking.serviceId === serviceId ? booking.date : '');
  const [slot, setSlot] = useState(booking.serviceId === serviceId ? booking.slot : '');
  if (!service) return <AppShell back title="Service"><div className="px-4 py-24 text-center"><h1 className="font-display text-2xl font-bold">Service not found</h1><Button asChild className="mt-6 rounded-full"><Link to="/services" search={{ q: '', category: '' }}>Browse services</Link></Button></div></AppShell>;
  const ready = !!date && !!slot;
  const go = () => { update({ serviceId, date, slot, confirmed: false }); navigate({ to: '/booking/summary' }); };
  const cta = <Button disabled={!ready} onClick={go} className="h-13 w-full rounded-2xl text-sm font-bold">{ready ? <>Continue · {money(service.price)} <ArrowRight size={16} /></> : 'Select a date & time'}</Button>;
  return (
    <AppShell back title={service.name} hideTabs footer={cta}>
      <div className="mx-auto max-w-6xl md:px-8 md:pt-8">
        <div className="grid gap-8 lg:grid-cols-[minmax(0,1fr)_400px] lg:gap-12">
          <div>
            <div className="aspect-[1.5] overflow-hidden bg-secondary md:rounded-3xl"><img src={service.image} alt={`${service.name} professional at work`} width={1024} height={768} className="h-full w-full object-cover" /></div>
            <div className="px-4 pt-5 md:px-0">
              <p className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground">{service.category}</p>
              <h1 className="mt-1 font-display text-3xl font-extrabold md:text-4xl">{service.name}</h1>
              <div className="mt-3 flex flex-wrap items-center gap-x-4 gap-y-2 text-xs font-semibold">
                <span className="flex items-center gap-1"><Star size={14} fill="currentColor" />{service.rating}<span className="font-normal text-muted-foreground">({service.reviews} reviews)</span></span>
                <span className="flex items-center gap-1"><Clock3 size={14} />{service.duration}</span>
                <span className="flex items-center gap-1"><BadgeCheck size={14} />Verified pro</span>
              </div>
              <div className="mt-5 flex items-end justify-between rounded-2xl bg-secondary p-4 lg:hidden"><div><p className="text-[11px] text-muted-foreground">Starts at</p><p className="text-2xl font-extrabold">{money(service.price)}</p></div><p className="text-xs font-semibold">Pay after service</p></div>
              <p className="mt-6 text-sm leading-7 text-muted-foreground">{service.detail}</p>
              <h2 className="mt-8 font-display text-lg font-bold">What’s included</h2>
              <ul className="mt-3 grid gap-3 sm:grid-cols-2">{service.includes.map(i => <li key={i} className="flex items-center gap-3 text-sm"><span className="flex size-6 shrink-0 items-center justify-center rounded-full bg-primary text-primary-foreground"><Check size={13} /></span>{i}</li>)}</ul>
              <div className="mt-8 flex items-start gap-3 rounded-2xl border border-border p-4"><ShieldCheck size={20} className="shrink-0" /><div><p className="text-sm font-bold">nest. service warranty</p><p className="mt-0.5 text-xs text-muted-foreground">If something isn’t right within 7 days, we’ll send a pro back at no extra cost.</p></div></div>
            </div>
          </div>

          <aside className="h-fit px-4 md:px-0 lg:sticky lg:top-24 lg:rounded-3xl lg:border lg:border-border lg:p-6">
            <div className="mb-5 hidden items-end justify-between border-b border-border pb-5 lg:flex"><div><p className="text-xs text-muted-foreground">Starts at</p><p className="text-3xl font-extrabold">{money(service.price)}</p></div><p className="text-xs font-semibold">Pay after service</p></div>
            <h2 className="font-display text-lg font-bold">Select date</h2>
            <div className="-mx-4 mt-3 flex gap-2 overflow-x-auto px-4 pb-1 [scrollbar-width:none] md:mx-0 md:px-0 lg:grid lg:grid-cols-4">
              {Array.from({ length: 8 }, (_, i) => { const day = addDays(new Date(), i); const key = format(day, 'yyyy-MM-dd'); const on = date === key; return (
                <button key={key} onClick={() => { setDate(key); setSlot(''); }} className={`flex h-[72px] w-16 shrink-0 flex-col items-center justify-center rounded-2xl border transition-colors lg:w-auto ${on ? 'border-primary bg-primary text-primary-foreground' : 'border-border hover:border-foreground'}`}>
                  <span className={`text-[11px] font-semibold ${on ? '' : 'text-muted-foreground'}`}>{i === 0 ? 'Today' : format(day, 'EEE')}</span>
                  <span className="text-lg font-extrabold">{format(day, 'd')}</span>
                  <span className={`text-[10px] ${on ? 'opacity-70' : 'text-muted-foreground'}`}>{format(day, 'MMM')}</span>
                </button>); })}
            </div>
            <h2 className="mt-6 font-display text-lg font-bold">Select time</h2>
            {!date && <p className="mt-1 text-xs text-muted-foreground">Pick a date to see available slots.</p>}
            <div className="mt-3 space-y-4">
              {slotGroups.map(g => <div key={g.label}><p className="mb-2 text-xs font-semibold text-muted-foreground">{g.label}</p><div className="grid grid-cols-2 gap-2">{g.slots.map(t => { const off = !date || slotPassed(date, t); return <button key={t} disabled={off} onClick={() => setSlot(t)} className={`h-11 rounded-xl border text-sm font-semibold transition-colors disabled:cursor-not-allowed disabled:opacity-35 ${slot === t ? 'border-primary bg-primary text-primary-foreground' : 'border-border hover:border-foreground'}`}>{t}</button>; })}</div></div>)}
            </div>
            <div className="mt-6 hidden lg:block">{cta}</div>
          </aside>
        </div>
      </div>
    </AppShell>
  );
}
