import { Bath, Bolt, BrushCleaning, Drill, Fan, House, Refrigerator, WashingMachine, Wrench, type LucideIcon } from 'lucide-react';
import cleaning from '@/assets/home-cleaning.jpg';
import electrical from '@/assets/electrical.jpg';
import plumbing from '@/assets/plumbing.jpg';
import appliance from '@/assets/appliance.jpg';

export type Service = { id: string; name: string; category: string; description: string; detail: string; price: number; duration: string; rating: string; reviews: string; image: string; icon: LucideIcon; includes: string[] };
export const categories = [
  { name: 'All services', icon: House }, { name: 'Cleaning', icon: BrushCleaning }, { name: 'Plumbing', icon: Wrench },
  { name: 'Electrical', icon: Bolt }, { name: 'Appliances', icon: WashingMachine }, { name: 'Repairs', icon: Drill },
];
export const services: Service[] = [
  { id: 'home-cleaning', name: 'Home cleaning', category: 'Cleaning', description: 'A spotless home, without lifting a finger.', detail: 'A thorough clean for the spaces you live in. Our experienced professionals bring the right tools and attention to every corner.', price: 799, duration: '2–3 hours', rating: '4.9', reviews: '2.4k', image: cleaning, icon: BrushCleaning, includes: ['Living room & bedrooms', 'Kitchen surfaces & sink', 'Bathroom cleaning', 'Floor mopping & dusting'] },
  { id: 'plumbing-repair', name: 'Plumbing repair', category: 'Plumbing', description: 'Leaks, taps and pipes, sorted.', detail: 'From a dripping tap to a stubborn leak, get a trusted plumber at your door with clear pricing and no surprises.', price: 499, duration: '60–90 min', rating: '4.8', reviews: '1.8k', image: plumbing, icon: Wrench, includes: ['Problem inspection', 'Minor leak & tap repair', 'Basic tools included', 'Post-service clean-up'] },
  { id: 'electrical-service', name: 'Electrical service', category: 'Electrical', description: 'Safe, reliable fixes for your home.', detail: 'Get help with switches, sockets, lights and everyday electrical fixes from a verified professional.', price: 449, duration: '60–90 min', rating: '4.9', reviews: '1.6k', image: electrical, icon: Bolt, includes: ['Electrical inspection', 'Switch & socket repair', 'Light fixture support', 'Safety check'] },
  { id: 'appliance-care', name: 'Appliance care', category: 'Appliances', description: 'Keep the essentials running smoothly.', detail: 'A skilled technician diagnoses and services your everyday appliances so you can get back to your routine.', price: 599, duration: '1–2 hours', rating: '4.8', reviews: '1.2k', image: appliance, icon: WashingMachine, includes: ['Appliance diagnosis', 'Basic servicing', 'Performance check', 'Repair estimate if needed'] },
  { id: 'bathroom-cleaning', name: 'Bathroom deep clean', category: 'Cleaning', description: 'A fresh start for your bathroom.', detail: 'Detailed cleaning for tiles, fittings and hard-to-reach spaces, handled by a trained cleaning professional.', price: 649, duration: '1–2 hours', rating: '4.8', reviews: '980', image: cleaning, icon: Bath, includes: ['Tiles & grout', 'Fixtures & fittings', 'Floor & drain cleaning', 'Mirror & surfaces'] },
  { id: 'ac-service', name: 'AC servicing', category: 'Appliances', description: 'Breathe easy, stay comfortable.', detail: 'Careful inspection and routine cleaning to keep your air conditioner working at its best.', price: 699, duration: '1–2 hours', rating: '4.9', reviews: '1.1k', image: appliance, icon: Fan, includes: ['Filter cleaning', 'Cooling inspection', 'Unit check', 'Service recommendations'] },
  { id: 'furniture-repair', name: 'Furniture repair', category: 'Repairs', description: 'Little fixes that make a big difference.', detail: 'From loose hinges to wobbly furniture, book a practical repair visit for the things around your home.', price: 549, duration: '1–2 hours', rating: '4.7', reviews: '760', image: plumbing, icon: Drill, includes: ['Problem assessment', 'Minor repairs', 'Fitting adjustments', 'Clean work area'] },
  { id: 'fridge-repair', name: 'Refrigerator repair', category: 'Appliances', description: 'Get your fridge back on track.', detail: 'An expert technician checks your refrigerator and walks you through the best way to fix it.', price: 599, duration: '1–2 hours', rating: '4.8', reviews: '890', image: appliance, icon: Refrigerator, includes: ['Fridge diagnosis', 'Cooling check', 'Door seal inspection', 'Repair estimate if needed'] },
];
export const money = (amount: number) => `₹${amount.toLocaleString('en-IN')}`;

export function getService(id: string): Service { const found = services.find(s => s.id === id); if (found) return found; const fallback = services[0]; if (!fallback) throw new Error('Service catalog is empty'); return fallback; }
