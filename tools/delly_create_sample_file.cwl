cwlVersion: v1.2
id: delly_create_sample_file 
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
      echo -e "$(inputs.tumor_sample_name.split('.')[0])\ttumor\n$(inputs.normal_sample_name.split('.')[0])\tcontrol" > sample.tsv
inputs:
  normal_sample_name: { type: 'string', doc: "Name of the normal sample" }
  tumor_sample_name: { type: 'string', doc: "Name of the tumor sample" } 

outputs:
  output:
    type: File
    outputBinding:
      glob: sample.tsv
