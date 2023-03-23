# RSA

```bash
./rsa.sh --help
```

This command is an RSA algorithm implementation written in shell script.
There are three modes to choose from:

I. Key generation:
usage: ./rsa.sh --key-generation <1st prime number> <2nd prime number>
eg: ./rsa.sh --key-generation 707981 906313

II. Encrypt mode:
usage: ./rsa.sh --encrypt --public-exponent <e> --modulus <n> <file>
eg: ./rsa.sh --encrypt --public-exponent 65537 --modulus 641652384053 testfile
usage: ./rsa.sh --key-generation <1st prime number> <2nd prime number> --encrypt <file>
eg: ./rsa.sh --key-generation 707981 906313 --encrypt testfile

III. Decrypt mode:
usage: ./rsa.sh --decrypt --private-exponent <d> --modulus <n> <file>
eg: ./rsa.sh --decrypt --private-exponent 64657547393 --modulus 641652384053 testfile
