#!/bin/bash

BASE=$(dirname $0)
SCRIPTS="$BASE"/../scripts/
OUT=$(mktemp -d array_size-XXXXXX)

# Unfortunately, "make coccicheck MODE=patch COCCI=path/to/our.cocci" can't
# be used because it interleaves the patch output. Instead, use the wrapper
# "super-spatch" to merge the output.
#
# The arguments are Linux Makefile-specific, so this attempts to extract
# the desired arguments from the execution error message.
ARGS=$(make coccicheck V=1 MODE=patch COCCI=/dev/null 2>&1 | \
	grep ^Running | \
	awk -F"/usr/bin/spatch " '{print $2}' | \
	sed	\
		-e 's/-D patch //' \
		-e 's/--cocci-file \/dev\/null //' \
		-e 's/--dir \. //' \
		-e 's/--jobs [0-9]*//' \
		-e 's/--chunksize [0-9]*//' \
	)

#
# Ignore changes in the tools/ subdirectory via filterdiff.

for i in $(cat "$BASE"/order.txt); do
	echo $i
	$SCRIPTS/super-spatch \
		$ARGS \
		--cocci-file $BASE/$i.cocci \
		--dir . \
		2>"$OUT"/$i.err | filterdiff -p1 -x 'tools/*' . | \
		tee "$OUT"/$i.patch
	grep -v 'files match' "$OUT"/$i.err
	if [ -s "$OUT"/$i.patch ]; then
		patch -p1 < "$OUT"/$i.patch
		git commit -asm $i
	fi
done
rm -rf "$OUT"
