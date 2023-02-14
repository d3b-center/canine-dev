cwlVersion: v1.2
class: CommandLineTool
id: sigprofiler
doc: "Custom sigprofiler tool for Coyote"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dmiller15/sigprofiler:1.1'
  - class: LoadListingRequirement
    loadListing: deep_listing
  - class: InitialWorkDirRequirement
    listing:
    - entryname: sigprofiler_d78cc9e.py 
      writable: false
      entry:
        $include: ../scripts/sigprofiler_d78cc9e.py
    - entryname: invcfs
      writable: true
      entry: |
        $({ class: "Directory", listing: inputs.input_vcfs })
baseCommand: [python, sigprofiler_d78cc9e.py]
arguments:
  - position: 2
    prefix: '--vcfpath'
    shellQuote: false
    valueFrom: |
      invcfs
  - position: 10
    prefix: "&&"
    shellQuote: false
    valueFrom:
      tar -czf extraneous_results.tar.gz \$(ls -d */)
inputs:
  input_vcfs: { type: 'File[]', doc: "vcf file(s)" }
  genome: { type: 'string?', inputBinding: { position: 2, prefix: "--genome"}, doc: "Optional definition of genome, defaults to GRCh38" }
  project: { type: 'string?', inputBinding: { position: 2, prefix: "--project"}, doc: "Name of the project" }
  exome: { type: 'boolean?', inputBinding: { position: 2, prefix: "--exome"}, doc: "Set if input is from exome" }
  matrix_only: { type: 'boolean?', inputBinding: { position: 2, prefix: "--matrix_only"}, doc: "Stop after mutational matrix generation" }
  extract_only: { type: 'boolean?', inputBinding: { position: 2, prefix: "--extract_only"}, doc: "Stop after SigProfilerExtractor" }

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
    inputBinding:
      position: 2
      prefix: "--threads"
  ram:
    type: 'int?'
    default: 8
    doc: "GB size of RAM to allocate to this task."
outputs:
  dbs_activities:
    type: 'Directory?'
    outputBinding:
      glob: "DBS78/Suggested_Solution/DBS78_De-Novo_Solution/Activities"
  dbs_signatures:
    type: 'Directory?'
    outputBinding:
      glob: "DBS78/Suggested_Solution/DBS78_De-Novo_Solution/Signatures"
  id_activities:
    type: 'Directory?'
    outputBinding:
      glob: "ID83/Suggested_Solution/ID83_De-Novo_Solution/Activities"
  id_signatures:
    type: 'Directory?'
    outputBinding:
      glob: "ID83/Suggested_Solution/ID83_De-Novo_Solution/Signatures"
  sbs_activities:
    type: 'Directory?'
    outputBinding:
      glob: "SBS96/Suggested_Solution/SBS96_De-Novo_Solution/Activities"
  sbs_signatures:
    type: 'Directory?'
    outputBinding:
      glob: "SBS96/Suggested_Solution/SBS96_De-Novo_Solution/Signatures"
  extraneous_results:
    type: 'File?'
    outputBinding:
      glob: "extraneous_results.tar.gz"
