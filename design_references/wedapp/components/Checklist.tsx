
import React from 'react';

const Checklist: React.FC = () => {
  return (
    <div className="flex-1 flex flex-col bg-white dark:bg-background-dark">
      <header className="sticky top-0 z-10 flex items-center bg-white/80 dark:bg-background-dark/80 backdrop-blur-md p-4 pb-2 justify-between border-b border-gray-100 dark:border-white/10">
        <div className="text-[#181114] dark:text-white flex size-12 shrink-0 items-center justify-start">
          <span className="material-symbols-outlined text-[24px]">arrow_back_ios</span>
        </div>
        <h2 className="text-[#181114] dark:text-white text-lg font-bold leading-tight tracking-[-0.015em] flex-1 text-center font-display">Wedding Checklist</h2>
        <div className="flex w-12 items-center justify-end">
          <button className="flex items-center justify-center rounded-lg h-12 text-[#181114] dark:text-white">
            <span className="material-symbols-outlined text-[24px]">tune</span>
          </button>
        </div>
      </header>

      <main className="flex-1 p-4">
        <div className="flex flex-col gap-3 mb-8">
          <div className="flex gap-6 justify-between items-center">
            <p className="text-[#181114] dark:text-white text-lg font-bold leading-normal">Our Big Day Progress</p>
            <p className="text-primary text-base font-bold leading-normal">45%</p>
          </div>
          <div className="rounded-full bg-[#e6dbe0] dark:bg-white/10 h-3 overflow-hidden">
            <div className="h-full rounded-full bg-primary" style={{ width: '45%' }}></div>
          </div>
          <p className="text-[#896172] dark:text-gray-400 text-sm font-medium leading-normal">48 of 102 tasks completed</p>
        </div>

        <section className="mb-8">
          <div className="flex items-center justify-between pb-4">
            <h2 className="text-[#181114] dark:text-white text-[20px] font-bold leading-tight tracking-[-0.015em]">12 Months Out</h2>
            <span className="text-primary text-sm font-semibold">View All</span>
          </div>
          <div className="flex flex-col divide-y divide-gray-50 dark:divide-white/5 bg-gray-50/50 dark:bg-white/5 rounded-2xl overflow-hidden">
            <TaskItem title="Set a Budget" date="Completed Oct 01" completed />
            <TaskItem title="Draft Guest List" date="Due Oct 15, 2024" />
            <TaskItem title="Book Ceremony Venue" date="Due Tomorrow" isUrgent />
          </div>
        </section>

        <section className="mb-8">
          <div className="flex items-center justify-between pb-4">
            <h2 className="text-[#181114] dark:text-white text-[20px] font-bold leading-tight tracking-[-0.015em]">9 Months Out</h2>
          </div>
          <div className="flex flex-col divide-y divide-gray-50 dark:divide-white/5 bg-gray-50/50 dark:bg-white/5 rounded-2xl overflow-hidden">
            <TaskItem title="Hire Photographer" date="Due Dec 12, 2024" isHighPriority />
            <TaskItem title="Shop for Wedding Rings" date="Due Jan 05, 2025" hasShopLink />
          </div>
        </section>

        <div className="p-4 rounded-xl bg-gradient-to-br from-[#ee2b7c] to-[#ff6b9d] text-white relative overflow-hidden mb-8">
          <div className="relative z-10 flex flex-col gap-1">
            <p className="text-sm font-bold opacity-90 uppercase tracking-widest">Planning Tip</p>
            <p className="text-lg font-bold">Booking early saves 15%</p>
            <p className="text-xs opacity-80">See our partner venues for exclusive deals.</p>
            <button className="mt-2 w-max px-4 py-2 bg-white text-primary rounded-lg text-xs font-bold">Explore Venues</button>
          </div>
          <div className="absolute top-[-20px] right-[-20px] opacity-20">
            <span className="material-symbols-outlined text-[120px]">celebration</span>
          </div>
        </div>
      </main>

      <button className="fixed bottom-28 right-8 z-20 flex size-14 items-center justify-center rounded-full bg-primary text-white shadow-lg shadow-primary/40 active:scale-95 transition-transform">
        <span className="material-symbols-outlined text-[28px]">add</span>
      </button>
    </div>
  );
};

const TaskItem = ({ title, date, completed = false, isUrgent = false, isHighPriority = false, hasShopLink = false }: any) => (
  <div className="flex items-center gap-4 px-4 min-h-[72px] py-2 justify-between">
    <div className="flex items-center gap-4">
      <div className="flex size-7 items-center justify-center">
        <input defaultChecked={completed} className="h-6 w-6 rounded border-[#e6dbe0] border-2 bg-transparent text-primary checked:bg-primary checked:border-primary focus:ring-0 focus:ring-offset-0" type="checkbox" />
      </div>
      <div className="flex flex-col justify-center">
        <p className={`text-[#181114] dark:text-white text-base font-semibold leading-normal ${completed ? 'line-through opacity-50' : ''}`}>{title}</p>
        <p className={`${isUrgent ? 'text-primary font-semibold' : 'text-[#896172] dark:text-gray-400'} text-xs font-normal leading-normal`}>{date}</p>
      </div>
    </div>
    <div className="shrink-0 flex items-center gap-2">
      {isHighPriority && <div className="px-2 py-1 rounded bg-primary/10 text-primary text-[10px] font-bold uppercase tracking-wider">High Priority</div>}
      {hasShopLink && (
        <button className="flex items-center justify-center px-3 py-1.5 bg-primary rounded-full text-white text-xs font-bold gap-1">
          <span className="material-symbols-outlined text-[14px]">shopping_bag</span>
          Shop
        </button>
      )}
      <span className="material-symbols-outlined text-gray-400 text-[20px]">chevron_right</span>
    </div>
  </div>
);

export default Checklist;
