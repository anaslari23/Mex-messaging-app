import { webcrypto } from 'crypto'

export async function generateKeyPair() {
  const keyPair = await webcrypto.subtle.generateKey(
    {
      name: 'RSA-OAEP',
      modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]),
      hash: 'SHA-256'
    },
    true,
    ['encrypt', 'decrypt']
  )

  const publicKey = await webcrypto.subtle.exportKey('spki', keyPair.publicKey)
  const privateKey = await webcrypto.subtle.exportKey('pkcs8', keyPair.privateKey)

  return {
    publicKey: Buffer.from(publicKey).toString('base64'),
    privateKey: Buffer.from(privateKey).toString('base64')
  }
}

export async function encryptMessage(message: string, publicKeyBase64: string) {
  const publicKey = await webcrypto.subtle.importKey(
    'spki',
    Buffer.from(publicKeyBase64, 'base64'),
    {
      name: 'RSA-OAEP',
      hash: 'SHA-256'
    },
    true,
    ['encrypt']
  )

  const encoded = new TextEncoder().encode(message)
  const encrypted = await webcrypto.subtle.encrypt(
    { name: 'RSA-OAEP' },
    publicKey,
    encoded
  )

  return Buffer.from(encrypted).toString('base64')
}

export async function decryptMessage(encryptedMessage: string, privateKeyBase64: string) {
  const privateKey = await webcrypto.subtle.importKey(
    'pkcs8',
    Buffer.from(privateKeyBase64, 'base64'),
    {
      name: 'RSA-OAEP',
      hash: 'SHA-256'
    },
    true,
    ['decrypt']
  )

  const decrypted = await webcrypto.subtle.decrypt(
    { name: 'RSA-OAEP' },
    privateKey,
    Buffer.from(encryptedMessage, 'base64')
  )

  return new TextDecoder().decode(decrypted)
}
