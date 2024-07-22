cwlVersion: v1.2
id: manta_harvest_insertsize
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
      cat $(inputs.insert_stats.path) | tail -n 1 > stats.tsv 
inputs:
  insert_stats: { type: 'File', doc: "TSV file containing TGEN stats insertSize summary information" }

outputs:
  insert_size:
    type: float 
    outputBinding:
      glob: stats.tsv
      loadContents: true
      outputEval: $(parseFloat(self[0].contents.split('\t')[8]))
  std_is:
    type: float
    outputBinding:
      glob: stats.tsv
      loadContents: true
      outputEval: $(parseFloat(self[0].contents.split('\t')[10]))
