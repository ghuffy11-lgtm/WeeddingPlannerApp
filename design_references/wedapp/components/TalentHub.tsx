
import React from 'react';

const TalentHub: React.FC = () => {
  return (
    <div className="flex-1 flex flex-col bg-background-dark">
      <header className="sticky top-0 z-50 bg-background-dark/80 backdrop-blur-xl border-b border-white/5">
        <div className="flex items-center p-4 pb-2 justify-between">
          <div className="flex size-10 shrink-0 items-center justify-center rounded-full bg-white/5">
            <span className="material-symbols-outlined text-xl">arrow_back</span>
          </div>
          <div className="text-center">
            <h2 className="text-xs font-bold tracking-[0.2em] uppercase text-white/40">Talent Hub</h2>
            <p className="text-lg font-extrabold tracking-tight">Entertainment</p>
          </div>
          <div className="flex size-10 items-center justify-end">
            <button className="flex size-10 items-center justify-center rounded-full bg-primary/20 text-primary">
              <span className="material-symbols-outlined">auto_awesome</span>
            </button>
          </div>
        </div>
        
        <div className="px-4 py-4">
          <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#1a1a2e] to-[#0a0a0c] border border-white/10 p-4">
            <div className="relative z-10 flex items-center justify-between">
              <div className="flex flex-col gap-1">
                <span className="flex items-center gap-2 text-accent text-[10px] font-bold uppercase tracking-wider">
                  <span className="size-1.5 rounded-full bg-accent animate-pulse"></span>
                  Vocal Match AI
                </span>
                <h3 className="text-sm font-bold">Find your singer's tone</h3>
                <p className="text-[11px] text-white/50">Upload a clip to match vocal profiles</p>
              </div>
              <button className="flex h-10 w-10 items-center justify-center rounded-full bg-white text-black shadow-lg">
                <span className="material-symbols-outlined">mic</span>
              </button>
            </div>
          </div>
        </div>

        <div className="flex gap-2 p-4 pt-0 overflow-x-auto no-scrollbar">
          {['Soloists', 'Jazz Bands', 'Electronic', 'Classical'].map((tag, i) => (
            <button key={tag} className={`flex h-9 shrink-0 items-center justify-center px-5 rounded-full text-xs font-bold ${i === 0 ? 'bg-white text-black' : 'border border-white/10 bg-white/5 text-white/70'}`}>
              {tag}
            </button>
          ))}
        </div>
      </header>

      <main className="flex-1 px-4 py-4 space-y-6">
        <div className="flex items-center justify-between">
          <p className="text-white/40 text-xs font-bold tracking-wide uppercase">Top Matches for Your Venue</p>
          <div className="flex items-center gap-1 text-accent">
            <span className="text-[11px] font-bold">AI Recommended</span>
            <span className="material-symbols-outlined text-sm">expand_more</span>
          </div>
        </div>

        <TalentCard 
          name="Elena Voci" 
          genre="Mezzo-Soprano • Soul & Jazz" 
          compatibility={98} 
          image="https://lh3.googleusercontent.com/aida-public/AB6AXuBVTEhVEDywA4Cu67cTRpIVti1qnp4QD605dE9sFpSQ5zZOSrppFoWJpaZOHLAwnH_jLtMBmnm1kGpTkMGrMNscd0ck6_I_mb9vugHbtv9V03JPeD9SMWn2CZ9Dj3tVijdSb8XFS5-Ccg8Sxf0m-EUczLGI9Q4XZkStcXi5syMhKhCf_x4q5oiBziKzY1oBRZZPLDTJdJpEGfWqFxmFuWmYKBB6mgpD4XVjhVfaxbkpvRCZzVlmuW3N6UeiLWfw0JuY1YqiKd_Ls08"
          rate="$1,850 — $2,400"
          rider="AV Sync Ready"
        />

        <TalentCard 
          name="Marcus J." 
          genre="Acoustic Pop • Live Looping" 
          compatibility={84} 
          image="https://lh3.googleusercontent.com/aida-public/AB6AXuCP5Ak3LKIVadyahJ4_0J_9SzRw0Kq-gPchphMboS4ntzYe7vnBn5l1erfoZ_I8A9ksfjoz1kw3ZlkeTt4cyueqEn3xr-sq5frTD02f3JvHgCLvcJWsw1gT548wTu1mdpqYymI-PqCHR40W_ekflpT9fVz_hOJSL39YNC5tF84I_sU65FFy3kcVE68_HxfWTXw13sorevyjjQpgjx64qeZKlDwt1jQGUeEdBeAbbMCGQ9STW2ixanO3-2EPuJb_pa6Auv28pWauV9A"
          rate="$950 — $1,200"
          rider="Needs PA System"
          isSecondary
        />
      </main>
    </div>
  );
};

const TalentCard = ({ name, genre, compatibility, image, rate, rider, isSecondary = false }: any) => (
  <div className={`group cursor-pointer ${isSecondary ? 'opacity-80' : ''}`}>
    <div className="glass-card rounded-[2rem] overflow-hidden transition-all duration-500 hover:border-accent/40">
      <div className="performance-vault-preview relative w-full aspect-[4/5] overflow-hidden bg-black">
        <img alt={name} className="vault-video absolute inset-0 h-full w-full object-cover transition-transform duration-700 brightness-75" src={image} />
        <div className="vault-overlay absolute inset-0 transition-opacity duration-500"></div>
        <div className="absolute top-4 left-4 bg-black/40 backdrop-blur-md px-3 py-1.5 rounded-full border border-white/10 flex items-center gap-2">
          <div className={`size-2 rounded-full ${compatibility > 90 ? 'bg-accent shadow-[0_0_8px_rgba(0,242,255,0.8)]' : 'bg-white/20'}`}></div>
          <span className="text-[11px] font-black text-white">{compatibility}% COMPATIBLE</span>
        </div>
        {!isSecondary && (
          <button className="absolute top-4 right-4 size-10 flex items-center justify-center rounded-full bg-black/20 backdrop-blur-md text-white border border-white/10">
            <span className="material-symbols-outlined text-[20px]">bookmark</span>
          </button>
        )}
        <div className="absolute bottom-6 left-6 right-6">
          <div className="flex items-end justify-between mb-2">
            <div>
              <h4 className="text-2xl font-black tracking-tighter uppercase italic">{name}</h4>
              <p className={`${isSecondary ? 'text-white/40' : 'text-accent'} text-[11px] font-bold tracking-widest uppercase`}>{genre}</p>
            </div>
            {!isSecondary && (
              <div className="flex flex-col items-end">
                <span className="text-white/40 text-[9px] font-bold uppercase tracking-tighter mb-1">Performance Vault</span>
                <div className="flex gap-1">
                  <div className="w-1 h-3 bg-white/20 rounded-full"></div>
                  <div className="w-1 h-5 bg-accent rounded-full"></div>
                  <div className="w-1 h-3 bg-white/20 rounded-full"></div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
      <div className={`p-6 pt-5 ${isSecondary ? 'bg-surface-dark/50' : 'bg-surface-dark'}`}>
        <div className="grid grid-cols-2 gap-4 mb-6">
          <div className="space-y-1">
            <p className="text-white/40 text-[10px] font-bold uppercase tracking-widest">Technical Rider</p>
            <div className="flex items-center gap-2">
              <span className={`material-symbols-outlined text-sm ${rider.includes('Ready') ? 'text-green-400' : 'text-amber-400'}`}>{rider.includes('Ready') ? 'check_circle' : 'info'}</span>
              <span className="text-xs font-bold text-white/90">{rider}</span>
            </div>
          </div>
          <div className="space-y-1">
            <p className="text-white/40 text-[10px] font-bold uppercase tracking-widest">Rate (60 min)</p>
            <p className="text-xs font-bold text-white/90">{rate}</p>
          </div>
        </div>
        {!isSecondary ? (
          <div className="flex gap-3">
            <button className="flex-1 bg-white text-black h-12 rounded-xl font-black text-xs uppercase tracking-widest flex items-center justify-center gap-2">
              <span>Automate Booking</span>
              <span className="material-symbols-outlined text-[18px]">bolt</span>
            </button>
            <button className="w-12 h-12 rounded-xl border border-white/10 flex items-center justify-center">
              <span className="material-symbols-outlined text-[20px]">visibility</span>
            </button>
          </div>
        ) : (
          <button className="w-full border border-white/10 h-12 rounded-xl font-black text-xs uppercase tracking-widest flex items-center justify-center gap-2 text-white/60">
            View Performance Vault
          </button>
        )}
      </div>
    </div>
  </div>
);

export default TalentHub;
