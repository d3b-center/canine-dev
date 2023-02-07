cwlVersion: v1.2
class: CommandLineTool
id: calling_intervals_yaml_to_beds
doc: "Convert Calling Intervals YAML to interval BEDs"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'biowdl/pyyaml:latest'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing:
    - entryname: calling_intervals_yaml_to_beds.py
      writable: false
      entry:
        $include: ../scripts/calling_intervals_yaml_to_beds.py
baseCommand: [python, calling_intervals_yaml_to_beds.py]
inputs:
  input_yaml: { type: 'File', inputBinding: { position: 1 }, doc: "YAML containing calling intervals" }
  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 1
    doc: "GB size of RAM to allocate to this task."
outputs:
  outputs: 
    type: File[]
    outputBinding:
      glob: '*.bed' 
