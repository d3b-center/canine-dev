cwlVersion: v1.2
class: CommandLineTool
id: thred 
doc: |
  TGEN tHRed Program 
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dmiller15/thred:1.1.0'
baseCommand: [python, /opt/thred/tHReD.py]
inputs:
  seg: { type: 'File', inputBinding: { position: 2, prefix: "--seg"}, doc: "SEG file with non-overlapping segments (default: None)" }
  genomic_regions: { type: 'File', inputBinding: { position: 2, prefix: "--genomic-regions"}, doc: "Genomic Regions File defining Centromere (required) and optionally telomeres, p and q arms. NOTE: defined regions MUST not overlap (default: None)" }

  
  outfile: { type: 'string?', inputBinding: { position: 2, prefix: "--outfile"}, doc: "output file where the score HRD will be saved into; Can be rlative or full path (default: hrd_scores.txt)" }
  th_log2r: { type: 'float?', inputBinding: { position: 2, prefix: "--th-log2r"}, doc: "log2R Threshold value for considering a Deletion (default: -0.1613)" }
  minsize: { type: 'int?', inputBinding: { position: 2, prefix: "--minsize"}, doc: "Minimum size region for a Segment to be considered into HRD score (default: 1000000)" }
  th_pct_overlapping: { type: 'float?', inputBinding: { position: 2, prefix: "--th-pct-overlapping"}, doc: "Percentage of overlapping between arm and sum of segements with deletions [allow to exclude deletion being an entire arm for instance ] (default: 0.9)" }
  contigs: { type: 'string?', inputBinding: { position: 2, prefix: "--contigs"}, doc: "comma-separated list of contigs to use with the HRD score; Contigs Must Exist in Seg file and Genomic Region file; If None, list will be captured from SEG file (default: .)" }
  sample: { type: 'string?', inputBinding: { position: 2, prefix: "--sample"}, doc: "Sample Name to add to the results output table (default: .)" }
  id: { type: 'string?', inputBinding: { position: 2, prefix: "--id"}, doc: "Kit Code or Any ID you want to add to the results output table (default: .)" }
  exclude_contigs: { type: 'string?', inputBinding: { position: 2, prefix: "--exclude-contigs"}, doc: "comma-separated list of contigs to exclude from HRD scores ; default is 'chrX,chrY,chrM' (default: chrX,chrY,chrM)" }
  karyo_file: { type: 'File?', inputBinding: { position: 2, prefix: "--karyo-file"}, doc: "Cytoband Information of the Genome [UCSC --> table_browser --> Sequence & Mapping --> Chromosome Band --> allFieldsFromSelectedtable --> getOuput button ; default is karyo_file = 'examples/inputs/grch38_ucsc_cytobands.bed' (default: /opt/thred/examples/inputs/grch38_ucsc_cytobands.bed)" }
  plots: { type: 'boolean?', inputBinding: { position: 2, prefix: "--plots"}, doc: "by default no plot will be created ; use --plots to enabled making plots (default: False)" }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      prefix: "--threads"
      position: 2 
  ram:
    type: 'int?'
    default: 2
    doc: "GB size of RAM to allocate to this task."
outputs:
  hrd_scores:
    type: 'File'
    outputBinding:
      glob: "*_hrd_scores.txt"
  hrd_flt_segments:
    type: 'File'
    outputBinding:
      glob: "*_hrd_flt_segments.txt"
  hrd_ori_segments:
    type: 'File'
    outputBinding:
      glob: "*_hrd_ori_segments.txt"
  excluded90_hrd_excluded_segments:
    type: 'File'
    outputBinding:
      glob: "*_excluded90_hrd_excluded_segments.txt"
  hrd_captured_genome_territory:
    type: 'File'
    outputBinding:
      glob: "*_hrd_captured_genome_territory.txt"
  original_segments_karyoplot_1:
    type: 'File?'
    outputBinding:
      glob: "*_original_segments_karyoplot_1.png"
  original_segments_karyoplot_2:
    type: 'File?'
    outputBinding:
      glob: "*_original_segments_karyoplot_2.png"
  segments_filtered_karyoplot_1:
    type: 'File?'
    outputBinding:
      glob: "*_segments_filtered_karyoplot_1.png"
  segments_filtered_karyoplot_2:
    type: 'File?'
    outputBinding:
      glob: "*_segments_filtered_karyoplot_2.png"
  segments_excluded_karyoplot_1:
    type: 'File?'
    outputBinding:
      glob: "*_segments_excluded_karyoplot_1.png"
  segments_excluded_karyoplot_2:
    type: 'File?'
    outputBinding:
      glob: "*_segments_excluded_karyoplot_2.png"
