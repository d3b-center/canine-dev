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
  sbs_activity: { type: 'File?', outputSource: sigprofiler/sbs_activity }
  sbs_activity_plot: { type: 'File?', outputSource: sigprofiler/sbs_activity_plot }
  sbs_tmb_plot: { type: 'File?', outputSource: sigprofiler/sbs_tmb_plot }
  sbs_dnm_prob: { type: 'File?', outputSource: sigprofiler/sbs_dnm_prob }
  sbs_dn_sigs: { type: 'File?', outputSource: sigprofiler/sbs_dn_sigs }
  id_activity: { type: 'File?', outputSource: sigprofiler/id_activity }
  id_activity_plot: { type: 'File?', outputSource: sigprofiler/id_activity_plot }
  id_tmb_plot: { type: 'File?', outputSource: sigprofiler/id_tmb_plot }
  id_dnm_prob: { type: 'File?', outputSource: sigprofiler/id_dnm_prob }
  id_dn_sigs: { type: 'File?', outputSource: sigprofiler/id_dn_sigs }
  dbs_activity: { type: 'File?', outputSource: sigprofiler/dbs_activity }
  dbs_activity_plot: { type: 'File?', outputSource: sigprofiler/dbs_activity_plot }
  dbs_tmb_plot: { type: 'File?', outputSource: sigprofiler/dbs_tmb_plot }
  dbs_dnm_prob: { type: 'File?', outputSource: sigprofiler/dbs_dnm_prob }
  dbs_dn_sigs: { type: 'File?', outputSource: sigprofiler/dbs_dn_sigs }

steps:
  bcftools_view_index:
    run: ../tools/bcftools_view_index.cwl
    in:
      input_vcf: input_vcf
      include:
        source: total_callers
        valueFrom: |
          $(self > 3 ? "INFO/CC>=" + self - 2 : "INFO/CC>=" + self - 1)
      output_filename:
        source: output_basename
        valueFrom: $(self).flt.vcf
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
    out: [sbs_activity, sbs_activity_plot, sbs_tmb_plot, sbs_dnm_prob, sbs_dn_sigs, id_activity, id_activity_plot, id_tmb_plot, id_dnm_prob, id_dn_sigs, dbs_activity, dbs_activity_plot, dbs_tmb_plot, dbs_dnm_prob, dbs_dn_sigs]

$namespaces:
  sbg: https://sevenbridges.com
