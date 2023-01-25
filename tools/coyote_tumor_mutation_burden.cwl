cwlVersion: v1.2
class: CommandLineTool
id: coyote_tumor_mutation_burden
doc: "Custom TMB tool for Coyote"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'ghcr.io/tgen/jetstream_containers/mutation-burden:1.2.3'
baseCommand: [tgen_mutation_burden.sh]
arguments:
  - position: 99
    prefix: ''
    shellQuote: false
    valueFrom: |
      1>&2
inputs:
  # Required Arguments
  bed: { type: 'File', inputBinding: { position: 2, prefix: "--bed" }, doc: "BED file representing the TARGETS Regions" }
  vcf: { type: 'File', inputBinding: { position: 2, prefix: "--vcf" }, doc: "VCF file with somatic variants" }
  nbam: { type: 'File', inputBinding: { position: 2, prefix: "--nbam" }, doc: "Constitutional or Normal BAM file" }
  tbam: { type: 'File', inputBinding: { position: 2, prefix: "--tbam" }, doc: "Case or Tumor BAM file" }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--outfile" }, doc: "Name for output file" }

  # Optional Arguments
  mindepth: { type: 'int?', inputBinding: { position: 2, prefix: "--mindepth"}, doc: "Minimum read depth for both BAMS at each positions --> Callable Space [O, Default value is 10]" }
  min_read_per_strand: { type: 'int?', inputBinding: { position: 2, prefix: "--min-read-per-strand"}, doc: "Minimum read depth for each Strand for Case/Tumor BAM at each positions [O, Default value is 1]" }
  min_base_qual: { type: 'int?', inputBinding: { position: 2, prefix: "--min-base-qual"}, doc: "Minimum base quality to keep the read in samtools depth cmd [O, Default value is 5]" }
  min_map_qual: { type: 'int?', inputBinding: { position: 2, prefix: "--min-map-qual"}, doc: "Minimum Mapping quality to keep the read in samtools view cmd [O, Default value is 5]" }
  outprefix: { type: 'string?', inputBinding: { position: 2, prefix: "--outprefix"}, doc: "Provide a prefix name to default output filenames [O, default is NULL]" }
  pqarms: { type: 'File?', inputBinding: { position: 2, prefix: "--pqarms"}, doc: "provide a 2-columns FILE with column 1 as the coordinates (1:0-121535434) of the arms and the column 2 as the name of the arms (such as p or q); see file examples; WARNING: if you have lots of small regions in that file, the plot will be very long to make and may be not easy to read or not well formatted; The plot has been optimized for regions similar to regions of p and q arms chromosomes in size; up to 5 regions per chromosome might be the maximum for good plot read" }
  keep_unflt_outfile: { type: 'boolean?', inputBinding: { position: 2, prefix: "--keep-unflt-outfile"}, doc: "[O, Default is 'no' ]" }
  skip: { type: 'boolean?', inputBinding: { position: 2, prefix: "--skip"}, doc: "This option is only used when --pqarms is provided and the user does not want to get a plot with ALL the regions given; Note; For each region given, a bar will exist in plot; so if you have thousands of region in BED file, you will get thousands of bar in the plot which may take a while to make; If used, then you may consider this as running in the regions in parallel without getting the plot at the end" }
  samtools_depth_only: { type: 'boolean?', inputBinding: { position: 2, prefix: "--samtools-depth-only"}, doc: "Advanced_users_Only; It defies the purpose of this tool as it skips the calculation of the 'Mutation Burden' and only runs the 'samtools depth' commands" }
  force: { type: 'boolean?', inputBinding: { position: 2, prefix: "--force"}, doc: "If the contigs between the two bam files do not perfectly match both at the name and size levels, the script will stop; use this option to force the run knowing that might generate wrong calculi. Use at your own risk unless you are sure that the contigs difference will not impact the Mutation Burden calculation, such as the difference may be in alternate contigs not present in the VCF; [O, Default is 'no']" }
  sample: { type: 'string?', inputBinding: { position: 2, prefix: "--sample"}, doc: "Name of sample as presented in the tumor BAM read group." }
  library: { type: 'string?', inputBinding: { position: 2, prefix: "--library"}, doc: "Name of the library as presented in the tumor BAM read group." }
  rg: { type: 'string?', inputBinding: { position: 2, prefix: "--rg"}, doc: "Read group name as presented in the tumor BAM read group." }

  # Advanced Arguments
  region: { type: 'string?', inputBinding: { position: 2, prefix: "--region"}, doc: "You may provide a region formatted as follow 1:100000-200000 ; coordinates value are inclusive here; this will speed up the output while testing if you modified the current script ; the region will only be used with the samtools view to limit the searching region space in bams ; the BED file is still mandatory when using this option ; also help for DEBUGGING by reducing the space;" }
  region_name: { type: 'string?', inputBinding: { position: 2, prefix: "--region-name"}, doc: "Only used if --pqarms is provided ; For Internal usage when recursive call made [O, Default is NULL]" }
  do_not_add_dbsnp_pct_to_plot: { type: 'boolean?', inputBinding: { position: 2, prefix: "--do-not-add-dbsnp-pct-to-plot"}, doc: "enable plotting the percentage percentage of dbsnp in given regions ; required --pqarms option with a 3-column file provided to --pqarms option" }
  flag_dbsnp: { type: 'string?', inputBinding: { position: 2, prefix: "--flag-dbsnp"}, doc: "Default value hardcoded is 'RS' which means that we count the RSID present in column three (3) of the VCF; if vcf is annotated with another flag for knowing if variant is present or not in DBSNP, please provide the FLAG This Flag should be defined in INFO column; (if not ask for updating the script by creating an issue in github); Example --flag-dbsnp DBSNP152 [O, default is RS ]" }
  gnu_parallel_jobs: { type: 'int?', inputBinding: { position: 2, prefix: "--gnu-parallel-jobs"}, doc: "This is for more advance users; this option will require LOTS of CPUS available if value if greater than 1 ; see README to learn about how many cpus total will be require [O, Default is 1 ]" }
  verbose: { type: 'boolean?', inputBinding: { position: 2, prefix: "--verbose"}, doc: "For DEBUGGING purposes; print to sdtout the content of the stats outfile [O, Default is 'no']" }
  pipeline: { type: 'boolean?', inputBinding: { position: 2, prefix: "--pipeline" }, doc: "Set to true if using as part of TGEN pipeline" }

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 8
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: 'File'
    outputBinding:
      glob: $(inputs.output_filename) 
