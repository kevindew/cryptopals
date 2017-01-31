# Ruby resources for [Cryptopals](https://cryptopals.com/)

I'm trying to fill in my knowledge gaps with cryptography by working through
the [cryptopal](https://cryptopals.com/) challenges. This repo contains
resources to work on the problems.

Usage in irb:

```
irb(main):001:0> load "./crypto.rb"
=> true
irb(main):002:0> Crypto.bytes_to_base64(Crypto.hex_to_bytes("49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"))
=> "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
```

Note - if you are doing these challenges yourself you should work these out
yourself rather than using this code.

