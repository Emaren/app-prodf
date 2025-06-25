window.suggestWolo = async () => {
  if (!window.keplr) return;
  await window.keplr.experimentalSuggestChain({
    chainId: "wolochain",
    chainName: "WoloChain",
    rpc: "https://rpc.wolo.aoe2hdbets.com",
    rest: "https://api.wolo.aoe2hdbets.com",
    stakeCurrency: {
      coinDenom: "WOLO",
      coinMinimalDenom: "uwolo",
      coinDecimals: 6,
    },
    bip44: { coinType: 118 },
    bech32Config: {
      bech32PrefixAccAddr: "wolo",
      bech32PrefixAccPub: "wolopub",
      bech32PrefixValAddr: "wolovaloper",
      bech32PrefixValPub: "wolovaloperpub",
      bech32PrefixConsAddr: "wolovalcons",
      bech32PrefixConsPub: "wolovalconspub",
    },
    currencies: [{ coinDenom: "WOLO", coinMinimalDenom: "uwolo", coinDecimals: 6 }],
    feeCurrencies: [{ coinDenom: "WOLO", coinMinimalDenom: "uwolo", coinDecimals: 6 }],
    gasPriceStep: { low: 0.01, average: 0.025, high: 0.04 },
  });
};

