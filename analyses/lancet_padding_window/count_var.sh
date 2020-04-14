# This  file reads in a file that has Sample, BED file name and padding length
# It prints out the number of  variants and also locations of varinats  that are missing compared to 300-600 padding length 


while read sample vcf padding;
do 
  if [ $padding == "300-600" ]; then
    #first_var_missing=$(bedtools intersect -a $vcf -b $second -v | cut -f6 | cut  -d "|" -f2  | sort | uniq -c)
    echo "300-600\t"$sample"\t"$(< "$vcf" wc -l)
    firstvcf=$vcf
  elif [ $padding == "200-400" ]; then
    second_var_missing=$(bedtools intersect -a $firstvcf -b $vcf  -v | cut -f6 | cut  -d "|" -f2  | sort | uniq -c)
    echo "200-400\t"$sample"\t"$(< "$vcf" wc -l)"\t"$second_var_missing
  elif [ $padding == "150-300" ]; then
    third_var_missing=$(bedtools intersect -a $firstvcf -b $vcf  -v | cut -f6 | cut  -d "|" -f2  | sort | uniq -c)
    echo "150-300\t"$sample"\t"$(< "$vcf" wc -l)"\t"$third_var_missing
  elif [ $padding == "75-150" ]; then
    fourth_var_missing=$(bedtools intersect -a $firstvcf -b $vcf  -v | cut -f6 | cut  -d "|" -f2  | sort | uniq -c)
    echo "75-150\t"$sample"\t"$(< "$vcf" wc -l)"\t"$fourth_var_missing
  fi  
done < $1



