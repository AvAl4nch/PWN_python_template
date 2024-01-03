#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file_name> <binary_name>"
    exit 1
fi

file_name="$1"
binary_name="$2"

if [[ ! $file_name =~ \.py$ ]]; then
    file_name="${file_name}.py"
fi

# for customizations change this 
# ----------------------------------------------------------------------
cat <<EOL > "$file_name"
from pwn import *

binary_name = "$binary_name"
context.binary = binary = ELF('./$binary_name', checksec=False)
context.log_level = 'debug'

libc = ELF('/lib/x86_64-linux-gnu/libc.so.6', checksec=False)
libc_gets = libc.sym.gets

rop = ROP(binary)
ret_gad = p64(rop.find_gadget(['ret'])[0])

p = process('./$binary_name')
# p = remote("10.10.254.3", 9009)


p.interactive()
EOL
# ----------------------------------------------------------------------

echo "Python script created successfully in $file_name"
