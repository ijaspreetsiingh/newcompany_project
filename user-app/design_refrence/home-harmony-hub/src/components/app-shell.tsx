import { Link, useRouter, useRouterState } from '@tanstack/react-router';
import { ArrowLeft, ArrowRight, Bell, CalendarDays, ChevronDown, House, LayoutGrid, MapPin, UserRound } from 'lucide-react';
import { useBooking } from '@/lib/booking-context';

const nav = [
  { to: '/', label: 'Home', icon: House },
  { to: '/services', label: 'Services', icon: LayoutGrid },
  { to: '/booking/tracker', label: 'Bookings', icon: CalendarDays },
  { to: '/account', label: 'Account', icon: UserRound },
] as const;

function isActive(path: string, to: string) {
  if (to === '/') return path === '/';
  if (to === '/booking/tracker') return path.startsWith('/booking');
  return path.startsWith(to);
}

type ShellProps = { children: React.ReactNode; title?: string; back?: boolean; hideTabs?: boolean; footer?: React.ReactNode };

export function AppShell({ children, title, back, hideTabs, footer }: ShellProps) {
  const path = useRouterState({ select: s => s.location.pathname });
  const router = useRouter();
  const { booking } = useBooking();
  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="sticky top-0 z-30 border-b border-border bg-background/90 backdrop-blur-xl">
        <div className="mx-auto flex h-16 max-w-6xl items-center justify-between gap-4 px-4 md:px-8">
          {back ? (
            <div className="flex min-w-0 items-center gap-2">
              <button onClick={() => router.history.back()} aria-label="Go back" className="-ml-2 flex size-10 items-center justify-center rounded-full transition-colors hover:bg-secondary"><ArrowLeft size={20} /></button>
              <span className="truncate font-display text-base font-bold">{title}</span>
            </div>
          ) : (
            <div className="flex min-w-0 items-center gap-6">
              <Link to="/" className="flex items-center gap-2 font-display text-xl font-extrabold"><span className="flex size-8 items-center justify-center rounded-lg bg-primary text-primary-foreground"><House size={16} strokeWidth={2.5} /></span>nest.</Link>
              <button className="hidden min-w-0 items-center gap-1.5 rounded-full border border-border px-3 py-1.5 text-xs font-semibold sm:flex" aria-label="Service location"><MapPin size={14} /><span className="truncate">Home · New Delhi</span><ChevronDown size={14} className="text-muted-foreground" /></button>
            </div>
          )}
          <nav className="hidden items-center gap-1 md:flex">
            {nav.map(item => <Link key={item.to} to={item.to} search={item.to === '/services' ? { q: '', category: '' } : {}} className={`rounded-full px-4 py-2 text-sm font-semibold transition-colors ${isActive(path, item.to) ? 'bg-primary text-primary-foreground' : 'text-muted-foreground hover:text-foreground'}`}>{item.label}</Link>)}
          </nav>
          <Link to="/booking/tracker" aria-label="Booking updates" className="relative flex size-10 items-center justify-center rounded-full border border-border md:hidden"><Bell size={18} />{booking.confirmed && <span className="absolute right-2.5 top-2.5 size-2 rounded-full bg-primary ring-2 ring-background" />}</Link>
        </div>
      </header>
      <main className={hideTabs ? (footer ? 'pb-32' : 'pb-10') : 'pb-28 md:pb-16'}>{children}</main>
      {footer && <div className="fixed inset-x-0 bottom-0 z-40 border-t border-border bg-background/95 pb-[env(safe-area-inset-bottom)] backdrop-blur-xl lg:hidden"><div className="mx-auto max-w-6xl px-4 py-3">{footer}</div></div>}
      {!hideTabs && (
        <nav className="fixed inset-x-0 bottom-0 z-40 border-t border-border bg-background/95 pb-[env(safe-area-inset-bottom)] backdrop-blur-xl md:hidden">
          <div className="grid grid-cols-4">
            {nav.map(item => { const active = isActive(path, item.to); return (
              <Link key={item.to} to={item.to} search={item.to === '/services' ? { q: '', category: '' } : {}} className={`relative flex h-16 flex-col items-center justify-center gap-1 text-[11px] font-semibold ${active ? 'text-foreground' : 'text-muted-foreground'}`}>
                {active && <span className="absolute top-0 h-0.5 w-8 rounded-full bg-primary" />}
                <item.icon size={21} strokeWidth={active ? 2.4 : 1.8} />{item.label}
                {item.to === '/booking/tracker' && booking.confirmed && <span className="absolute right-[calc(50%-16px)] top-3 size-2 rounded-full bg-primary ring-2 ring-background" />}
              </Link>); })}
          </div>
        </nav>
      )}
    </div>
  );
}

export function SectionHeading({ title, subtitle, action }: { title: string; subtitle?: string; action?: React.ReactNode }) {
  return <div className="mb-4 flex items-end justify-between gap-4"><div><h2 className="font-display text-lg font-bold md:text-2xl">{title}</h2>{subtitle && <p className="mt-0.5 text-xs text-muted-foreground md:text-sm">{subtitle}</p>}</div>{action}</div>;
}

export function ArrowLink({ to, children }: { to: '/services' | '/'; children: React.ReactNode }) {
  return <Link to={to} search={to === '/services' ? { q: '', category: '' } : {}} className="flex shrink-0 items-center gap-1 text-xs font-bold">{children}<ArrowRight size={14} /></Link>;
}

export function Steps({ current }: { current: 1 | 2 | 3 }) {
  const labels = ['Schedule', 'Review', 'Track'];
  return <div className="flex items-center gap-2">{labels.map((l, i) => <div key={l} className="flex flex-1 flex-col gap-1.5"><span className={`h-1 rounded-full ${i < current ? 'bg-primary' : 'bg-secondary'}`} /><span className={`text-[10px] font-bold uppercase tracking-wider ${i < current ? 'text-foreground' : 'text-muted-foreground'}`}>{l}</span></div>)}</div>;
}
