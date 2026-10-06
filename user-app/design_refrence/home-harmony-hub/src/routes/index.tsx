import { createFileRoute, Link, useNavigate } from '@tanstack/react-router';
import { useState } from 'react';
import { format, parseISO } from 'date-fns';
import { ArrowRight, BadgeCheck, CalendarDays, ChevronRight, Headphones, IndianRupee, MapPin, Search, ShieldCheck } from 'lucide-react';
import { AppShell, ArrowLink, SectionHeading } from '@/components/app-shell';
import { ServiceCard, ServiceRow } from '@/components/service-card';
import { categories, getService, services } from '@/lib/services';
import { useBooking } from '@/lib/booking-context';
import heroImage from '@/assets/home-cleaning.jpg';

export const Route = createFileRoute('/')({
  head: () => ({ meta: [
    { title: 'nest. | Home, handled.' },
    { name: 'description', content: 'Book trusted cleaning, repairs, plumbing, electrical and appliance care for your home with nest.' },
    { property: 'og:title', content: 'nest. | Home, handled.' },
    { property: 'og:description', content: 'Trusted help for everything your home needs.' },
    { property: 'og:type', content: 'website' },
    { name: 'twitter:card', content: 'summary_large_image' },
  ] }),
  component: Home,
});

function greeting() { const h = new Date().getHours(); return h < 12 ? 'Good morning' : h < 17 ? 'Good afternoon' : 'Good evening'; }

function Home() {
  const [query, setQuery] = useState('');
  const navigate = useNavigate();
  const { booking } = useBooking();
  const active = booking.confirmed ? getService(booking.serviceId) : null;
  const popular = services.slice(0, 4);
  return (
    <AppShell>
      <div className="mx-auto max-w-6xl px-4 pt-5 md:px-8 md:pt-10">
        <button className="mb-4 flex items-center gap-1.5 text-xs font-semibold sm:hidden" aria-label="Service location"><MapPin size={14} />Home · New Delhi<ChevronRight size={14} className="text-muted-foreground" /></button>
        <p className="text-sm text-muted-foreground">{greeting()}</p>
        <h1 className="mt-1 font-display text-[28px] font-extrabold leading-tight md:text-5xl">What can we help<br className="md:hidden" /> with today?</h1>

        <form className="mt-5 flex h-14 items-center gap-3 rounded-2xl border border-border bg-secondary px-4 focus-within:border-foreground md:max-w-xl" onSubmit={e => { e.preventDefault(); navigate({ to: '/services', search: { q: query, category: '' } }); }}>
          <Search size={19} className="shrink-0 text-muted-foreground" />
          <input value={query} onChange={e => setQuery(e.target.value)} aria-label="Search home services" placeholder="Search cleaning, AC, plumber…" className="min-w-0 flex-1 bg-transparent text-sm outline-none placeholder:text-muted-foreground" />
          {query && <button type="submit" aria-label="Search" className="flex size-9 items-center justify-center rounded-xl bg-primary text-primary-foreground"><ArrowRight size={16} /></button>}
        </form>

        {active && (
          <Link to="/booking/tracker" className="mt-5 flex items-center gap-4 rounded-2xl bg-primary p-4 text-primary-foreground">
            <span className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-primary-foreground/10"><CalendarDays size={20} /></span>
            <div className="min-w-0 flex-1"><p className="text-[11px] font-semibold uppercase tracking-wider opacity-70">Upcoming · Preview</p><p className="truncate text-sm font-bold">{active.name}</p><p className="text-xs opacity-70">{format(parseISO(booking.date), 'EEE, d MMM')} · {booking.slot}</p></div>
            <ChevronRight size={20} />
          </Link>
        )}

        <section className="mt-8">
          <SectionHeading title="Categories" action={<ArrowLink to="/services">See all</ArrowLink>} />
          <div className="grid grid-cols-3 gap-3 md:grid-cols-6">
            {categories.map(c => (
              <Link key={c.name} to="/services" search={{ q: '', category: c.name === 'All services' ? '' : c.name }} className="group flex flex-col items-center gap-2 rounded-2xl border border-border bg-card px-2 py-4 text-center transition-colors hover:border-foreground">
                <span className="flex size-12 items-center justify-center rounded-full bg-secondary transition-colors group-hover:bg-primary group-hover:text-primary-foreground"><c.icon size={22} strokeWidth={1.8} /></span>
                <span className="text-xs font-semibold">{c.name === 'All services' ? 'All' : c.name}</span>
              </Link>
            ))}
          </div>
        </section>

        <section className="relative mt-8 overflow-hidden rounded-3xl bg-primary text-primary-foreground">
          <img src={heroImage} alt="Professional cleaning a bright living room" width={1536} height={1024} className="absolute inset-y-0 right-0 h-full w-3/5 object-cover opacity-90 md:w-1/2" />
          <div className="absolute inset-0 bg-gradient-to-r from-primary via-primary/90 to-primary/10" />
          <div className="relative max-w-[62%] p-5 md:max-w-md md:p-10">
            <p className="text-[11px] font-bold uppercase tracking-[0.18em] opacity-70">Most booked</p>
            <h2 className="mt-2 font-display text-xl font-extrabold leading-tight md:text-4xl">A spotless home in 3 hours.</h2>
            <p className="mt-2 hidden text-sm opacity-75 md:block">Trained cleaners, all supplies included, pay after the job is done.</p>
            <Link to="/services/$serviceId" params={{ serviceId: 'home-cleaning' }} className="mt-4 inline-flex items-center gap-2 rounded-full bg-background px-4 py-2 text-xs font-bold text-foreground">Book from ₹799 <ArrowRight size={14} /></Link>
          </div>
        </section>

        <section className="mt-8">
          <SectionHeading title="Popular near you" subtitle="Top rated by homes in New Delhi" action={<ArrowLink to="/services">View all</ArrowLink>} />
          <div className="grid gap-3 md:hidden">{popular.map(s => <ServiceRow key={s.id} service={s} />)}</div>
          <div className="hidden gap-5 md:grid md:grid-cols-2 lg:grid-cols-4">{popular.map(s => <ServiceCard key={s.id} service={s} />)}</div>
        </section>

        <section className="mt-10 grid grid-cols-2 gap-3 md:grid-cols-4">
          {[
            { icon: BadgeCheck, t: 'Verified pros', d: 'Background checked & trained' },
            { icon: IndianRupee, t: 'Upfront pricing', d: 'No hidden charges' },
            { icon: ShieldCheck, t: 'Service warranty', d: 'Free fix if not right' },
            { icon: Headphones, t: 'Real support', d: 'Help 8 AM – 10 PM' },
          ].map(x => <div key={x.t} className="rounded-2xl bg-secondary p-4"><x.icon size={20} /><p className="mt-3 text-sm font-bold">{x.t}</p><p className="mt-0.5 text-xs text-muted-foreground">{x.d}</p></div>)}
        </section>
      </div>
    </AppShell>
  );
}
