cwlVersion: v1.2
class: Workflow
id: canine_add_matched_rna
doc: "Port of Canine RNA Variant Check: add_matched_rna Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  reference_dict: { type: 'File', doc: "DICT file for reference fasta" }
  reference_fasta: { type: 'File', secondaryFiles: [{ pattern: '.fai', required: true }], doc: "Reference fasta and fai index" }
  input_vcf: { type: 'File', doc: "VCF file to which RNA headers." }
  star_bam_final: { type: 'File', doc: "STAR BAM final" }
  output_filename: { type: 'string', doc: "Name for final output VCF." }
  rna_samplename: { type: 'string', doc: "Name of RNA sample associated with tumor pair" }

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }
  freebayes_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Freebayes." }
  freebayes_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Freebayes." }

outputs:
  matched_rna_vcf: { type: 'File', outputSource: bcftools_index_csi/output }

steps:
  coyote_dict_contig_lengths:
    run: ../tools/coyote_dict_contig_lengths.cwl
    in:
      reference_dict: reference_dict 
    out: [output]

  bcftools_query_varpos:
    run: ../tools/bcftools_query.cwl
    in:
      input_vcfs:
        source: input_vcf 
        valueFrom: $([self])
      format:
        valueFrom: "%CHROM\t%POS0\t%END\n"
      output_filename:
        valueFrom: "temp_variant_pos.bed"
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output] 
  
  bedtools_slop:
    run: ../tools/bedtools_slop.cwl
    in:
      input_file: bcftools_query_varpos/output 
      output_filename:
        valueFrom: "temp_intervals.bed"
      genome: coyote_dict_contig_lengths/output
      left:
        valueFrom: $(100)
      right:
        valueFrom: $(100)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]
  
  bedtools_merge:
    run: ../tools/bedtools_merge.cwl
    in:
      input_file: bedtools_slop/output
      output_filename:
        valueFrom: "temp_target_intervals.bed"
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]
  
  freebayes:
    run: ../tools/freebayes.cwl 
    in:
      input_bams:
        source: star_bam_final
        valueFrom: $([self]) 
      reference_fasta: reference_fasta
      targets_file: bedtools_merge/output
      variant_input_file: input_vcf
      only_use_input_alleles:
        valueFrom: $(1 == 1)
      min_alternate_count:
        valueFrom: $(1)
      min_alternate_fraction:
        valueFrom: $(0.0001)
      output_filename: 
        source: rna_samplename
        valueFrom: $(self)_DnaVarInRNA_norm.vcf
      ram: freebayes_ram
      cpu: freebayes_cpu
    out: [output]
  
  bcftools_norm_filter_index:
    run: ../tools/bcftools_norm_filter_index.cwl
    in:
      input_vcf: freebayes/output
      output_filename:
        source: rna_samplename
        valueFrom: $(self)_DnaVarInRNA_norm.vcf.gz 
      check_ref:
        valueFrom: "s"
      fasta_ref: reference_fasta
      multiallelics:
        valueFrom: "-any"
      exclude:
        valueFrom: "N_ALT==0"
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]
  
  bcftools_annotate_view_index:
    run: ../tools/bcftools_annotate_view_index.cwl
    in:
      input_vcf: input_vcf
      output_filename:
        valueFrom: "temp_DNA.vcf.gz"
      remove:
        valueFrom: "INFO,FORMAT"
      drop_genotypes:
        valueFrom: $(1 == 1)
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]
  
  bcftools_merge:
    run: ../tools/bcftools_merge.cwl
    in:
      input_vcfs:
        source: [bcftools_annotate_view_index/output,bcftools_norm_filter_index/output]
      output_filename:
        valueFrom: "merged_RNA.vcf.gz"
      missing_to_ref:
        valueFrom: $(1 == 1)
      output_type:
        valueFrom: "z"
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]
  
  coyote_temp_rna_header2:
    run: ../tools/coyote_temp_rna_header2.cwl
    in: []
    out: [output]

  bcftools_query_counts:
    run: ../tools/bcftools_query.cwl
    in:
      input_vcfs:
        source: bcftools_merge/output
        valueFrom: $([self])
      output_filename:
        valueFrom: "temp_RNA_Counts.txt"
      format:
        valueFrom: "%CHROM\t%POS\t%REF\t%ALT\t[ %AD{0}]\t[ %AD{1}]\n"
    out: [output]
  
  coyote_temp_rna_vcf:
    run: ../tools/coyote_temp_rna_vcf.cwl
    in:
      input_counts: bcftools_query_counts/output
      input_header: coyote_temp_rna_header2/output
    out: [output]
  
  bcftools_view_index:
    run: ../tools/bcftools_view_index.cwl 
    in:
      input_vcf: coyote_temp_rna_vcf/output
      output_filename:
        valueFrom: "temp_RNA.vcf.gz"
      output_type:
        valueFrom: "z"
      force:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bcftools_annotate_index:
    run: ../tools/bcftools_annotate_index.cwl
    in:
      input_vcf: input_vcf
      output_filename: output_filename
      annotations: bcftools_view_index/output
      columns:
        valueFrom: "INFO"
      output_type:
        valueFrom: "z"
      tbi:
        valueFrom: $(1 == 1)
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  bcftools_index_csi:
    run: ../tools/bcftools_index.cwl
    in:
      input_vcf: bcftools_annotate_index/output
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

$namespaces:
  sbg: https://sevenbridges.com

hints:
- class: "sbg:maxNumberOfParallelInstances"
  value: 2
