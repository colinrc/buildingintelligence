package au.com.BI.Util;

//
//TEA.java
//
//Created by Thomas Dixon on 12/30/05.
//

import java.security.InvalidKeyException;

public class TEA {

	/**** Constants ****/
	public final int ROUNDS = 32, // iteration count (cycles)
			BLOCK_SIZE = 8, // bytes in a data block (64 bits)
			KEY_SIZE = 16; // key size (128 bits)
	
	public final int DELTA = 0x9E3779B9, D_SUM = 0xC6EF3720;

	/**** Instance vars ****/
	//Subkeys
	private int[] S = new int[4];

	//False for encipher, true for decipher
	private boolean decrypt;

	// Initialization
	public void engineInit(byte[] key, boolean decipher)
			throws InvalidKeyException {
		/*
		if (key == null) {
			throw new InvalidKeyException("Null key");
		}

		if (key.length != KEY_SIZE) {
			throw new InvalidKeyException("Invalid key length (req. 16 bytes)");
		}

		generateSubKeys(key);
		*/
		S[0] = 1;
		S[1] = 2;
		S[2] = 3;
		S[3] = 4;
		
		decrypt = decipher;
	}

	// Encrypt one block of data with XTEA algorithm
	public byte[] engineCrypt(byte[] in, int inOffset) {
		// Pack bytes into integers
		int v0 = ((in[inOffset++] & 0xFF)) | ((in[inOffset++] & 0xFF) << 8)
				| ((in[inOffset++] & 0xFF) << 16) | ((in[inOffset++]) << 24);
		int v1 = ((in[inOffset++] & 0xFF)) | ((in[inOffset++] & 0xFF) << 8)
				| ((in[inOffset++] & 0xFF) << 16) | ((in[inOffset++]) << 24);

		int n = ROUNDS, sum;

		// Encipher
		if (!decrypt) {
			sum = 0;

			while (n-- > 0) {
				v0 += ((v1 << 4 ^ v1 >> 5) + v1) ^ (sum + S[sum & 3]);
				sum += DELTA;
				v1 += ((v0 << 4 ^ v0 >> 5) + v0) ^ (sum + S[sum >> 11 & 3]);
			}
			// Decipher
		} else {
			sum = D_SUM;

			while (n-- > 0) {
				v1 -= ((v0 << 4 ^ v0 >> 5) + v0) ^ (sum + S[sum >> 11 & 3]);
				sum -= DELTA;
				v0 -= ((v1 << 4 ^ v1 >> 5) + v1) ^ (sum + S[sum & 3]);
			}
		}

		// Unpack and return
		int outOffset = 0;
		byte[] out = new byte[BLOCK_SIZE];
		out[outOffset++] = (byte) (v0);
		out[outOffset++] = (byte) (v0 >>> 8);
		out[outOffset++] = (byte) (v0 >>> 16);
		out[outOffset++] = (byte) (v0 >>> 24);

		out[outOffset++] = (byte) (v1);
		out[outOffset++] = (byte) (v1 >>> 8);
		out[outOffset++] = (byte) (v1 >>> 16);
		out[outOffset++] = (byte) (v1 >>> 24);

		return out;
	}

	// Subkey generator
	public void generateSubKeys(byte[] key) {
		for (int off = 0, i = 0; i < 4; i++) {
			S[i] = ((key[off++] & 0xFF)) | ((key[off++] & 0xFF) << 8)
					| ((key[off++] & 0xFF) << 16) | ((key[off++] & 0xFF) << 24);
		}
	}
}
