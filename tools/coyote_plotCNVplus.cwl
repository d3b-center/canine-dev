cwlVersion: v1.2
class: CommandLineTool
id: coyote_plotCNVplus
doc: "Make plots from and optionally recenter ModelFinal SEG file"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'dmiller15/r-util:3.6.1'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing:
    - entryname: plotCNVplus_4d89cb4.R
      writable: false
      entry:
        $include: ../scripts/plotCNVplus_4d89cb4.R
baseCommand: [Rscript, plotCNVplus_4d89cb4.R]
arguments:
  - position: 2
    shellQuote: false
    prefix: "--plots"
    valueFrom: "."
  - position: 2
    shellQuote: false
    prefix: "--re_centered_seg_directory"
    valueFrom: "."
inputs:
  # Required Arguments
  sample_name: { type: 'string', inputBinding: { position: 2, prefix: "--sample"}, doc: "The title used for each plot" }
  output_basename: { type: 'string', inputBinding: { position: 2, prefix: "--output"}, doc: "Prefix for each of the plots" }
  denoised_tsv: { type: 'File', inputBinding: { position: 2, prefix: "--denoised"}, doc: ".denoisedCR.tsv output from gatk DenoiseReadCounts" }
  allelic_tsv: { type: 'File', inputBinding: { position: 2, prefix: "--allelic"}, doc: ".hets.tsv output from gatk ModelSegments" }
  modeled_seg: { type: 'File', inputBinding: { position: 2, prefix: "--modeled"}, doc: ".modelFinal.seg output from gatk ModelSegments" }

  # Optional Arguments
  contig_names_string: { type: 'string?', inputBinding: { position: 2, prefix: "--contig_names_string"}, doc: "'CONTIG_DELIMITER' seperated list of contig names to plot" }
  contig_lengths_string: { type: 'string?', inputBinding: { position: 2, prefix: "--contig_lengths_string"}, doc: "'CONTIG_DELIMITER' seperated list of contig lengths in the same order as contig_names" }
  re_center_CNA: { type: 'string?', inputBinding: { position: 2, prefix: "--re_center_CNA"}, doc: "Re-Center all copy number values based on the distribution of heterozygous Log ratio" }
  CNlossColor: { type: 'string?', inputBinding: { position: 2, prefix: "--CNlossColor"}, doc: "Color of points to use for CN losses" }
  CNgainColor: { type: 'string?', inputBinding: { position: 2, prefix: "--CNgainColor"}, doc: "Color of points to use for CN gains" }
  CNhetColor: { type: 'string?', inputBinding: { position: 2, prefix: "--CNhetColor"}, doc: "Color of points to use for hets" }
  BAFcolor: { type: 'string?', inputBinding: { position: 2, prefix: "--BAFcolor"}, doc: "Color of points to use for ALT-Alleles-Frequency" }
  SEGcolor: { type: 'string?', inputBinding: { position: 2, prefix: "--SEGcolor"}, doc: "Color of lines to denote segements" }
  CNlossLim: { type: 'float?', inputBinding: { position: 2, prefix: "--CNlossLim"}, doc: "Log2 value used to denote CN losses" }
  CNgainLim: { type: 'float?', inputBinding: { position: 2, prefix: "--CNgainLim"}, doc: "Log2 value used to denote CN gains" }
  hetDPfilter: { type: 'int?', inputBinding: { position: 2, prefix: "--hetDPfilter"}, doc: "Depth requirement to filter hets" }
  hetAFlow: { type: 'float?', inputBinding: { position: 2, prefix: "--hetAFlow"}, doc: "Min allele frequency to keep hets" }
  hetAFhigh: { type: 'float?', inputBinding: { position: 2, prefix: "--hetAFhigh"}, doc: "Max allele frequency to keep hets" }
  hetMAFposteriorOffset: { type: 'float?', inputBinding: { position: 2, prefix: "--hetMAFposteriorOffset"}, doc: "Value to be added/subtracted to MINOR_ALLELE_FRACTION_POSTERIOR_10 and MINOR_ALLELE_FRACTION_POSTERIOR_90 from modeled_segments_file for filter hets." }
  point_size: { type: 'int?', inputBinding: { position: 2, prefix: "--point_size"}, doc: "Size of points to be ploted" }
  lowerCNvalidatePeakOffset: { type: 'float?', inputBinding: { position: 2, prefix: "--lowerCNvalidatePeakOffset"}, doc: "The lower real copy number offset used for the selection of hets around a mode in the copy number density plot of hets used for validating the mode to be used for centering." }
  UpperCNvalidatePeakOffset: { type: 'float?', inputBinding: { position: 2, prefix: "--UpperCNvalidatePeakOffset"}, doc: "The upper real copy number offset used for the selection of hets around a mode in the copy number density plot of hets used for validating the mode to be used for centering." }
  lowerCNcenteringPeakOffset: { type: 'float?', inputBinding: { position: 2, prefix: "--lowerCNcenteringPeakOffset"}, doc: "The lower real copy number offset used for the selection of hets around a mode in the copy number density plot of hets used for centering of all segments." }
  UpperCNcenteringPeakOffset: { type: 'float?', inputBinding: { position: 2, prefix: "--UpperCNcenteringPeakOffset"}, doc: "The upper real copy number offset used for the selection of hets around a mode in the copy number density plot of hets used for centering of all segments." }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 16
    doc: "GB size of RAM to allocate to this task."
outputs:
  plots: 
    type: 'File[]'
    outputBinding:
      glob: '*.png' 
  recentered_seg:
    type: 'File?'
    outputBinding:
      glob: '*.re_centered.cr.igv.seg'
  dlrs:
    type: 'File?'
    outputBinding:
      glob: '*dLRs.tsv'
