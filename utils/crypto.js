import sodium from 'libsodium-wrappers';

export async function initCrypto() {
  await sodium.ready;
  return sodium;
}

export async function generateKeyPair() {
  const sodium = await initCrypto();
  return sodium.crypto_box_keypair();
}

export async function encryptMessage(message, publicKey, privateKey) {
  const sodium = await initCrypto();
  const nonce = sodium.randombytes_buf(sodium.crypto_box_NONCEBYTES);
  const ciphertext = sodium.crypto_box_easy(
    message,
    nonce,
    publicKey,
    privateKey
  );
  return { ciphertext, nonce };
}

export async function decryptMessage(ciphertext, nonce, publicKey, privateKey) {
  const sodium = await initCrypto();
  return sodium.crypto_box_open_easy(
    ciphertext,
    nonce,
    publicKey,
    privateKey
  );
}