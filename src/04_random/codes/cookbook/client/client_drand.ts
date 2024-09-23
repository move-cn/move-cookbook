import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { SuiClient } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";

import axios from "axios";
import dotenv from "dotenv";
dotenv.config();
const MNEMONIC = process.env.MNEMONIC!;
const keypair = Ed25519Keypair.deriveKeypair(MNEMONIC);

const FULLNODE_URL = "https://fullnode.testnet.sui.io:443";
const PACKAGE_ID =
  "0xe94fae15e81744ec0d64c45de6efe8feeb7e14d9894b20316d7e57b7a8274ad0";
const MODULE_NAME = "drand";
const FUNCTION_NAME = "roll_dice_nft";

const SUI_CLIENT = new SuiClient({ url: FULLNODE_URL });

function hexStringToU8Vector(hexString: string): number[] {
  const u8Vector: number[] = [];
  for (let i = 0; i < hexString.length; i += 2) {
    u8Vector.push(parseInt(hexString.slice(i, i + 2), 16));
  }

  return u8Vector;
}

(async () => {
  const url =
    "https://drand.cloudflare.com/52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971/public/latest";

  const response = await axios.get(url);
  const data = response.data;

  const round = data.round; // eg: 10934869
  const signature = data.signature; // eg: "b2916323d2a94f95648f8cc72c3462352bcca735391f5d29c141166da03526b5ab6c63b0cc5905251f9d06e5e0420e9f";

  let tx = new Transaction();

  let signatureVec = hexStringToU8Vector(signature);

  tx.moveCall({
    target: `${PACKAGE_ID}::${MODULE_NAME}::${FUNCTION_NAME}`,
    arguments: [tx.pure.u64(round), tx.pure.vector("u8", signatureVec)],
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
