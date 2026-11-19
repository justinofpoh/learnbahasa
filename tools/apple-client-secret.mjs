#!/usr/bin/env node
// Makes the "Secret Key (for OAuth)" for Supabase › Authentication › Providers › Apple.
// Runs on your Mac only; the .p8 never leaves it. Apple caps these at 6 months, so re-run before then.
//
//   node tools/apple-client-secret.mjs ~/Downloads/AuthKey_ABC123DEFG.p8 ABC123DEFG
//
// Arguments: path to the .p8 file, then its Key ID (shown next to the key on developer.apple.com).
import { createPrivateKey, sign } from "node:crypto";
import { readFileSync } from "node:fs";

const [p8Path, keyId] = process.argv.slice(2);
const TEAM_ID = "Y4648M7S2X";
const SERVICES_ID = "com.justinpoh.bahasa.web";
if (!p8Path || !keyId) {
  console.error("Usage: node tools/apple-client-secret.mjs <AuthKey.p8> <KeyID>");
  process.exit(1);
}

const b64url = (input) => Buffer.from(input).toString("base64").replace(/=+$/, "").replace(/\+/g, "-").replace(/\//g, "_");
const now = Math.floor(Date.now() / 1000);
const header = { alg: "ES256", kid: keyId, typ: "JWT" };
const payload = { iss: TEAM_ID, iat: now, exp: now + 180 * 24 * 60 * 60, aud: "https://appleid.apple.com", sub: SERVICES_ID };
const unsigned = `${b64url(JSON.stringify(header))}.${b64url(JSON.stringify(payload))}`;
const key = createPrivateKey(readFileSync(p8Path));
const signature = sign("sha256", Buffer.from(unsigned), { key, dsaEncoding: "ieee-p1363" });

console.log(`${unsigned}.${b64url(signature)}`);
console.error(`\nPaste the line above into Supabase. It expires ${new Date((now + 180 * 86400) * 1000).toDateString()}; make a new one before then.`);
