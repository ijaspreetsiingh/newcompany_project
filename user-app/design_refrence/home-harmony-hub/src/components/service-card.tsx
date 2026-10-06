import { Link } from '@tanstack/react-router';
import { ChevronRight, Clock3, Star } from 'lucide-react';
import { type Service, money } from '@/lib/services';

export function ServiceCard({ service }: { service: Service }) {
  return (
    <Link to="/services/$serviceId" params={{ serviceId: service.id }} className="group block overflow-hidden rounded-2xl border border-border bg-card transition-all hover:-translate-y-0.5 hover:shadow-xl">
      <div className="relative aspect-[1.6] overflow-hidden bg-secondary">
        <img src={service.image} alt={service.name} loading="lazy" width={1024} height={768} className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105" />
        <span className="absolute left-3 top-3 flex items-center gap-1 rounded-full bg-background px-2.5 py-1 text-[11px] font-bold"><Star size={11} fill="currentColor" />{service.rating}<span className="font-medium text-muted-foreground">({service.reviews})</span></span>
      </div>
      <div className="p-4">
        <p className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">{service.category}</p>
        <h3 className="mt-1 font-display text-base font-bold">{service.name}</h3>
        <p className="mt-1 line-clamp-1 text-xs text-muted-foreground">{service.description}</p>
        <div className="mt-4 flex items-center justify-between">
          <div><span className="text-[11px] text-muted-foreground">Starts at </span><span className="text-base font-bold">{money(service.price)}</span></div>
          <span className="flex items-center gap-1 text-[11px] font-semibold text-muted-foreground"><Clock3 size={12} />{service.duration}</span>
        </div>
      </div>
    </Link>
  );
}

export function ServiceRow({ service }: { service: Service }) {
  return (
    <Link to="/services/$serviceId" params={{ serviceId: service.id }} className="flex items-center gap-4 rounded-2xl border border-border bg-card p-3 transition-colors hover:border-foreground/30">
      <img src={service.image} alt={service.name} loading="lazy" width={1024} height={768} className="size-20 shrink-0 rounded-xl object-cover" />
      <div className="min-w-0 flex-1">
        <h3 className="truncate font-display text-[15px] font-bold">{service.name}</h3>
        <div className="mt-1 flex items-center gap-2 text-[11px] font-semibold text-muted-foreground"><span className="flex items-center gap-0.5 text-foreground"><Star size={11} fill="currentColor" />{service.rating}</span>·<span>{service.duration}</span></div>
        <p className="mt-1.5 text-sm font-bold">{money(service.price)}<span className="ml-1 text-[11px] font-medium text-muted-foreground">onwards</span></p>
      </div>
      <ChevronRight size={18} className="shrink-0 text-muted-foreground" />
    </Link>
  );
}
