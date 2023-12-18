import { Button, Input, InputAmount } from '@fuel-ui/react';

import contractIds from '@/sway-api/contract-ids.json';
import { TestContractAbi, TestContractAbi__factory } from '@/sway-api';
import { useEffect, useState } from 'react';
import {
  BaseAssetId,
  Provider,
  Wallet,
  WalletUnlocked,
  bn,
  concat,
  hash,
} from 'fuels';
import { useBalance } from './hooks/useBalance';

const CONTRACT_ID = contractIds.testContract;

export default function Home() {
  const [contractInstance, setContractInstance] = useState<TestContractAbi>();
  const [wallet, setWallet] = useState<WalletUnlocked>();
  const { balance: baseAssetBalance } = useBalance({
    provider: contractInstance?.provider,
    accountAddress: wallet?.address,
    assetId: BaseAssetId,
  });

  const { balance: customAssetBalance } = useBalance({
    provider: contractInstance?.provider,
    accountAddress: wallet?.address,
    assetId: hash(concat([CONTRACT_ID, BaseAssetId])),
  });

  useEffect(() => {
    (async () => {
      const provider = await Provider.create('http://127.0.0.1:4000/graphql');
      const wallet = Wallet.fromPrivateKey('0x01', provider);
      const contract = TestContractAbi__factory.connect(CONTRACT_ID, wallet);
      setWallet(wallet);
      setContractInstance(contract);
    })();
  }, []);

  const onMintClicked = async () => {
    if (contractInstance && wallet) {
      await contractInstance?.functions
        .mint(
          {
            Address: {
              value: wallet?.address.toB256(),
            },
          },
          BaseAssetId,
          bn(10_000)
        )
        .txParams({
          gasPrice: 1,
          gasLimit: 10_000,
        })
        .call();
    }
  };

  return (
    <div className='p-24 items-center flex flex-col'>
      {contractInstance && (
        <div>
          <h1 className='text-2xl'>
            Contract Address: {contractInstance.id.toB256()}
          </h1>
          <h1 className='text-2xl'>
            Native Asset Balance: {baseAssetBalance?.toString()}
          </h1>
          <h1 className='text-2xl'>
            Custom Asset Balance: {customAssetBalance?.toString()}
          </h1>
        </div>
      )}
      <Button onClick={onMintClicked}>Mint Custom Asset</Button>
    </div>
  );
}
