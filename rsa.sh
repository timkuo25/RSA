#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
cd $(dirname $[0])

function power(){
    a=$1
    n=$2
    N=$3
    ans=1
    while [[ $n > 0 ]]; do
        read num < <(bc <<< "$n % 2")
        if [[ $num -eq 1 ]]; then
            read ans < <(bc <<< "$ans * $a % $N")
        fi
        read a < <(bc <<< "$a * $a % $N")
        read long < <(bc <<< "$n / 2")
        n=$long
    done
    echo $ans
}

function valid(){
    num=$1
    pattern_hex="^[0-9a-fA-F]+$"
    pattern_dec="^[0-9]+$"
	

    if [[ ${num:0:2} == "0x" ]]; then
        num_hex=${num:2}
        if [[ $num_hex =~ $pattern_hex ]]; then
        	num_upper=$(echo ${num:2} | tr '[:lower:]' '[:upper:]')
        	num_lower=$(echo ${num:2} | tr '[:upper:]' '[:lower:]')
        	if [[ $num_hex == $num_upper ]] || [[ $num_hex == $num_lower ]]; then
				echo 1
				return
			else
				echo 0
				return
			fi
        else
            echo 0
            return
        fi
    fi
    if [[ $num =~ $pattern_dec ]]; then
        echo 1
        return
    fi
    echo 0
    return
}

function euc(){
    a=$1
    b=$2

    if  (( b == 0 )); then
        echo "$a:1:0"
    else
        read long < <(bc <<< "$a % $b")
        result=$(euc $b $long)
        gcd=$(echo $result | cut -d ":" -f 1)
        x=$(echo $result | cut -d ":" -f 2)
        y=$(echo $result | cut -d ":" -f 3)

        read ans < <(bc <<< "$x - ($a / $b) * $y")

        echo "$gcd:$y:$ans"
    fi
}

# Argument parsing
# echo original parameters=[$@]
ARGS=$(getopt -o h --long help,encrypt,decrypt,public-exponent:,private-exponent:,modulus:,key-generation: -n "$0" -- "$@")
# echo ARGS=[$ARGS]
eval set -- "$ARGS"
# echo formatted parameters=[$@]

need_help=0

keygen=0
enc=0
dec=0
pub_exp=0
pri_exp=0
modulus=0

help_msg="This command is an RSA algorithm implementation written in shell script.\n
There are three modes to choose from:\n
\n
I. Key generation:\n
usage: ./rsa.sh --key-generation <1st prime number> <2nd prime number>\n
eg: ./rsa.sh --key-generation 707981 906313\n
\n
II. Encrypt mode:\n
usage: ./rsa.sh --encrypt --public-exponent <e> --modulus <n> <file>\n
eg: ./rsa.sh --encrypt --public-exponent 65537 --modulus 641652384053 testfile\n
usage: ./rsa.sh --key-generation <1st prime number> <2nd prime number> --encrypt <file>\n
eg: ./rsa.sh --key-generation 707981 906313 --encrypt testfile\n
\n
III. Decrypt mode:\n
usage: ./rsa.sh --decrypt --private-exponent <d> --modulus <n> <file>\n
eg: ./rsa.sh --decrypt --private-exponent 64657547393 --modulus 641652384053 testfile"

p=0
q=0
e=0
n=0
N=0

while true
do
    case $1 in
        -h|--help)
            need_help=1
            shift
            ;;
        --key-generation)
            keygen=1
            p=$2
            shift 2
            ;;
        --encrypt)
            enc=1
            shift
            ;;
        --decrypt)
            dec=1
            shift
            ;;
        --public-exponent)
            pub_exp=1
            e=$2
            shift 2
            ;;
        --private-exponent)
            pri_exp=1
            d=$2
            shift 2
            ;;
        --modulus)
            modulus=1
            N=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo -e $help_msg; exit 1
            ;;
    esac
done


#valid $e
#valid $N


# if contains -h
if [[ $need_help == 1 ]]; then
    echo -e $help_msg; exit 0
fi

# encrypt 
if [[ $enc == 1 ]] && [[ $dec == 0 ]] && [[ $pub_exp == 1 ]] && [[ $pri_exp == 0 ]] && [[ $keygen == 0 ]] && [[ $modulus == 1 ]]; then
    if [ ! $# -eq 1 ]; then
        echo -e $help_msg; exit 1
    fi
    file=$1
    if [[ ! -f $file ]] || [[ $(valid $e) == 0 ]] || [[ $(valid $N) == 0 ]]; then
        echo -e $help_msg; exit 1
    fi    
    if [[ ${e:0:2} == "0x" ]]; then
        e=$(echo ${e:2} | tr '[:lower:]' '[:upper:]')
        read e < <(bc <<< "obase=10; ibase=16; $e")
    fi
    if [[ ${N:0:2} == "0x" ]]; then
        N=$(echo ${N:2} | tr '[:lower:]' '[:upper:]')
        read N < <(bc <<< "obase=10; ibase=16; $N")
    fi


    mapfile -t lines < <(cat $file)
    for ((i=0;i<${#lines[@]};i++)); do
    	n=${lines[$i]}
        power $n $e $N
    done
    exit 0
fi

# decrypt
if [[ $enc == 0 ]] && [[ $dec == 1 ]] && [[ $pub_exp == 0 ]] && [[ $pri_exp == 1 ]] && [[ $keygen == 0 ]] && [[ $modulus == 1 ]]; then
    if [ ! $# -eq 1 ]; then
        echo -e $help_msg; exit 1
    fi

    file=$1
    if [[ ! -f $file ]] || [[ $(valid $d) == 0 ]] || [[ $(valid $N) == 0 ]]; then
        echo -e $help_msg; exit 1
    fi    
    if [[ ${d:0:2} == "0x" ]]; then
        d=$(echo ${d:2} | tr '[:lower:]' '[:upper:]')
        read d < <(bc <<< "obase=10; ibase=16; $d")
    fi
    if [[ ${N:0:2} == "0x" ]]; then
        N=$(echo ${N:2} | tr '[:lower:]' '[:upper:]')
        read N < <(bc <<< "obase=10; ibase=16; $N")
    fi

    mapfile -t lines < <(cat $file)
    for ((i=0;i<${#lines[@]};i++)); do
    	c=${lines[$i]}
        power $c $d $N
    done
    exit 0
fi

# keygen
if [[ $enc == 0 ]] && [[ $dec == 0 ]] && [[ $pub_exp == 0 ]] && [[ $pri_exp == 0 ]] && [[ $keygen == 1 ]] && [[ $modulus == 0 ]]; then
    if [ ! $# -eq 1 ]; then
        echo -e $help_msg; exit 1
    fi

    q=$1
    if [[ $(valid $p) == 0 ]] || [[ $(valid $q) == 0 ]]; then
        echo -e $help_msg; exit 1
    fi    
    if [[ ${p:0:2} == "0x" ]]; then
        p=$(echo ${p:2} | tr '[:lower:]' '[:upper:]')
        read p < <(bc <<< "obase=10; ibase=16; $p")
    fi
    if [[ ${q:0:2} == "0x" ]]; then
        q=$(echo ${q:2} | tr '[:lower:]' '[:upper:]')
        read q < <(bc <<< "obase=10; ibase=16; $q")
    fi

    read N < <(bc <<< "$p * $q")
    read r < <(bc <<< "($p - 1) * ($q - 1)")
    e=65537
    result=$(euc $e $r)
    a=$(echo $result | cut -d ":" -f 1)
    d=$(echo $result | cut -d ":" -f 2)
    b=$(echo $result | cut -d ":" -f 3)

    echo "Public exponent: $e"
    echo "Private exponent: $d"
    echo "Modulus: $N"

    exit 0
fi

# keygen and encrypt 
if [[ $enc == 1 ]] && [[ $dec == 0 ]] && [[ $pub_exp == 0 ]] && [[ $pri_exp == 0 ]] && [[ $keygen == 1 ]] && [[ $modulus == 0 ]]; then
    if [ ! $# -eq 2 ]; then
        echo -e $help_msg; exit 1
    fi
    q=$1
    file=$2

    if [[ ! -f $file ]]; then
        echo -e $help_msg; exit 1
    fi   

    if [[ $(valid $p) == 0 ]] || [[ $(valid $q) == 0 ]]; then
        echo -e $help_msg; exit 1
    fi    
    if [[ ${p:0:2} == "0x" ]]; then
        p=$(echo ${p:2} | tr '[:lower:]' '[:upper:]')
        read p < <(bc <<< "obase=10; ibase=16; $p")
    fi
    if [[ ${q:0:2} == "0x" ]]; then
        q=$(echo ${q:2} | tr '[:lower:]' '[:upper:]')
        read q < <(bc <<< "obase=10; ibase=16; $q")
    fi

    read N < <(bc <<< "$p * $q")
    read r < <(bc <<< "($p - 1) * ($q - 1)")
    e=65537
    result=$(euc $e $r)
    a=$(echo $result | cut -d ":" -f 1)
    d=$(echo $result | cut -d ":" -f 2)
    b=$(echo $result | cut -d ":" -f 3)

    echo "Public exponent: $e"
    echo "Private exponent: $d"
    echo "Modulus: $N"

    mapfile -t lines < <(cat $file)
    for ((i=0;i<${#lines[@]};i++)); do
    	n=${lines[$i]}
        power $n $e $N
    done
    exit 0
fi

echo -e $help_msg; exit 1
