cwlVersion: v1.2
class: CommandLineTool 
id: clt_pick_interval
doc: |
  Pick the right interval list 
requirements:
  - class: InlineJavascriptRequirement
baseCommand: [echo]
inputs:
  exome_male: { type: 'File?' }
  exome_female: { type: 'File?' }
  genome_male: { type: 'File?' }
  genome_female: { type: 'File?' }
  exome: { type: "boolean", doc: "Pick exome?" }
  female: { type: "boolean", doc: "Pick female?" }
outputs:
  output:
    type: 'File?'
    outputBinding:
      outputEval: |
        ${
          var outfile = null;
          if (inputs.exome) {
            if (inputs.female) {
              outfile = inputs.exome_female;
            } else {
              outfile = inputs.exome_male;
            }
          } else {
            if (inputs.female) {
              outfile = inputs.genome_female;
            } else {
              outfile = inputs.genome_male;
            }
          } 
          return outfile;
        }
