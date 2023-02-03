cwlVersion: v1.2
class: CommandLineTool 
id: clt_grab_contigs_from_json
doc: |
  Grabs contigs from a JSON input.
requirements:
  - class: InlineJavascriptRequirement
baseCommand: [echo]
inputs:
  file: 
    type: File 
    loadContents: true
outputs:
  output:
    type: string[]
    outputBinding:
      outputEval: |
        ${
          var contentObj = JSON.parse(inputs.file.contents);
          var contigs = [];
          var primary_contigs = contentObj.primary_calling_contigs.map(function(e) { return e.contig.toString() })
          return primary_contigs;
        }
