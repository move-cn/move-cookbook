import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { SuiClient } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";

import dotenv from "dotenv";
dotenv.config();
const MNEMONIC = process.env.MNEMONIC!;
const keypair = Ed25519Keypair.deriveKeypair(MNEMONIC);

const FULLNODE_URL = "https://fullnode.testnet.sui.io:443";
const PACKAGE_ID =
  "0xb5b69526e8c37cc195b4ca881c60a897194ffd11b8adb3638b5909fbdb44119e";
const WEATHER_ORACLE =
  "0x50fe253f3913d4c120f1cc96a69db10b9bebed01a4fcb4e3957336f33d9fa4c3";
const MODULE_NAME = "weather_oracle";
const FUNCTION_NAME = "roll_dice_nft";
const GEO_NAME_ID_SZ = 1795566;

const SUI_CLIENT = new SuiClient({ url: FULLNODE_URL });

(async () => {
  let tx = new Transaction();
  tx.moveCall({
    target: `${PACKAGE_ID}::${MODULE_NAME}::${FUNCTION_NAME}`,
    arguments: [tx.object(WEATHER_ORACLE), tx.pure.u32(Number(GEO_NAME_ID_SZ))],
  });

  try {
    const result = await SUI_CLIENT.signAndExecuteTransaction({
      transaction: tx,
      signer: keypair,
      options: {
        showEvents: true,
      },
    });

    console.log(
      `signAndExecuteTransactionBlock result: ${JSON.stringify(
        result,
        null,
        2
      )}`
    );
  } catch (e) {
    console.error(e);
  }
})();
