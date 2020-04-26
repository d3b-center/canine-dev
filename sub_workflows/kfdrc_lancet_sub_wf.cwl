class: Workflow
cwlVersion: v1.0
id: kfdrc_lancet_sub_wf
doc: 'Lancet sub workflow, meant to be wrapped'
$namespaces:
  sbg: 'https://sevenbridges.com'
inputs:
  - id: bed_invtl_split
    type: 'File[]'
    doc: Bed file intervals passed on from and outside pre-processing step
    'sbg:x': 0
    'sbg:y': 1070
  - id: indexed_reference_fasta
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
    'sbg:x': 0
    'sbg:y': 963
  - id: input_normal_aligned
    type: File
    secondaryFiles:
      - ^.bai
    'sbg:x': 0
    'sbg:y': 856
  - id: input_tumor_aligned
    type: File
    secondaryFiles:
      - ^.bai
    'sbg:x': 0
    'sbg:y': 749
  - id: output_basename
    type: string
    'sbg:x': 247.328125
    'sbg:y': 486
  - id: padding
    type: int
    doc: 'If WGS (less likely), default 25, if exome+, recommend half window size'
    'sbg:x': 0
    'sbg:y': 642
  - id: ram
    type: int?
    doc: Adjust in rare circumstances in which 12 GB is not enough.
    default: 12
    'sbg:x': 0
    'sbg:y': 535
  - id: reference_dict
    type: File
    'sbg:x': 247.328125
    'sbg:y': 379
  - id: reference_gzipped
    type: File
    doc: Fasta genome assembly with indexes
    secondaryFiles:
      - .fai
      - .gzi
    'sbg:x': 862.4901123046875
    'sbg:y': 414
  - id: select_vars_mode
    type:
      - 'null'
      - type: enum
        symbols:
          - gatk
          - grep
        name: select_vars_mode
    doc: 'Choose ''gatk'' for SelectVariants tool, or ''grep'' for grep expression'
    default: gatk
    'sbg:x': 0
    'sbg:y': 428
  - id: vep_assembly
    type: string
    doc: 'Type of reference  assembly used. Ex: CanFam3.1 for canine'
    'sbg:x': 0
    'sbg:y': 321
  - id: vep_cache
    type: File
    doc: tar gzipped cache from ensembl/local converted cache
    'sbg:x': 0
    'sbg:y': 214
  - id: vep_cache_version
    type: string
    doc: 'Version of ensembl cache file, Ex: 99, 98'
    'sbg:x': 0
    'sbg:y': 107
  - id: window
    type: int
    doc: >-
      window size for lancet.  default is 600, recommend 500 for WGS, 600 for
      exome+
    'sbg:x': 0
    'sbg:y': 0
outputs:
  - id: lancet_pass_vcf
    outputSource:
      - gatk_selectvariants_lancet/pass_vcf
    type: File
    'sbg:x': 1134.7332763671875
    'sbg:y': 646.1961059570312
  - id: lancet_prepass_vcf
    outputSource:
      - sort_merge_lancet_vcf/merged_vcf
    type: File
    'sbg:x': 804.7940063476562
    'sbg:y': 532.5392456054688
  - id: lancet_vep_vcf
    outputSource:
      - vep_annot_lancet/output_vcf
    type: File
    'sbg:x': 1414.071044921875
    'sbg:y': 494.61273193359375
steps:
  - id: gatk_selectvariants_lancet
    in:
      - id: input_vcf
        source: sort_merge_lancet_vcf/merged_vcf
      - id: mode
        source: select_vars_mode
      - id: output_basename
        source: output_basename
      - id: tool_name
        valueFrom: '${return "lancet"}'
    out:
      - id: pass_vcf
    run: ../tools/gatk_selectvariants.cwl
    label: GATK Select Lancet PASS
    'sbg:x': 862.4901123046875
    'sbg:y': 642
  - id: lancet
    in:
      - id: bed
        source: bed_invtl_split
      - id: input_normal_bam
        source: input_normal_aligned
      - id: input_tumor_bam
        source: input_tumor_aligned
      - id: output_basename
        source: output_basename
      - id: padding
        source: padding
      - id: ram
        source: ram
      - id: reference
        source: indexed_reference_fasta
      - id: window
        source: window
    out:
      - id: lancet_vcf
    run: ../tools/lancet.cwl
    scatter:
      - bed
    'sbg:x': 247.328125
    'sbg:y': 642
  - id: sort_merge_lancet_vcf
    in:
      - id: input_vcfs
        source:
          - lancet/lancet_vcf
      - id: output_basename
        source: output_basename
      - id: reference_dict
        source: reference_dict
      - id: tool_name
        valueFrom: '${return "lancet"}'
    out:
      - id: merged_vcf
    run: ../tools/gatk_sortvcf.cwl
    label: GATK Sort & Merge lancet
    'sbg:x': 585.2869873046875
    'sbg:y': 521
  - id: vep_annot_lancet
    in:
      - id: assembly
        source: vep_assembly
      - id: cache
        source: vep_cache
      - id: cache_version
        source: vep_cache_version
      - id: input_vcf
        source: gatk_selectvariants_lancet/pass_vcf
      - id: output_basename
        source: output_basename
      - id: reference_gzipped
        source: reference_gzipped
      - id: species
        valueFrom: '${return "canis_familiaris"}'
      - id: tool_name
        valueFrom: '${return "lancet"}'
    out:
      - id: output_html
      - id: output_vcf
      - id: warn_txt
    run: ../tools/vep_annotate.cwl
    label: VEP
    'sbg:x': 1115.501220703125
    'sbg:y': 446.5
requirements:
  - class: ScatterFeatureRequirement
