#!/usr/bin/env python3
"""Read Keycloak's realm JWKS on stdin; print its RS256 signing key as an indented PEM public key."""
import base64, json, sys, textwrap

def der_len(n):
    if n < 0x80:
        return bytes([n])
    b = n.to_bytes((n.bit_length() + 7) // 8, "big")
    return bytes([0x80 | len(b)]) + b

def tlv(tag, body):
    return bytes([tag]) + der_len(len(body)) + body

def der_int(raw):
    return tlv(0x02, (b"\x00" if raw[0] & 0x80 else b"") + raw)

def b64u(s):
    return base64.urlsafe_b64decode(s + "=" * (-len(s) % 4))

key = next(k for k in json.load(sys.stdin)["keys"] if k.get("use") == "sig" and k["alg"] == "RS256")
rsa = tlv(0x30, der_int(b64u(key["n"])) + der_int(b64u(key["e"])))
algo = bytes.fromhex("300d06092a864886f70d0101010500")  # rsaEncryption, NULL params
spki = tlv(0x30, algo + tlv(0x03, b"\x00" + rsa))
body = textwrap.wrap(base64.b64encode(spki).decode(), 64)
for line in ["-----BEGIN PUBLIC KEY-----", *body, "-----END PUBLIC KEY-----"]:
    print("          " + line)
