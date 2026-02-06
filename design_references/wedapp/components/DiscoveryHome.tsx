
import React from 'react';
import { AppTab } from '../types';

interface Props {
  onNavigate: (tab: AppTab) => void;
}

const DiscoveryHome: React.FC<Props> = ({ onNavigate }) => {
  return (
    <div className="flex-1 flex flex-col">
      <header className="sticky top-0 z-50 flex items-center bg-white/5 backdrop-blur-md p-4 pb-2 justify-between border-b border-white/5">
        <div className="flex size-12 shrink-0 items-center justify-start">
          <span className="material-symbols-outlined text-2xl">search</span>
        </div>
        <h2 className="text-white text-lg font-bold leading-tight tracking-tight flex-1 text-center font-display">Discovery Home</h2>
        <div className="flex w-12 items-center justify-end">
          <button className="flex items-center justify-center rounded-lg h-12 bg-transparent text-white">
            <span className="material-symbols-outlined text-2xl">favorite</span>
          </button>
        </div>
      </header>

      <main className="flex-1">
        <section className="px-0 py-0 sm:px-4 sm:py-3">
          <div className="bg-cover bg-center flex flex-col justify-end overflow-hidden sm:rounded-xl min-h-[400px] relative" 
            style={{ backgroundImage: `linear-gradient(0deg, rgba(34, 16, 24, 0.7) 0%, rgba(34, 16, 24, 0) 50%), url("https://lh3.googleusercontent.com/aida-public/AB6AXuDjf8kCz0MeuxNlF52mzdP1M6a1aHeF9VlhyKa7EkKZmjncmoLi5Kj5Ayn5UijZ-bdL4cNYj_6nQttxzrBUngqmkhsRxQpBGgF0EIAl29zaQqbnKC4yzQh4aICY3J9fv5tF2r4Ysi-slx7rpN3JAlizL4YqkXZ4cZOZi0N-na0_sd9ZNuoidhUBPwWy_iLjMH8tjaY3Au_SoFcTjcBe7xtTYORq3lP4OMFOX9BliSOxzcdKBzAvbdflw9Mcrbia3R34ymBjkJvstuQ")` }}>
            <div className="flex flex-col p-6 gap-2">
              <p className="text-white text-[32px] font-bold leading-tight tracking-tight">Your Dream Wedding Starts Here</p>
              <p className="text-white/80 text-sm max-w-[280px]">Discover vendors, themes, and shop the latest bridal trends.</p>
              <button className="mt-4 bg-primary text-white font-bold py-3 px-6 rounded-full w-fit hover:opacity-90 transition-opacity">
                Get Inspired
              </button>
            </div>
          </div>
        </section>

        <div className="flex items-center justify-between px-4 pt-8 pb-3">
          <h2 className="text-white text-[22px] font-bold leading-tight tracking-tight">Trending Themes</h2>
          <a className="text-primary text-sm font-semibold" href="#">See All</a>
        </div>

        <div className="flex overflow-x-auto no-scrollbar scroll-smooth">
          <div className="flex items-stretch px-4 gap-4 pb-4">
            <ThemeCard title="Rustic Charm" subtitle="Warm and earthy vibes" image="https://lh3.googleusercontent.com/aida-public/AB6AXuCzRmjlonm6MVPZ31YehIKmbKkWxzECwggin2NDeL61qkdvIkwBAc3Pew6S3reFIWZ3l8dAaqClvEVXAbT9_RuEgsrCVeg71dxymBQVb79bV_nV2z3DBoKM4ROLoT1uIbY9aQNyBqsxgGQrwc-9wnotdZF_4iW8Yc--LkyAso-T1svDODgFDxVe7oLo3qr8GTWgkm6ou74d6_YTBnz-Cr_hMN5bHIubVh2la260jot6qBNWmhYzVKr8X2l_Ak8uo10TnkjNtjpzGGc" />
            <ThemeCard title="Modern Chic" subtitle="Clean lines and minimalist" image="https://lh3.googleusercontent.com/aida-public/AB6AXuDNDcPeCkTIsNi6CxH3yZVLCxv7r_prNizxMlcV5Y-WNLy7XfxO6i_tw5e2YQKVZueBVPZQ6di0Wa9-dxDi6Rtr_Vk3vPxCQZS5wooyCU-aq3jbPto_qYp0GvUpmqu8Jk7WxKY_PY48H1pAN0rqtiZqLiM6WbJ72F_czpEDVzUf_2KiFGWvXJmvjJJ9GjNgXYuGgkZE1HFo8ZgCrkXGvW-dZ7UlzBYop8ZltugZpLyLdyt3zXPJZ3ceK9b30QnjLpP3ngjBvM5lFNs" />
          </div>
        </div>

        <div className="px-4 py-6">
          <div className="bg-primary/10 p-6 rounded-xl flex flex-col gap-3 border border-primary/20">
            <h3 className="text-white text-lg font-bold">Planning for a specific date?</h3>
            <p className="text-gray-400 text-sm">Tell us your wedding date to get personalized recommendations and countdowns.</p>
            <button className="bg-primary text-white text-sm font-bold py-3 px-6 rounded-lg w-full mt-2" onClick={() => onNavigate(AppTab.PLANNER)}>Set Wedding Date</button>
          </div>
        </div>

        <div className="flex items-center justify-between px-4 pt-6 pb-3">
          <h2 className="text-white text-[22px] font-bold leading-tight tracking-tight">Featured Vendors</h2>
          <a className="text-primary text-sm font-semibold" href="#">See All</a>
        </div>

        <div className="flex overflow-x-auto no-scrollbar px-4 gap-4 pb-8">
          <VendorCircle name="Elena Bloom" role="Photographer" rating="4.9" image="https://lh3.googleusercontent.com/aida-public/AB6AXuCLrA1YjVXKCgMEPdEaUbr3FHoz_jZ17a-kmVsd1K4rzBVQDdsoVyvtQCeuo-rMKMoKaxAYR3R5NBG0_PMxMTD0F2MdWTO0SMkeV6mmWAt9HLvxN0hzD7ryjNVG3HssevGVYzLBvKikBbgFF2CEv_isKGa0Kz6um_wGziPFIZlqRYubnEeVq9KDPWIJvXc_hTmX5qM0gctl1YsnSAmhTMRGpTqxZ4yJ40eyrHCe2ozMUwf_w7q8rpmykqcOo9NOsIK2P7IxiveW0J0" />
          <VendorCircle name="Petals & Co." role="Floral Design" rating="4.8" image="https://lh3.googleusercontent.com/aida-public/AB6AXuDmiqCySMFBDthGiGWwlDXkej6ZIOqVjWum8Z8u4hP6js9SNcghHttpjDyPYdIkX87HWPFlGwr6DXY3uMB9NPpiNwL5iv4c_L4tsmbLY94lxLcAss-KemspXmkYMZCUOxNcMiqC5Wrf38D9TvkJH3khNiNPpoyGVfsKm5IKjRpFAjwidzcSKUm5iWstxsg34h9jXXjzIZtkmp-A8c40donISnJGU-Z7ymhWfHh11lXMa-51rt2TB1yd9A8jQT9oNn9t2ZJe8F8Sq6w" />
        </div>
      </main>
    </div>
  );
};

const ThemeCard = ({ title, subtitle, image }: { title: string, subtitle: string, image: string }) => (
  <div className="flex flex-col gap-3 rounded-xl min-w-[240px]">
    <div className="w-full bg-center bg-no-repeat aspect-[4/5] bg-cover rounded-xl" style={{ backgroundImage: `url("${image}")` }}></div>
    <div>
      <p className="text-white text-base font-bold">{title}</p>
      <p className="text-primary text-sm font-medium">{subtitle}</p>
    </div>
  </div>
);

const VendorCircle = ({ name, role, rating, image }: { name: string, role: string, rating: string, image: string }) => (
  <div className="flex flex-col gap-2 min-w-[140px]">
    <div className="relative w-full aspect-square rounded-full border-2 border-primary/20 p-1">
      <div className="w-full h-full rounded-full bg-cover bg-center" style={{ backgroundImage: `url("${image}")` }}></div>
    </div>
    <div className="text-center">
      <p className="text-white text-sm font-bold">{name}</p>
      <p className="text-gray-500 text-xs">{role}</p>
      <div className="flex items-center justify-center gap-1 mt-1">
        <span className="material-symbols-outlined text-[14px] text-yellow-500 fill-current">star</span>
        <span className="text-[12px] font-bold">{rating}</span>
      </div>
    </div>
  </div>
);

export default DiscoveryHome;
