import React, { createContext, useContext, useState } from 'react';

const HeaderSlotContext = createContext(null);

export const HeaderSlotProvider = ({ children }) => {
  const [headerSlot, setHeaderSlot] = useState(null);

  return (
    <HeaderSlotContext.Provider value={{ headerSlot, setHeaderSlot }}>
      {children}
    </HeaderSlotContext.Provider>
  );
};

export const useHeaderSlot = () => {
  const context = useContext(HeaderSlotContext);
  return context?.headerSlot || null;
};

export const useSetHeaderSlot = () => {
  const context = useContext(HeaderSlotContext);
  return context?.setHeaderSlot || (() => {});
};

