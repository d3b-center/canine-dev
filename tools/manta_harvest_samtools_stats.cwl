cwlVersion: v1.2
id: manta_harvest_samtools_stats 
requirements:
  - class: DockerRequirement
    dockerPull: 'ubuntu:20.04'
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 1000 
    coresMin: 1
class: CommandLineTool
baseCommand: [/bin/bash, -c]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: | 
      cat $(inputs.samtools_stats.path) | tail -n 1 > stats.tsv 
inputs:
  samtools_stats: { type: 'File', doc: "TSV file containing samtools stats insertSize summary information" }

outputs:
  insert_size:
    type: int 
    outputBinding:
      glob: stats.tsv
      loadContents: true
      outputEval: $(self[0].contents.split('\t')[9])
  std_is:
    type: float
    outputBinding:
      glob: stats.tsv
      loadContents: true
      outputEval: $(self[0].contents.split('\t')[11])
