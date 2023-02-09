cwlVersion: v1.2
class: CommandLineTool 
id: clt_grab_yaml_contigs
doc: |
  Grabs contig information from a YAML file. This is brutally awful line parsing.
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
          var lines = inputs.file.contents.split('\n');
          var contigs = [];
          for (var i = 0; i < lines.length; i++) {
            if (!lines[i].startsWith("contig",6)) { continue; };
            var contig_name = '';
            if (lines[i].charAt(16) == ',') {
              contig_name = lines[i].substr(15,1);
            } else {
              contig_name = lines[i].substr(15,2);
            }
            contigs.push(contig_name);
          }
          return contigs;
        }
