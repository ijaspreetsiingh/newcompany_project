import { createFileRoute, Link } from "@tanstack/react-router";
import { Avatar, Section, TopBar } from "@/components/app/ui";
import { provider } from "@/data/mock";

export const Route = createFileRoute("/_tabs/profile")({
  head: () => ({
    meta: [
      { title: "Profile — Ink Partner" },
      { name: "description", content: "Owner details, business information and verification documents." },
      { property: "og:title", content: "Profile — Ink Partner" },
      { property: "og:description", content: "Owner details, business information and verification documents." },
    ],
  }),
  component: Profile,
});

function Field({ label, value }: { label: string; value: string }) {
  return (
    <div className="p-3.5">
      <p className="eyebrow">{label}</p>
      <p className="mt-1 text-[13.5px] font-semibold">{value}</p>
    </div>
  );
}

function Profile() {
  return (
    <div className="space-y-6 pb-8">
      <TopBar
        title="Profile"
        back="/more"
        right={
          <span className="rounded-full border border-border px-3 py-1.5 text-[12px] font-semibold">
            Edit
          </span>
        }
      />

      <div className="px-4">
        <div className="ink-surface flex items-center gap-4 p-5">
          <span className="flex size-16 items-center justify-center rounded-full bg-white/15 font-display text-xl font-bold">
            JS
          </span>
          <div>
            <p className="font-display text-lg font-bold">{provider.business}</p>
            <p className="text-[12px] text-white/70">{provider.owner}</p>
            <p className="mt-1.5 inline-block rounded-full bg-white/15 px-2.5 py-1 text-[10.5px] font-bold">
              Verified partner
            </p>
          </div>
        </div>
      </div>

      <Section title="Profile information">
        <div className="ink-card divide-y divide-border">
          <Field label="Full name" value={provider.owner} />
          <Field label="Phone" value="+91 98140 22114" />
          <Field label="Email" value="jaspreet@sharmaservices.in" />
        </div>
      </Section>

      <Section title="Business information">
        <div className="ink-card divide-y divide-border">
          <Field label="Company" value={provider.business} />
          <Field label="GST / license" value="03ABCDE1234F1Z5" />
          <Field label="Operating zone" value="Chandigarh · Mohali · Panchkula" />
          <Field label="Documents" value="Aadhaar, PAN, Shop license — approved" />
        </div>
      </Section>

      <Section title="Bank information">
        <div className="ink-card divide-y divide-border">
          <Field label="Bank" value="HDFC Bank — Sector 22 branch" />
          <Field label="Account" value="XXXX XXXX 4421" />
          <Field label="IFSC" value="HDFC0000321" />
        </div>
      </Section>

      <div className="px-4">
        <Link
          to="/account"
          className="block rounded-full bg-foreground py-3.5 text-center text-[14px] font-bold text-background"
        >
          View account & earnings
        </Link>
      </div>
    </div>
  );
}
