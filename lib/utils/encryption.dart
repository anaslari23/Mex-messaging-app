import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class EncryptionService {
  static final _iv = IV.fromLength(16);

  // Generate RSA key pair
  static Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>>
      generateRSAKeyPair() async {
    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        SecureRandom('SHA-256/RSA'),
      ));
    return keyGen.generateKeyPair();
  }

  // Encrypt message with public key
  static String encryptMessage(String plaintext, RSAPublicKey publicKey) {
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    return encrypter.encrypt(plaintext).base64;
  }

  // Decrypt message with private key
  static String decryptMessage(String ciphertext, RSAPrivateKey privateKey) {
    final encrypter = Encrypter(RSA(privateKey: privateKey));
    return encrypter.decrypt(Encrypted.fromBase64(ciphertext));
  }
}
