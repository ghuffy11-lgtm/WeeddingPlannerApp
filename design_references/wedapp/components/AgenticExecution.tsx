
import React from 'react';

const AgenticExecution: React.FC = () => {
  return (
    <div className="flex-1 flex flex-col bg-background-light dark:bg-[#221018] font-manrope">
      <header className="sticky top-0 z-50 flex items-center bg-background-light dark:bg-[#221018] p-4 pb-2 justify-between">
        <div className="text-slate-900 dark:text-white flex size-12 shrink-0 items-center cursor-pointer">
          <span className="material-symbols-outlined">arrow_back_ios</span>
        </div>
        <div className="flex flex-col items-center">
          <h2 className="text-slate-900 dark:text-white text-lg font-extrabold leading-tight tracking-[-0.015em]">Agentic Execution</h2>
          <span className="text-[10px] uppercase tracking-widest text-primary font-bold">Protocol 2026-X</span>
        </div>
        <div className="flex w-12 items-center justify-end">
          <button className="flex items-center justify-center rounded-lg h-12 bg-transparent text-slate-900 dark:text-white">
            <span className="material-symbols-outlined">verified_user</span>
          </button>
        </div>
      </header>

      <main className="flex-1 px-4 space-y-6 pb-10">
        <div className="rounded-xl p-4 bg-primary/10 border border-primary/20 flex flex-col gap-3 mt-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="material-symbols-outlined text-primary text-sm">smart_toy</span>
              <p className="text-primary text-xs font-bold uppercase tracking-wider">Legal Paperwork Bot</p>
            </div>
            <span className="flex h-2 w-2 rounded-full bg-primary animate-pulse"></span>
          </div>
          <div className="flex flex-col gap-1">
            <div className="flex justify-between items-end">
              <p className="text-slate-900 dark:text-white text-base font-bold">Scanning Digital Contracts</p>
              <p className="text-primary text-sm font-bold">94%</p>
            </div>
            <div className="w-full bg-slate-200 dark:bg-white/10 h-1.5 rounded-full overflow-hidden">
              <div className="bg-primary h-full w-[94%]"></div>
            </div>
            <p className="text-slate-500 dark:text-slate-400 text-[11px] mt-1">14/14 clauses verified for compliance & escrow safety.</p>
          </div>
        </div>

        <section>
          <div className="flex items-center justify-between pb-4">
            <h3 className="text-slate-900 dark:text-white text-lg font-extrabold leading-tight tracking-[-0.015em]">Master Plan Summary</h3>
            <span className="text-primary text-xs font-bold bg-primary/10 px-2 py-1 rounded">Verified</span>
          </div>
          <div className="space-y-4">
            <PlanCard title="Grand Plaza Estate" subtitle="Venue • AI Verified Capacity" image="https://lh3.googleusercontent.com/aida-public/AB6AXuC7v82gasIZe90uA2DpRRighW2f-VwIPAm5pUJqty_ZjjhRmCr40llLTo05NUhnn3QvHEwuUDbIHgszgE-NBjOx56sRNpYW32wNYyjwS9H_1U9hv67nIYEe88rIWKV37cEXyf2WLdhcqfuyNyvzrAP_lfY2i0z2QXq2-836Bfwdk97pP5U4kksFnH7WbbMq2_NjqJ6f4CviLrGsqWAOjV5FVqiqBGVHyeGFOHrJvrLgulitYiWdtulSfwFe23p7LPCrkoB2kVsnV3s" buttonText="Review Contract" />
            <PlanCard title="Synthetica Sounds" subtitle="Talent • Digital Contract Ready" image="https://lh3.googleusercontent.com/aida-public/AB6AXuC-8eeHRCkRq3wb7Hfj8KyDPUgZhyXnY0jiVa8ywOxh1EU1-LCX8B9UI4ZX7UXjJS3EvypkC3taPtj68ZxiMx4uJN_ETuA7Jsd1QQ4FFktvu0C_38Cx6CdLV7g2ilpolMz5hO5R53YSmnc9MIv0qx8SQabh1nr7SSmrGOTdY1gTneN61rrPss4ExNwH3f8iKhuT9FCX5GdUR_HJQ1XcMlJb2UT9JKTCVG0vniTffjbxmv5pi4ri9zD5JWUaHikTQcKU_n9dTvLPhOc" buttonText="View Tech Rider" />
          </div>
        </section>

        <section>
          <h3 className="text-sm font-bold leading-tight tracking-tight mb-4 uppercase text-slate-400">Financial Execution</h3>
          <div className="space-y-3 rounded-xl bg-slate-50 dark:bg-white/5 p-4">
            <FinanceRow label="Venue Escrow (20%)" value="$4,200.00" />
            <FinanceRow label="Talent Booking (50%)" value="$1,500.00" />
            <FinanceRow label="Decor Materials (Full)" value="$2,850.00" />
            <div className="pt-3 border-t border-slate-200 dark:border-white/10 flex justify-between items-center">
              <span className="text-slate-900 dark:text-white font-extrabold">Total Initial Deposit</span>
              <span className="text-xl font-extrabold text-primary">$8,550.00</span>
            </div>
          </div>
        </section>

        <div className="mt-auto space-y-4">
          <div className="flex items-center justify-center gap-2 text-slate-400 text-[10px] uppercase font-bold tracking-[0.2em]">
            <span className="material-symbols-outlined text-sm">lock</span>
            End-to-End Encrypted Secure Transaction
          </div>
          <button className="w-full bg-primary text-white h-16 rounded-xl flex flex-col items-center justify-center transition-transform active:scale-95 group shadow-[0_0_20px_rgba(238,43,124,0.4)]">
            <div className="flex items-center gap-2">
              <span className="material-symbols-outlined font-bold group-hover:scale-110 transition-transform">bolt</span>
              <span className="text-lg font-black tracking-wider uppercase">Execute & Secure</span>
            </div>
            <div className="flex items-center gap-1 opacity-80">
              <span className="material-symbols-outlined text-[14px]">fingerprint</span>
              <span className="text-[10px] font-bold">Biometric Signature Required</span>
            </div>
          </button>
          <p className="text-center text-[10px] text-slate-500 dark:text-slate-400 px-8">
            By tapping Execute, you authorize the AI Agent to sign digital contracts on your behalf and initiate escrow fund transfers.
          </p>
        </div>
      </main>
    </div>
  );
};

const PlanCard = ({ title, subtitle, image, buttonText }: any) => (
  <div className="flex items-stretch justify-between gap-4 rounded-xl bg-white dark:bg-[#2d1a23] p-4 shadow-sm border border-slate-100 dark:border-white/5">
    <div className="flex flex-[2_2_0px] flex-col justify-between py-1">
      <div className="flex flex-col gap-1">
        <p className="text-slate-900 dark:text-white text-base font-bold leading-tight">{title}</p>
        <p className="text-slate-500 dark:text-[#b99da8] text-xs font-normal leading-normal">{subtitle}</p>
      </div>
      <button className="flex items-center justify-center rounded-lg h-8 px-4 bg-slate-100 dark:bg-[#39282f] text-slate-900 dark:text-white gap-1 text-xs font-semibold w-fit mt-2">
        <span className="truncate">{buttonText}</span>
        <span className="material-symbols-outlined text-[18px]">chevron_right</span>
      </button>
    </div>
    <div className="w-24 h-24 bg-center bg-no-repeat bg-cover rounded-lg shrink-0" style={{ backgroundImage: `url("${image}")` }}></div>
  </div>
);

const FinanceRow = ({ label, value }: any) => (
  <div className="flex justify-between items-center text-sm">
    <span className="text-slate-500 dark:text-slate-400">{label}</span>
    <span className="font-bold text-slate-900 dark:text-white">{value}</span>
  </div>
);

export default AgenticExecution;
