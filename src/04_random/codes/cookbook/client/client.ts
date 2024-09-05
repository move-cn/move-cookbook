import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { SuiClient } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";

import dotenv from "dotenv";
dotenv.config();
const MNEMONIC = process.env.MNEMONIC!;
const keypair = Ed25519Keypair.deriveKeypair(MNEMONIC);

const PACKAGE_ID =
  "0xc80da11fbee3b9b74f3cf3fc7f013b6c12041b6ba68261019cf77fa3cbdc0966";
const MODULE_NAME = "random";
const FUNCTION_NAME = "roll_dice_nft";
const FULLNODE_URL = "https://fullnode.testnet.sui.io:443";

const SUI_CLIENT = new SuiClient({ url: FULLNODE_URL });

(async () => {
  let tx = new Transaction();
  tx.moveCall({
    target: `${PACKAGE_ID}::${MODULE_NAME}::${FUNCTION_NAME}`,
    arguments: [tx.object("0x8")],
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
