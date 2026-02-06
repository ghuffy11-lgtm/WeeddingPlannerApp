
import React from 'react';

interface Props {
  onBack: () => void;
}

const ARShowroom: React.FC<Props> = ({ onBack }) => {
  return (
    <div className="fixed inset-0 z-[100] bg-background-dark font-display text-white overflow-hidden">
      {/* Simulated AR Background */}
      <div className="absolute inset-0 z-0 bg-center bg-cover" 
        style={{ backgroundImage: `url('https://lh3.googleusercontent.com/aida-public/AB6AXuBGxsdblC8v1zcIjXsKInS_gG-LSeBShgj19UcEWwOCMWMxtj4o05_WLhpIbycPAw8HJK3DSV_gpgwFLTQSTp9UceN7mLMg2KBXt34wf690AUbIu_49AiPJy4KURw6CHWPrjupUWZX5j7n4zEWExjF26U6s0cm9WIVcI8jvdVIbPxW846MKCPjhZV5uHoc_2IPJP1ZRKcc7-P4gD__vDbnxcLUsGz2DD9Km8ONfugOUL09fWjjibOHpG3SdzpIn3geRj14Ygdq98II')` }}>
        
        {/* Holographic Anchor */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 border-2 border-primary/40 rounded-full flex items-center justify-center shadow-[0_0_15px_rgba(238,43,124,0.4)]">
          <div className="text-primary animate-pulse">
            <span className="material-symbols-outlined" style={{ fontSize: '64px' }}>filter_vintage</span>
          </div>
          <div className="absolute -right-24 top-0 glassmorphism p-2 rounded-lg text-xs">
            <p className="font-bold text-primary">Cyber-Flora v.4</p>
            <p className="text-white/70">Spatial Anchor: Fixed</p>
          </div>
        </div>

        <div className="absolute bottom-1/3 left-1/4 w-32 h-32 border border-primary/20 rounded-lg flex flex-col items-center justify-end pb-2 glassmorphism">
          <span className="material-symbols-outlined text-white/50">table_restaurant</span>
          <p className="text-[10px] text-white/60">Table Placement</p>
        </div>
      </div>

      <div className="relative z-10 flex flex-col h-screen">
        <header className="flex items-center glassmorphism m-4 rounded-xl p-3 justify-between">
          <div className="flex items-center gap-3">
            <button onClick={onBack} className="text-white flex size-10 items-center justify-center rounded-full bg-white/10">
              <span className="material-symbols-outlined">arrow_back</span>
            </button>
            <div>
              <h2 className="text-white text-sm font-bold">The Glass Pavilion</h2>
              <div className="flex items-center gap-1.5">
                <span className="size-2 bg-green-500 rounded-full"></span>
                <p className="text-[10px] text-white/60 uppercase tracking-widest">AI Agent: Scanning Space</p>
              </div>
            </div>
          </div>
          <button className="size-10 flex items-center justify-center rounded-full bg-primary/20 text-primary border border-primary/30">
            <span className="material-symbols-outlined">auto_awesome</span>
          </button>
        </header>

        <div className="flex-1"></div>

        <div className="px-4 pb-2">
          <div className="flex justify-between items-end mb-4">
            <div className="glassmorphism p-3 rounded-xl max-w-[160px]">
              <p className="text-[10px] text-white/50 uppercase font-bold mb-1">Live Estimate</p>
              <p className="text-xl font-bold">$12,450</p>
              <p className="text-[10px] text-primary">Includes 12 Vendors</p>
            </div>
            <div className="flex flex-col gap-2">
              <button className="flex items-center justify-center rounded-full size-12 glassmorphism"><span className="material-symbols-outlined">layers</span></button>
              <button className="flex items-center justify-center rounded-full size-12 glassmorphism"><span className="material-symbols-outlined">light_mode</span></button>
            </div>
          </div>
        </div>

        <div className="bg-gradient-to-t from-background-dark/80 via-background-dark/40 to-transparent pt-8 pb-10 px-4">
          <div className="flex items-center justify-center gap-2 mb-4">
            <span className="material-symbols-outlined text-primary text-sm">view_in_ar</span>
            <h4 className="text-white text-xs font-bold uppercase tracking-widest">Decor Kits</h4>
          </div>
          
          <div className="flex overflow-x-auto no-scrollbar gap-4 pb-4">
            <DecorKitCard title="Cyber-Ethereal" price="$4,200" active image="https://lh3.googleusercontent.com/aida-public/AB6AXuDdauSI7QnWyRbzyIUgKK7oX9WG4mBzr63vAH1s-xTSfsHpY7aMNlp1GYPORYyPTx-lK05k6qGZnB3lNNQbNMpYH7uAOUoMNS5JxIQSpPqgkuBYqnO8k8_w9pPPSx4MR-uQNTIRf1uwH1cCEc67YlfHhkyebovmhqOypNTGgceyZkWLzSyQeHxE2AlJxJD--vwmwnFfXUEDxaQnCnOkDLKh-A9L4YSmQATx0kBsCpyX4vtoRGg48sfXGO4bYo__e4I25vP96zJZifU" />
            <DecorKitCard title="Classic Bloom" price="$3,500" image="https://lh3.googleusercontent.com/aida-public/AB6AXuA3H-ZDNoE9NjqmMsfRGveCPwlt_ocDUgjRRe317GxdzUebyoqdeBsmookq8dhRsUYPJ2sR4X7hJ2zX30IqZdy4OBo8AeXk8VWVMNHljMBxJ1Xgp02BRct4Bv4fLm54A1bwMrPe8pmpXwXpuZffsj99htu_hUBNp42FUZT0mTou6IhAfb39LUiBoenIGM_Y-n_BwtYpPFXdsvQC5L8yRvJIfRf5yVrXGWtFxRair1UskZoN9p1qVRcLZVNPooQH3PdjudJxEVn4Hqo" />
          </div>

          <button className="w-full py-4 bg-primary text-white font-bold rounded-xl flex items-center justify-center gap-2 shadow-lg shadow-primary/30">
            <span className="material-symbols-outlined">smart_toy</span> Book This Look
          </button>
          
          <div className="flex items-center justify-center gap-8 mt-6">
            <ARActionButton icon="photo_library" label="Gallery" />
            <button className="flex items-center justify-center rounded-full size-16 border-4 border-white/20 bg-white/10 text-white">
              <span className="material-symbols-outlined text-4xl">photo_camera</span>
            </button>
            <ARActionButton icon="share" label="Share AR" />
          </div>
        </div>
      </div>
    </div>
  );
};

const DecorKitCard = ({ title, price, image, active = false }: any) => (
  <div className={`flex flex-col gap-3 rounded-xl min-w-[160px] glassmorphism p-2 ${active ? 'ring-2 ring-primary' : ''}`}>
    <div className="w-full aspect-square bg-cover rounded-lg" style={{ backgroundImage: `url("${image}")` }}></div>
    <div>
      <p className="text-white text-sm font-bold">{title}</p>
      <p className="text-white/50 text-[10px]">{price} Vendor Pkg.</p>
    </div>
  </div>
);

const ARActionButton = ({ icon, label }: any) => (
  <button className="flex flex-col items-center gap-1 text-white/60">
    <span className="material-symbols-outlined">{icon}</span>
    <span className="text-[10px]">{label}</span>
  </button>
);

export default ARShowroom;
