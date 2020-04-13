
#cat $vcf | cut -f6 | cut -d "|" -f2

while read vcf padding;
do 
  if [ $padding == "consensus" ]; then
    consensus=$vcf
  elif [ $padding == "300-600" ]; then
    first=$vcf
  elif [ $padding == "200-400" ]; then
    second=$vcf
  elif [ $padding == "150-300" ]; then
    third=$vcf
  elif [ $padding == "75-150" ]; then
    fourth=$vcf
  fi
done < $1

#goldenset = wc -l $first
#read  -d '' VAR << bedtools intersect -a $first -b $second -v | cut -f6 | cut  -d "|" -f2  | sort | uniq -c 

MYVAR=$(bedtools intersect -a $first -b $second -v | cut -f6 | cut  -d "|" -f2  | sort | uniq -c)

#while read line; 
#do 
#  echo "'${line}'"; 
#done <<< "$MYVAR"

second_var_missing=$(bedtools intersect -a $first -b $second -v | cut -f6 | cut  -d "|" -f2  | sort | uniq -c)

echo "PAdding num\t Numofvar\tVarmissing"
echo "300-600\t"$(< "$first" wc -l)
echo "200-400\t"$(< "$second" wc -l)"\t"$second_var_missing
echo "150-300\t"$(< "$third" wc -l)
echo "75-150\t"$(< "$fourth" wc -l)



