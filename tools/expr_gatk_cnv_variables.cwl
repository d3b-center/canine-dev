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
  max_vaf: { type: float }
  min_dp: { type: int }
  min_vaf: { type: float }
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
    var out_exp_1x_counts = Math.floor(corr_bin_len / inputs.bamstats_max_length / 2); // Divide by two to accommodate autosomes

    var out_bin_length = (inputs.exome ? 0 : tmp_bin_length); // Ultimately the value we need for bin_length in exome samples is zero

    var out_min_vaf = (inputs.exome || inputs.normal_average_depth >= 20 ? 0.45 : 0.333);
    var out_max_vaf = (inputs.exome || inputs.normal_average_depth >= 20 ? 0.55 : 0.666);
    var out_min_db = (inputs.exome || inputs.normal_average_depth >= 20 ? 20 : 5);

    return {
      'bin_length': out_bin_length,
      'exp_1x_counts': out_exp_1x_counts,
      'max_vaf': out_max_vaf,
      'min_dp': out_min_db,
      'min_vaf': out_min_vaf,
      'padding': (inputs.exome ? 100 : null)
    };
  }
