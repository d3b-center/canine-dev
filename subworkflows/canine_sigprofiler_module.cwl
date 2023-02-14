cwlVersion: v1.2
class: Workflow
id: canine_sigprofiler_module
doc: "Port of Canine Sigprofiler Module"

requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement

inputs:
  input_vcf: { type: 'File', doc: "VCF files to merge." }
  output_basename: { type: 'string', doc: "String to use as base for output filenames." }
  disable_workflow: { type: 'boolean?', doc: "For when this workflow is wrapped into a larger workflow, you can use this value in the when statement to toggle the running of this workflow." }
  total_callers: { type: 'int', doc: "Total callers run to generate this VCF." } 

  # Resource Control
  bcftools_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to BCFtools." }
  bcftools_cpu: { type: 'int?', doc: "Number of CPUs to allocate to BCFtools." }
  sigprofiler_ram: { type: 'int?', doc: "Maximum GB of RAM to allocate to Sigprofiler." }
  sigprofiler_cpu: { type: 'int?', doc: "Number of CPUs to allocate to Sigprofiler." }

outputs:
  dbs_activities: { type: 'Directory?', outputSource: sigprofiler/dbs_activities }
  dbs_signatures: { type: 'Directory?', outputSource: sigprofiler/dbs_signatures }
  id_activities: { type: 'Directory?', outputSource: sigprofiler/id_activities }
  id_signatures: { type: 'Directory?', outputSource: sigprofiler/id_signatures }
  sbs_activities: { type: 'Directory?', outputSource: sigprofiler/sbs_activities }
  sbs_signatures: { type: 'Directory?', outputSource: sigprofiler/sbs_signatures }
  extraneous_results: { type: 'File?', outputSource: sigprofiler/extraneous_results }

steps:
  bcftools_view_index:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: input_vcf
      include:
        source: total_callers
        valueFrom: |
          $(self > 3 ? "INFO/CC>=" + (self - 2) : "INFO/CC>=" + (self - 1))
      output_filename:
        source: output_basename
        valueFrom: $(self).pass.vcf
      cpu: bcftools_cpu
      ram: bcftools_ram
    out: [output]

  sigprofiler:
    run: ../tools/sigprofiler.cwl
    in:
      input_vcfs:
        source: bcftools_view_index/output
        valueFrom: $([self])
      genome:
        source: disable_workflow # hiding this here because I hate cavatica
        valueFrom: "dog"
      project: output_basename
      extract_only:
        valueFrom: $(1 == 1)
      cpu: sigprofiler_cpu
      ram: sigprofiler_ram
    out: [dbs_activities, dbs_signatures, id_activities, id_signatures, sbs_activities, sbs_signatures, extraneous_results]

$namespaces:
  sbg: https://sevenbridges.com
