import { createFileRoute } from '@tanstack/react-router';
import { useState } from 'react';
import { Search, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { AppShell } from '@/components/app-shell';
import { ServiceCard, ServiceRow } from '@/components/service-card';
import { categories, services } from '@/lib/services';

export const Route = createFileRoute('/services/')({
  head: () => ({ meta: [
    { title: 'All home services | nest.' },
    { name: 'description', content: 'Explore professional cleaning, plumbing, electrical, appliance and repair services for your home.' },
    { property: 'og:title', content: 'All home services | nest.' },
    { property: 'og:description', content: 'Find trusted care for every corner of your home.' },
    { property: 'og:type', content: 'website' },
    { name: 'twitter:card', content: 'summary_large_image' },
  ] }),
  validateSearch: (search: Record<string, unknown>) => ({ q: typeof search['q'] === 'string' ? search['q'] : '', category: typeof search['category'] === 'string' ? search['category'] : '' }),
  component: Catalog,
});

function Catalog() {
  const search = Route.useSearch();
  const [category, setCategory] = useState(search.category || 'All services');
  const [query, setQuery] = useState(search.q);
  const matches = services.filter(s => (category === 'All services' || s.category === category) && `${s.name} ${s.category} ${s.description}`.toLowerCase().includes(query.trim().toLowerCase()));
  return (
    <AppShell>
      <div className="sticky top-16 z-20 border-b border-border bg-background/95 backdrop-blur-xl">
        <div className="mx-auto max-w-6xl px-4 pb-3 pt-4 md:px-8">
          <h1 className="font-display text-2xl font-extrabold md:text-4xl">Services</h1>
          <div className="mt-3 flex h-12 items-center gap-3 rounded-2xl border border-border bg-secondary px-4 focus-within:border-foreground md:max-w-xl">
            <Search size={18} className="text-muted-foreground" />
            <input aria-label="Search services" value={query} onChange={e => setQuery(e.target.value)} placeholder="Search for a service" className="h-full min-w-0 flex-1 bg-transparent text-sm outline-none placeholder:text-muted-foreground" />
            {query && <button onClick={() => setQuery('')} aria-label="Clear search" className="flex size-7 items-center justify-center rounded-full bg-background"><X size={14} /></button>}
          </div>
          <div className="-mx-4 mt-3 flex gap-2 overflow-x-auto px-4 [scrollbar-width:none] md:mx-0 md:px-0">
            {categories.map(c => <button key={c.name} onClick={() => setCategory(c.name)} className={`flex h-9 shrink-0 items-center gap-1.5 rounded-full border px-4 text-xs font-semibold transition-colors ${category === c.name ? 'border-primary bg-primary text-primary-foreground' : 'border-border hover:border-foreground'}`}><c.icon size={14} />{c.name}</button>)}
          </div>
        </div>
      </div>
      <div className="mx-auto max-w-6xl px-4 pt-5 md:px-8">
        <p className="mb-3 text-xs font-semibold text-muted-foreground">{matches.length} {matches.length === 1 ? 'service' : 'services'} available</p>
        {matches.length ? (
          <>
            <div className="grid gap-3 md:hidden">{matches.map(s => <ServiceRow key={s.id} service={s} />)}</div>
            <div className="hidden gap-5 md:grid md:grid-cols-2 lg:grid-cols-3">{matches.map(s => <ServiceCard key={s.id} service={s} />)}</div>
          </>
        ) : (
          <div className="py-24 text-center">
            <span className="mx-auto flex size-14 items-center justify-center rounded-full bg-secondary"><Search size={22} /></span>
            <h2 className="mt-4 font-display text-lg font-bold">No services found</h2>
            <p className="mt-1 text-sm text-muted-foreground">Try a different search or category.</p>
            <Button variant="outline" className="mt-5 rounded-full" onClick={() => { setQuery(''); setCategory('All services'); }}>Clear filters</Button>
          </div>
        )}
      </div>
    </AppShell>
  );
}
