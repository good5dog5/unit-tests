#!/usr/bin/env bash


gdbfile="_tmp.gdb"

cat <<EOF > $gdbfile
b main
r
source scripts/create_list.gdb
source scripts/printf_list.gdb
source scripts/find_node_address.gdb
set \$head = (List*)0
set \$node1 = (List*)0
set \$node2 = (List*)0
EOF

# stdin replace by $1(data-swap.in)
exec < $1

# read first line of data-swap.in, var=4
read var
echo 'create_list $head' $var >> $gdbfile

exec < $1
echo ' '>>$2
echo 'set logging file '$2 >> $gdbfile

while (read var) 
do
	read var
	node_1=$var
	read var
	node_2=$var


cat >> $gdbfile << HERE
set logging on
p "test begin"
p "old_list"
printf_list \$head
set logging off
find_node_address \$head $node_1 \$node1
find_node_address \$head $node_2 \$node2
p \$head = swap(\$head,\$node1,\$node2)
set logging on
p "change $node_1  $node_2"
p "new_list"
printf_list \$head
set logging off
HERE

done

# [-q | -quiet]  Don't print the introductory and copyright message
# [-x | -command=File] Execute GDB command from file File  
gdb -q -x _tmp.gdb bin-swap >> /dev/null
rm $gdbfile
