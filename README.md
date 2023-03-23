# RSA

```bash
./rsa.sh --help
```

This command is an RSA algorithm implementation written in shell script.
There are three modes to choose from:

I. Key generation:
usage:
```bash
./rsa.sh --key-generation <1st prime number> <2nd prime number>
```
eg:
```bash
./rsa.sh --key-generation 707981 906313
```

II. Encrypt mode:
usage:
```bash
./rsa.sh --encrypt --public-exponent <e> --modulus <n> <file>
```
eg:
```bash
./rsa.sh --encrypt --public-exponent 65537 --modulus 641652384053 testfile
```

usage:
```bash
./rsa.sh --key-generation <1st prime number> <2nd prime number> --encrypt <file>
```
eg:
```bash
./rsa.sh --key-generation 707981 906313 --encrypt testfile
```

III. Decrypt mode:
usage:
```bash
./rsa.sh --decrypt --private-exponent <d> --modulus <n> <file>
```
eg:
```bash
./rsa.sh --decrypt --private-exponent 64657547393 --modulus 641652384053 testfile
```
