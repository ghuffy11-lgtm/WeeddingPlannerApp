
import React from 'react';
import { AppTab } from '../types';

interface Props {
  onNavigate: (tab: AppTab) => void;
}

const MastermindHub: React.FC<Props> = ({ onNavigate }) => {
  return (
    <div className="flex-1 flex flex-col bg-hub-bg text-white font-display">
      <div className="fixed top-1/2 left-0 -translate-x-1/2 -translate-y-1/2 size-96 bg-accent-purple/5 blur-[120px] pointer-events-none"></div>
      <div className="fixed bottom-0 right-0 translate-x-1/4 translate-y-1/4 size-96 bg-accent-cyan/5 blur-[120px] pointer-events-none"></div>

      <header className="sticky top-0 z-50 flex items-center bg-hub-bg/60 backdrop-blur-xl p-5 justify-between">
        <div className="flex flex-col">
          <span className="text-[10px] uppercase tracking-[0.2em] text-gray-500 font-bold">Neural Sync Active</span>
          <h1 className="text-xl font-extrabold tracking-tight">Mastermind Hub</h1>
        </div>
        <div className="flex items-center gap-4">
          <div className="relative">
            <span className="material-symbols-outlined text-accent-cyan">notifications</span>
            <span className="absolute top-0 right-0 size-2 bg-accent-pink rounded-full border border-hub-bg"></span>
          </div>
          <div className="size-10 rounded-full border border-white/10 overflow-hidden">
            <img alt="User Profile" className="w-full h-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDbbuhDpbDcVS9m49IbjzUnE4iHaKWjJ8YWdtn1YCkDAojqNy_xIzGR6wzfpqb8SolI3kpdD41Nz2KghcMxD9C4aIFljMPok3duyngIPgIUtv5DhMgP4VH22pCaVzQOiUlANX7bXghF94OjSis4JEcoYhApisS7bokFreEb5VcII9oFcZcXRlrwEtctyi1NtbJhj4YXfAWKsh1mOSCDZxiOm-AqZGb-J2qHduI2iT-fsnvQgzAXbAsdWDf0-rw2-_MxbEZUsY_0i9g" />
          </div>
        </div>
      </header>

      <main className="px-5 space-y-6 flex-1 pb-10">
        <section className="glassmorphism rounded-[2rem] p-6 relative overflow-hidden">
          <div className="absolute -right-10 -top-10 size-40 bg-accent-cyan/10 blur-[50px] rounded-full"></div>
          <div className="flex justify-between items-start mb-6">
            <div>
              <p className="text-[10px] uppercase tracking-widest text-accent-cyan font-bold mb-1">Aesthetic Profile</p>
              <h2 className="text-2xl font-bold italic">Modern Elegance</h2>
            </div>
            <div className="glassmorphism rounded-full px-3 py-1 flex items-center gap-2">
              <span className="size-2 bg-green-400 rounded-full animate-pulse"></span>
              <span className="text-[10px] font-bold">98% Match</span>
            </div>
          </div>
          <div className="grid grid-cols-3 gap-2">
            <div className="h-1 bg-accent-cyan rounded-full"></div>
            <div className="h-1 bg-accent-cyan rounded-full"></div>
            <div className="h-1 bg-white/20 rounded-full"></div>
          </div>
          <div className="mt-4 flex gap-4 text-[11px] text-gray-400">
            <span className="flex items-center gap-1"><span className="material-symbols-outlined text-[14px]">palette</span> Monochromatic</span>
            <span className="flex items-center gap-1"><span className="material-symbols-outlined text-[14px]">architecture</span> Minimalist</span>
          </div>
        </section>

        <section className="space-y-4">
          <div className="flex items-center gap-2 mb-2">
            <span className="material-symbols-outlined text-accent-purple">neurology</span>
            <h3 className="text-sm font-bold tracking-wider uppercase text-gray-400">Optimized Packages</h3>
          </div>
          <div className="flex overflow-x-auto no-scrollbar gap-4 pb-2">
            <PackageCard color="accent-cyan" title="Urban Oasis" desc="Rooftop venue + Digital mapping decor + Smart bar" price="$42,500" />
            <PackageCard color="accent-purple" title="Ethereal Tech" desc="Glass cathedral + AI string quartet + Holographic florals" price="$68,000" />
          </div>
        </section>

        <div className="grid grid-cols-2 gap-4">
          <OptimizerGridItem icon="partly_cloudy_day" label="OPTIMIZER" color="accent-cyan" title="Sept 14" subtitle="Perfect Forecast" note="92% Chance of Clear Skies" />
          <OptimizerGridItem icon="block" label="HARD NO'S" color="accent-pink" title="Filtered" subtitle="12 Vendors Out" 
            tags={['No Ballrooms', 'No Buffet']} />
        </div>

        <section className="glassmorphism rounded-[2.5rem] overflow-hidden p-1 relative cursor-pointer" onClick={() => onNavigate(AppTab.AR_SHOWROOM)}>
          <div className="w-full aspect-video rounded-[2.2rem] bg-cover bg-center flex items-center justify-center relative group" 
            style={{ backgroundImage: `url("https://lh3.googleusercontent.com/aida-public/AB6AXuDjf8kCz0MeuxNlF52mzdP1M6a1aHeF9VlhyKa7EkKZmjncmoLi5Kj5Ayn5UijZ-bdL4cNYj_6nQttxzrBUngqmkhsRxQpBGgF0EIAl29zaQqbnKC4yzQh4aICY3J9fv5tF2r4Ysi-slx7rpN3JAlizL4YqkXZ4cZOZi0N-na0_sd9ZNuoidhUBPwWy_iLjMH8tjaY3Au_SoFcTjcBe7xtTYORq3lP4OMFOX9BliSOxzcdKBzAvbdflw9Mcrbia3R34ymBjkJvstuQ")` }}>
            <div className="absolute inset-0 bg-black/40 backdrop-blur-sm group-hover:backdrop-blur-none transition-all duration-700"></div>
            <button className="relative z-10 glassmorphism size-16 rounded-full flex items-center justify-center border-accent-cyan/50 shadow-[0_0_20px_rgba(0,242,255,0.3)]">
              <span className="material-symbols-outlined text-accent-cyan text-3xl">view_in_ar</span>
            </button>
            <div className="absolute bottom-6 left-6 z-10">
              <p className="text-sm font-bold text-white">Live Decor Preview</p>
              <p className="text-[10px] text-white/70">AR Visualization Active</p>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
};

const PackageCard = ({ color, title, desc, price }: any) => (
  <div className={`min-w-[280px] glassmorphism p-5 rounded-3xl border-l-4 border-l-${color} relative group`}>
    <div className={`absolute top-4 right-4 text-${color}`}>
      <span className="material-symbols-outlined">auto_awesome</span>
    </div>
    <h4 className="text-lg font-bold mb-1">{title}</h4>
    <p className="text-xs text-gray-400 mb-4">{desc}</p>
    <div className="flex justify-between items-center">
      <span className="text-lg font-bold font-mono">{price}</span>
      <button className="bg-white text-black px-4 py-2 rounded-xl text-xs font-bold hover:bg-accent-cyan transition-colors">Book All</button>
    </div>
  </div>
);

const OptimizerGridItem = ({ icon, label, color, title, subtitle, note, tags }: any) => (
  <div className="glassmorphism p-5 rounded-3xl flex flex-col justify-between h-40">
    <div className="flex items-center justify-between">
      <span className={`material-symbols-outlined text-${color}`}>{icon}</span>
      <span className="text-[10px] font-bold text-gray-500">{label}</span>
    </div>
    <div>
      <p className="text-2xl font-bold tracking-tighter">{title}</p>
      <p className={`text-[10px] text-${color} font-bold uppercase mt-1`}>{subtitle}</p>
      {tags && (
        <div className="flex flex-wrap gap-1 mt-1">
          {tags.map((t: string) => <span key={t} className="bg-accent-pink/20 text-accent-pink text-[8px] px-1.5 py-0.5 rounded-full border border-accent-pink/30">{t}</span>)}
        </div>
      )}
    </div>
    <div className="text-[10px] text-gray-400">{note}</div>
  </div>
);

export default MastermindHub;
