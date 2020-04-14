#cat  9795867a-0793-4e58-b9a9-2d6ea719686c.CanFam3.1.86.lancet.snpeff.vcf | grep -v "^#" | awk '{ if ( length($5)==1 ) {print $1"\t"$2-1"\t"$2"\t"$4"\t"$5"\t"$9"\t"$10"\t"$11} else if  ( length($5)> 1 ) {print $1"\t"$2-1"\t"$2-1+length($5)"\t"$4"\t"$5"\t"$9"\t"$10"\t"$11} }' > 9795867a-0793-4e58-b9a9-2d6ea719686c.CanFam3.1.86.lancet.snpeff.bed

out=$(echo $1 | sed 's/vcf/bed/g')

cat $1 |  grep -v "^#" | awk '{ if ( length($5)==1 ) {print $1"\t"$2-1"\t"$2"\t"$4"\t"$5"\t"$8"\t"$9"\t"$10"\t"$11} else if  ( length($5)> 1 ) {print $1"\t"$2-1"\t"$2-    1+length($5)"\t"$4"\t"$5"\t"$8"\t"$9"\t"$10"\t"$11} }'  > $out


