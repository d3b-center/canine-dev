cwlVersion: v1.2
class: CommandLineTool
id: coyote_addRC_to_delly_vcf 
doc: "Fixes formatting in the Delly VCF"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'dmiller15/delly:0.7.6'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing:
    - entryname: addRC_to_Delly_VCF_f4d178e.py 
      writable: false
      entry:
        $include: ../scripts/addRC_to_Delly_VCF_f4d178e.py
    - entryname: coyote_addRC_to_delly_vcf.sh
      writable: false
      entry:
        $include: ../scripts/coyote_addRC_to_delly_vcf.sh
baseCommand: [/bin/bash, coyote_addRC_to_delly_vcf.sh]
arguments:
  - position: 1
    valueFrom: |
      addRC_to_Delly_VCF_f4d178e.py
inputs:
  input_vcf: { type: 'File', inputBinding: { position: 2 }, doc: "Pass VCF from Delly" }
  input_tumor_bam: { type: 'File', inputBinding: { position: 3 }, doc: "Tumor BAM used to generate the VCF" }
  input_normal_bam: { type: 'File', inputBinding: { position: 4 }, doc: "Normal BAM used to generate the VCF" }
  slop: { type: 'int', inputBinding: { position: 5 }, doc: "Idk what this is" }

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 16
    doc: "GB size of RAM to allocate to this task."
outputs:
  output: 
    type: File
    outputBinding:
      glob: '*mod_addDist.vcf' 
