cwlVersion: v1.2
class: ExpressionTool
id: expr_gatk_cnv_variables
doc: |
  GATK CNV needs a lot of variables. This helps localize the logic in one place.
requirements:
  - class: InlineJavascriptRequirement
inputs:
  # Universal
  bamstats_max_length: { type: 'int' }
  exome: { type: 'boolean?' }

  # Exome
  intervals_min_interval: { type: 'int?' }
  absolute_min_interval: { type: 'int?', default: 100 }

  # Genome
  normal_average_depth: { type: 'int?' }
  tumor_average_depth: { type: 'int?' }
  coverage_constant: { type: 'int?', default: 30 }
  bin_length_constant: { type: 'int?', default: 2000 }
  min_bin_length: { type: 'int?', default: 2000 }
outputs:
  bin_length: { type: int }
  exp_1x_counts: { type: int }
  max_vaf: { type: int }
  min_dp: { type: int }
  min_vaf: { type: int }
  padding: { type: 'int?' }
expression: |
  ${
    var tmp_bin_length = 0;

    if (inputs.exome) {
      tmp_bin_length = Math.max(inputs.intervals_min_interval, inputs.absolute_min_interval) + 200;
    } else {
      var average_depth = Math.min(inputs.normal_average_depth, inputs.tumor_average_depth);
      var bin_length_mod = inputs.coverage_constant / average_depth;
      tmp_bin_length = inputs.bin_length_constant * bin_length_mod;
      tmp_bin_length = Math.max(tmp_bin_length, inputs.min_bin_length);
    }

    var corr_bin_len = (inputs.exome ? tmp_bin_length * 20 : tmp_bin_length); // Exome gets multiplied by 20 to reach an estimated 20x depth
    var out_exp_1x_counts = corr_bin_len/inputs.bamstats_max_length/2; // Divide by two to accomidate autosomes

    var out_bin_length = (inputs.exome ? 0 : tmp_bin_length); // Ultimately the value we need for bin_length in exome samples is zero

    var out_min_vaf = 0.333;
    var out_max_vaf = 0.666;
    var out_min_db = 5;
    if (inputs.exome || inputs.normal_average_depth >= 20) {
      out_min_vaf = 0.45;
      out_max_vaf = 0.55;
      out_min_db = 20;
    }

    var out = { 'bin_length': 100, 'exp_1x_counts': 100, 'max_vaf': 100, 'min_db': 100, 'min_vaf': 100, 'padding': 100  };
    return out; 
  }
