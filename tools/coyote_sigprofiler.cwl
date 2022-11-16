cwlVersion: v1.2
class: CommandLineTool
id: coyote_sigprofiler
doc: "Custom sigprofiler tool for Coyote"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'dmiller15/sigprofiler:1.1'
  - class: InitialWorkDirRequirement
    listing:
    - entryname: sigprofiler_d78cc9e.py 
      writable: false
      entry:
        $include: ../scripts/sigprofiler_d78cc9e.py
    - $(inputs.input_vcfs)
baseCommand: [python, sigprofiler_d78cc9e.py]
arguments:
  - position: 2
    prefix: '--vcfpath'
    shellQuote: false
    valueFrom: |
      .
  - position: 99
    prefix: ''
    shellQuote: false
    valueFrom: |
      1>&2
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
  sbs_activity:
    type: 'File?'
    outputBinding:
      glob: "SBS96/**/*De-Novo_Activities_refit.txt"
  sbs_activity_plot:
    type: 'File?'
    outputBinding:
      glob: "SBS96/**/*De-Novo_Activity_Plots_refit.pdf"
  sbs_tmb_plot:
    type: 'File?'
    outputBinding:
      glob: "SBS96/**/*De-Novo_TMB_plot_refit.pdf"
  sbs_dnm_prob:
    type: 'File?'
    outputBinding:
      glob: "SBS96/**/*Mutation_Probabilities_refit.txt"
  sbs_dn_sigs:
    type: 'File?'
    outputBinding:
      glob: "SBS96/**/*De-Novo_Signatures.txt"
  id_activity:
    type: 'File?'
    outputBinding:
      glob: "SBS96/**/*De-Novo_Activities_refit.txt"
  id_activity_plot:
    type: 'File?'
    outputBinding:
      glob: "ID83/**/*De-Novo_Activity_Plots_refit.pdf"
  id_tmb_plot:
    type: 'File?'
    outputBinding:
      glob: "ID83/**/*De-Novo_TMB_plot_refit.pdf"
  id_dnm_prob:
    type: 'File?'
    outputBinding:
      glob: "ID83/**/*Mutation_Probabilities_refit.txt"
  id_dn_sigs:
    type: 'File?'
    outputBinding:
      glob: "ID83/**/*De-Novo_Signatures.txt"
  dbs_activity:
    type: 'File?'
    outputBinding:
      glob: "DBS78/**/*De-Novo_Activities_refit.txt"
  dbs_activity_plot:
    type: 'File?'
    outputBinding:
      glob: "DBS78/**/*De-Novo_Activity_Plots_refit.pdf"
  dbs_tmb_plot:
    type: 'File?'
    outputBinding:
      glob: "DBS78/**/*De-Novo_TMB_plot_refit.pdf"
  dbs_dnm_prob:
    type: 'File?'
    outputBinding:
      glob: "DBS78/**/*Mutation_Probabilities_refit.txt"
  dbs_dn_sigs:
    type: 'File?'
    outputBinding:
      glob: "DBS78/**/*De-Novo_Signatures.txt"
#  extraneous_results:
#    type: 'File?'
#    outputBinding:
#      glob: "extraneous_results.tar"
