#!/bin/bash

sourcefile=$1
outfile="reload.xml"

echo "<code>" > "$outfile"
echo "<![CDATA[" >> "$outfile"
cat "$sourcefile" >> "$outfile"
echo "]]>" >> "$outfile"
echo "</code>" >> "$outfile"
