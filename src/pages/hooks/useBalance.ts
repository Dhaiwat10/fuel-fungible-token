import { TestContractAbi } from '@/sway-api';
import { AbstractAddress, Address, BN, Provider } from 'fuels';
import { useEffect, useState } from 'react';

export const useBalance = ({
  provider,
  accountAddress,
  assetId,
}: {
  provider?: Provider;
  accountAddress?: AbstractAddress;
  assetId?: string;
}) => {
  const [balance, setBalance] = useState<BN>();

  useEffect(() => {
    (async () => {
      if (accountAddress && assetId && provider) {
        const balance = await provider.getBalance(accountAddress, assetId);
        setBalance(balance);
      }
    })();
  }, [provider, accountAddress, assetId]);

  return {
    balance,
  };
};
