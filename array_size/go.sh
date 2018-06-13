#!/bin/bash

rm -f *.cocci order.txt

first=
# Functions that have full set of 2-factor size arguments
for i in 2arg*.template ; do
while read name alloc calloc ; do
	# Remove the HANDLE expression lines if unused.
	if ! echo "$alloc" | fgrep -q HANDLE ; then
		ignore='expression HANDLE'
		replace=HANDLE,
	else
		ignore=KEEP_EVERYTHING
		replace=REPLACE_NOTHING
		alloc=$(echo "$alloc" | cut -d'(' -f1)
		calloc=$(echo "$calloc" | cut -d'(' -f1)
	fi

	out=$(echo "$i" | sed -e 's/\.template$//')
	grep -v "$ignore" $i | \
		sed -e 's/('"$replace"' */(/g;' \
		    -e 's/%alloc%/'"$alloc"'/g;' \
		    -e 's/%calloc%/'"$calloc"'/g;' \
			> "$out"."$name".cocci

	#cat "$out"."$name".cocci <(echo "") >> array_size.cocci
	cat "$out"."$name".cocci <(echo "") >> "$name".cocci
	rm  "$out"."$name".cocci
	if [ -z "$first" ] ; then
		echo "$name" >> order.txt
	fi
done <<EOM
kmalloc		kmalloc			kmalloc_array
kzalloc		kzalloc			kcalloc
kmalloc_node	kmalloc_node		kmalloc_array_node
kzalloc_node	kzalloc_node		kcalloc_node
kvmalloc	kvmalloc		kvmalloc_array
kvzalloc	kvzalloc		kvcalloc
devm_kmalloc	devm_kmalloc(HANDLE,	devm_kmalloc_array(HANDLE,
devm_kzalloc	devm_kzalloc(HANDLE,	devm_kcalloc(HANDLE,
EOM
	first=n
done

first=
# Functions that only take a single size argument
for i in 1arg*.template ; do
while read name alloc ; do
	# Remove the HANDLE expression lines if unused.
	if ! echo "$alloc" | fgrep -q HANDLE ; then
		ignore='expression HANDLE'
		replace=HANDLE,
	else
		ignore=KEEP_EVERYTHING
		replace=REPLACE_NOTHING
		alloc=$(echo "$alloc" | cut -d'(' -f1)
	fi

	out=$(echo "$i" | sed -e 's/\.template$//')
	grep -v "$ignore" $i | \
		sed -e 's/('"$replace"' */(/g;' \
		    -e 's/%alloc%/'"$alloc"'/g;' \
			> "$out"."$name".cocci

	#cat "$out"."$name".cocci <(echo "") >> array_size.cocci
	cat "$out"."$name".cocci <(echo "") >> "$name".cocci
	rm  "$out"."$name".cocci
	if [ -z "$first" ] ; then
		echo "$name" >> order.txt
	fi
done <<EOM
vmalloc		vmalloc
vzalloc		vzalloc
vmalloc_node	vmalloc_node
vzalloc_node	vzalloc_node
kvmalloc_node	kvmalloc_node
kvzalloc_node	kvzalloc_node
sock_kmalloc	sock_kmalloc(HANDLE,
f2fs_kmalloc	f2fs_kmalloc(HANDLE,
f2fs_kzalloc	f2fs_kzalloc(HANDLE,
f2fs_kvmalloc	f2fs_kvmalloc(HANDLE,
f2fs_kvzalloc	f2fs_kvzalloc(HANDLE,
EOM
	first=n
done
