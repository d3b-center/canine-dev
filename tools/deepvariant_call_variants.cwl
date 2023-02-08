cwlVersion: v1.2
class: CommandLineTool
id: deepvariant_call_variants
doc: "Deepvariant Call Variants"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.max_memory*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'google/deepvariant:0.10.0-gpu'
  - class: InitialWorkDirRequirement
    listing: $(inputs.examples)
baseCommand: [/opt/deepvariant/bin/call_variants]
arguments:
  - position: 2
    prefix: "--checkpoint"
    shellQuote: false
    valueFrom: >
      /opt/models/$(inputs.sample_type)/model.ckpt
inputs:
  batch_size: { type: 'int?', inputBinding: { position: 2, prefix: "--batch_size"}, doc: "Number of candidate variant tensors to batch together during inference. Larger batches use more memory but are more computational efficient." }
  sample_type: 
    type:
      - type: enum
        name: sample_type
        symbols: ["pacbio", "wes", "wgs"]
    doc: "Type of sample. Used to pick the appropriate checkpoint model."
  config_string: { type: 'string?', inputBinding: { position: 2, prefix: "--config_string"}, doc: "String representation of a tf.ConfigProto message, with comma-separated key: value pairs, such as 'allow_soft_placement: True'. The value can itself be another message, such as 'gpu_options: {per_process_gpu_memory_fraction: 0.5}'." }
  debugging_true_label_mode: { type: 'boolean?', inputBinding: { position: 2, prefix: "--debugging_true_label_mode"}, doc: "If true, read the true labels from examples and add to output. Note that the program will crash if the input examples do not have the label field. When true, this will also fill everything when --include_debug_info is set to true." }
  examples: { type: 'File[]', doc: "Required. tf.Example protos containing DeepVariant candidate variants in TFRecord format, as emitted by make_examples. Can be a comma-separated list of files, and the file names can contain wildcard characters." }
  examples_name: { type: 'string', inputBinding: { position: 2, prefix: "--examples" }, doc: "Short name convention for all example files (e.g. filename@10.gz)" }
  execution_hardware: { type: 'string?', inputBinding: { position: 2, prefix: "--execution_hardware"}, doc: "When in cpu mode, call_variants will not place any ops on the GPU, even if one is available. In accelerator mode call_variants validates that at least some hardware accelerator (GPU/TPU) was available for us. This option is primarily for QA purposes to allow users to validate their accelerator environment is correctly configured. In auto mode, the default, op placement is entirely left up to TensorFlow.  In tpu mode, use and require TPU." }
  gcp_project: { type: 'string?', inputBinding: { position: 2, prefix: "--gcp_project"}, doc: "Project name for the Cloud TPU-enabled project. If not specified, we will attempt to automatically detect the GCE project from metadata." }
  include_debug_info: { type: 'boolean?', inputBinding: { position: 2, prefix: "--include_debug_info"}, doc: "If true, include extra debug info in the output." }
  kmp_blocktime: { type: 'int?', inputBinding: { position: 2, prefix: "--kmp_blocktime"}, doc: "Value to set the KMP_BLOCKTIME environment variable to for efficient MKL inference. See https://www.tensorflow.org/performance/performance_guide for more information. The default value is 0, which provides the best performance in our tests. Set this flag to '' to not set the variable." }
  master: { type: 'string?', inputBinding: { position: 2, prefix: "--master"}, doc: "GRPC URL of the master (e.g. grpc://ip.address.of.tpu:8470). You must specify either this flag or --tpu_name." }
  max_batches: { type: 'int?', inputBinding: { position: 2, prefix: "--max_batches"}, doc: "Max. batches to evaluate. Defaults to all." }
  model_name: { type: 'string?', inputBinding: { position: 2, prefix: "--model_name"}, doc: "The name of the model architecture of --checkpoint." }
  num_mappers: { type: 'int?', inputBinding: { position: 2, prefix: "--num_mappers"}, doc: "Number of parallel mappers to create for examples." }
  num_readers: { type: 'int?', inputBinding: { position: 2, prefix: "--num_readers"}, doc: "Number of parallel readers to create for examples." }
  outfile: { type: 'string', inputBinding: { position: 2, prefix: "--outfile"}, doc: "Required. Destination path where we will write output candidate variants with additional likelihood information in TFRecord format of CallVariantsOutput protos." }
  tpu_name: { type: 'string?', inputBinding: { position: 2, prefix: "--tpu_name"}, doc: "Name of the Cloud TPU for Cluster Resolvers. You must specify either this flag or --master. An empty value corresponds to no Cloud TPU. See https://www.tensorflow.org/api_docs/python/tf/distribute/cluster_resolver/TPUClusterResolver" }
  tpu_zone: { type: 'string?', inputBinding: { position: 2, prefix: "--tpu_zone"}, doc: "GCE zone where the Cloud TPU is located in. If not specified, we will attempt to automatically detect the GCE project from metadata." }
  use_tpu: { type: 'boolean?', inputBinding: { position: 2, prefix: "--use_tpu"}, doc: "Use tpu if available." }

  cpu:
    type: 'int?'
    default: 8
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 40
    doc: "Maximum GB of RAM to allocate for this tool."
outputs:
  output: 
    type: File
    outputBinding:
      glob: $(inputs.outfile)
