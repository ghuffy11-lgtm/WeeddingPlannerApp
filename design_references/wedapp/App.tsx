
import React, { useState, useEffect } from 'react';
import { AppTab } from './types';
import DiscoveryHome from './components/DiscoveryHome';
import TalentHub from './components/TalentHub';
import Checklist from './components/Checklist';
import MastermindHub from './components/MastermindHub';
import RegistryManager from './components/RegistryManager';
import AgenticExecution from './components/AgenticExecution';
import ARShowroom from './components/ARShowroom';
import BottomNav from './components/BottomNav';

const App: React.FC = () => {
  const [activeTab, setActiveTab] = useState<AppTab>(AppTab.DISCOVER);

  const renderScreen = () => {
    switch (activeTab) {
      case AppTab.DISCOVER:
        return <DiscoveryHome onNavigate={setActiveTab} />;
      case AppTab.TALENT:
        return <TalentHub />;
      case AppTab.PLANNER:
        return <Checklist />;
      case AppTab.MASTERMIND:
        return <MastermindHub onNavigate={setActiveTab} />;
      case AppTab.REGISTRY:
        return <RegistryManager />;
      case AppTab.AGENT:
        return <AgenticExecution />;
      case AppTab.AR_SHOWROOM:
        return <ARShowroom onBack={() => setActiveTab(AppTab.MASTERMIND)} />;
      default:
        return <DiscoveryHome onNavigate={setActiveTab} />;
    }
  };

  // Ensure AR showroom feels fullscreen
  const isAR = activeTab === AppTab.AR_SHOWROOM;

  return (
    <div className="flex justify-center min-h-screen bg-[#050508]">
      <div className={`relative flex h-auto min-h-screen w-full max-w-[430px] flex-col bg-background-dark shadow-2xl overflow-x-hidden ${isAR ? '' : 'pb-24'}`}>
        {renderScreen()}
        {!isAR && <BottomNav activeTab={activeTab} setActiveTab={setActiveTab} />}
      </div>
    </div>
  );
};

export default App;
