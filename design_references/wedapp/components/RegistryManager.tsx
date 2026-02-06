
import React from 'react';

const RegistryManager: React.FC = () => {
  return (
    <div className="flex-1 flex flex-col bg-background-light dark:bg-background-dark font-display text-[#181114] dark:text-white transition-colors duration-200">
      <header className="sticky top-0 z-50 flex items-center bg-white/80 dark:bg-background-dark/80 backdrop-blur-md p-4 pb-2 justify-between border-b border-gray-100 dark:border-gray-800">
        <div className="text-[#181114] dark:text-white flex size-12 shrink-0 items-center justify-start">
          <span className="material-symbols-outlined cursor-pointer">arrow_back_ios</span>
        </div>
        <h2 className="text-[#181114] dark:text-white text-lg font-bold leading-tight tracking-[-0.015em] flex-1 text-center">Registry Manager</h2>
        <div className="flex w-12 items-center justify-end">
          <button className="flex items-center justify-center rounded-lg h-12 text-[#181114] dark:text-white">
            <span className="material-symbols-outlined">more_horiz</span>
          </button>
        </div>
      </header>

      <main className="flex-1 pb-10">
        <div className="flex p-6 flex-col gap-4 items-center bg-white dark:bg-background-dark/40">
          <div className="bg-center bg-no-repeat aspect-square bg-cover rounded-full ring-4 ring-primary/10 w-32 h-32" 
            style={{ backgroundImage: `url("https://lh3.googleusercontent.com/aida-public/AB6AXuCx6DdQFY-InmOshREAm3m2NmOmqyhRh17QEhNjLbGwM0bmkPfPWuJCpc66PB_JFoOLNuO_owYFveym7Vt4JiMujVa3FZM6nZPRuy40eqgAuTFuOljm5Cnu4YG7m-EcXHaFNXLmuPRBbRz3mvH6vUe6q-6p3IwyFiyxU2y68N_sgkbdivKX0waXKe6QB0yfkt2BDGR8QnAZsYQGrwS7bDAryVaZIGuT65Oz8xwa-2SnPzy1gZhtbXNiBVbGZuD4xC4AutQDUi1Wz2I")` }}>
          </div>
          <div className="flex flex-col items-center">
            <p className="text-2xl font-bold leading-tight tracking-[-0.015em] text-center">Sarah & James's Registry</p>
            <p className="text-[#896172] dark:text-pink-200/60 text-base font-normal leading-normal text-center mt-1">Wedding Date: June 12, 2025</p>
          </div>
          <div className="flex gap-3 w-full mt-2">
            <button className="flex-1 flex items-center justify-center rounded-xl h-12 bg-primary text-white text-sm font-bold">
              <span className="material-symbols-outlined mr-2 text-lg">share</span> Share
            </button>
            <button className="flex-1 flex items-center justify-center rounded-xl h-12 bg-[#f4f0f2] dark:bg-gray-800 text-[#181114] dark:text-white text-sm font-bold">
              <span className="material-symbols-outlined mr-2 text-lg">edit</span> Edit
            </button>
          </div>
        </div>

        <div className="flex flex-wrap gap-3 p-4">
          <StatBox label="Total Items" value="42" />
          <StatBox label="Purchased" value="18" isHighlight />
          <StatBox label="Remaining" value="24" />
        </div>

        <div className="flex items-center justify-between px-4 pt-4 pb-2">
          <h2 className="text-[#181114] dark:text-white text-[20px] font-bold leading-tight">Our Gift List</h2>
          <button className="text-primary text-sm font-bold">Filter</button>
        </div>

        <div className="flex flex-col bg-white dark:bg-background-dark/20 divide-y divide-gray-50 dark:divide-gray-800">
          <RegistryListItem 
            title="KitchenAid Artisan Mixer" 
            subtitle="MOST WANTED" 
            info="1 of 1 Purchased" 
            price="$449" 
            image="https://lh3.googleusercontent.com/aida-public/AB6AXuBJXurH6n9Ggp6wjt_BdaXHC1etPX5MK-NmKGuJxP-cunBz58vXv6LLNK7noyqda5hBnNgBY27DAO4tLdEMGqxpWe_hOtJiya9c9bv6CZhFihDW87cxJJ8OuxtgluLxOvn4pFypth7c6QyAyGK-yEewDf-x53cPXfLTDdRl9dalPtcL9bViU_6sM_vMpDqhgz8VRbTkj-ygyGgPnD4wueuWzfLgn1I17_Z2B7HptAI6ltoTyP7f5gGfrDOsOgLWHVcu3I4nJ7Ndr24"
            isCompleted
          />
          <RegistryListItem 
            title="Italy Honeymoon Fund" 
            info="65% of $5,000 goal" 
            price="$3,250" 
            isFund 
            progress={65}
          />
        </div>
      </main>

      <div className="fixed bottom-28 left-0 right-0 p-4 bg-white/80 dark:bg-background-dark/80 backdrop-blur-lg flex justify-center">
        <button className="w-full h-14 bg-primary text-white font-bold rounded-xl shadow-lg flex items-center justify-center gap-2">
          <span className="material-symbols-outlined">add_circle</span> Add More Items
        </button>
      </div>
    </div>
  );
};

const StatBox = ({ label, value, isHighlight = false }: any) => (
  <div className="flex min-w-[100px] flex-1 flex-col gap-1 rounded-xl p-4 border border-primary/10 bg-white dark:bg-gray-900 shadow-sm">
    <p className="text-[#896172] dark:text-pink-200/60 text-xs font-medium uppercase tracking-wider">{label}</p>
    <p className={`${isHighlight ? 'text-primary' : 'text-[#181114] dark:text-white'} tracking-light text-2xl font-bold leading-tight`}>{value}</p>
  </div>
);

const RegistryListItem = ({ title, subtitle, info, price, image, isCompleted, isFund, progress }: any) => (
  <div className="flex items-center gap-4 px-4 min-h-[88px] py-4 justify-between hover:bg-gray-50 dark:hover:bg-gray-900/40 transition-colors">
    <div className="flex items-center gap-4">
      {isFund ? (
        <div className="bg-gradient-to-br from-primary to-pink-300 rounded-lg size-16 shadow-sm flex items-center justify-center text-white">
          <span className="material-symbols-outlined text-3xl">flight_takeoff</span>
        </div>
      ) : (
        <div className="bg-center bg-no-repeat aspect-square bg-cover rounded-lg size-16 shadow-sm" style={{ backgroundImage: `url("${image}")` }}></div>
      )}
      <div className="flex flex-col justify-center">
        <p className="text-[#181114] dark:text-white text-base font-semibold leading-normal line-clamp-1">{title}</p>
        {subtitle && <p className="text-primary text-xs font-bold leading-normal mb-1">{subtitle}</p>}
        <p className="text-[#896172] dark:text-pink-200/60 text-xs font-normal leading-normal mb-1">{info}</p>
        {progress !== undefined && (
          <div className="w-[100px] h-1.5 overflow-hidden rounded-full bg-[#e6dbe0] dark:bg-gray-700">
            <div className="h-full rounded-full bg-primary" style={{ width: `${progress}%` }}></div>
          </div>
        )}
      </div>
    </div>
    <div className="shrink-0 flex flex-col items-end gap-1">
      {isCompleted ? <span className="material-symbols-outlined text-green-500">check_circle</span> : <span className="material-symbols-outlined text-gray-400">more_vert</span>}
      <p className="text-[#181114] dark:text-white text-xs font-bold">{price}</p>
    </div>
  </div>
);

export default RegistryManager;
