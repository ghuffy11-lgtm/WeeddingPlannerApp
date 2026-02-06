
import React from 'react';
import { AppTab } from '../types';

interface Props {
  activeTab: AppTab;
  setActiveTab: (tab: AppTab) => void;
}

const BottomNav: React.FC<Props> = ({ activeTab, setActiveTab }) => {
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 mx-auto max-w-[430px] bg-background-dark/90 backdrop-blur-2xl border-t border-white/5 pb-10 pt-4">
      <div className="flex items-center justify-around px-2">
        <NavButton 
          icon="explore" 
          label="Discover" 
          active={activeTab === AppTab.DISCOVER} 
          onClick={() => setActiveTab(AppTab.DISCOVER)} 
        />
        <NavButton 
          icon="interpreter_mode" 
          label="Talent" 
          active={activeTab === AppTab.TALENT} 
          onClick={() => setActiveTab(AppTab.TALENT)} 
        />
        
        {/* Central Mastermind Button */}
        <button 
          onClick={() => setActiveTab(AppTab.MASTERMIND)}
          className={`flex size-14 items-center justify-center rounded-2xl bg-gradient-to-t from-primary to-[#ff5277] shadow-[0_8px_24px_rgba(255,45,85,0.4)] -mt-10 border-4 border-background-dark transition-transform active:scale-95 ${activeTab === AppTab.MASTERMIND ? 'ring-2 ring-accent' : ''}`}
        >
          <span className="material-symbols-outlined text-white text-3xl">hub</span>
        </button>

        <NavButton 
          icon="checklist" 
          label="Planner" 
          active={activeTab === AppTab.PLANNER} 
          onClick={() => setActiveTab(AppTab.PLANNER)} 
        />
        
        <div className="group relative flex flex-col items-center gap-1">
          <button 
            onClick={() => setActiveTab(AppTab.AGENT)}
            className={`flex flex-col items-center gap-1.5 transition-colors ${activeTab === AppTab.AGENT || activeTab === AppTab.REGISTRY ? 'text-primary' : 'text-white/40'}`}
          >
            <span className="material-symbols-outlined text-[24px]">more_horiz</span>
            <span className="text-[9px] font-bold uppercase tracking-[0.1em]">Menu</span>
          </button>
          
          {/* Subtle popover menu for remaining tabs */}
          <div className="absolute bottom-full mb-4 left-1/2 -translate-x-1/2 hidden group-hover:flex flex-col bg-surface-dark border border-white/10 rounded-xl overflow-hidden shadow-2xl min-w-[120px]">
            <button onClick={() => setActiveTab(AppTab.REGISTRY)} className="p-3 text-xs font-bold hover:bg-white/5 text-left flex items-center gap-2">
              <span className="material-symbols-outlined text-sm">featured_seasonal_and_gifts</span> Registry
            </button>
            <button onClick={() => setActiveTab(AppTab.AGENT)} className="p-3 text-xs font-bold hover:bg-white/5 text-left flex items-center gap-2 border-t border-white/5">
              <span className="material-symbols-outlined text-sm">shield</span> Agentic
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
};

const NavButton = ({ icon, label, active, onClick }: any) => (
  <button 
    onClick={onClick}
    className={`flex flex-col items-center gap-1.5 transition-colors ${active ? 'text-primary' : 'text-white/40'}`}
  >
    <span className="material-symbols-outlined text-[24px]" style={{ fontVariationSettings: active ? "'FILL' 1" : "'FILL' 0" }}>{icon}</span>
    <span className="text-[9px] font-bold uppercase tracking-[0.1em]">{label}</span>
  </button>
);

export default BottomNav;
