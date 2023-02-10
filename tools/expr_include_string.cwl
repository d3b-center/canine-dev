cwlVersion: v1.2
class: ExpressionTool
id: expr_include_string
doc: |
  The TGEN mutation burden script requires the input VCF be filtered. The filter include statement
  is rather complex and constructed using three separate inputs. Cavatica doesn't allow us to
  smash workflow inputs together on the fly so I'm making this tool to handle the string creation.
requirements:
  - class: InlineJavascriptRequirement
inputs:
  snpeff: { type: 'boolean', doc: "Did the input VCF come from SnpEff?" }
  ns_effects: { type: 'string[]', doc: "Collection of NS Effects. TGEN supplies this in a constants config." }
  total_callers: { type: 'int', doc: "The total number of callers used to create the input vcf." }
outputs:
  output:
    type: string
expression: |
  ${
    var cc_filter = inputs.total_callers > 3 ? inputs.total_callers - 2 : inputs.total_callers - 1;
    var info_prefix = inputs.snpeff ? "INFO/ANN ~ " : "INFO/CSQ ~ ";
    var info_eff = inputs.ns_effects.map(function(e) { return info_prefix + e; });
    var include = "INFO/CC>=" + cc_filter + " && (" + info_eff.join(" || ") + ")"; 
    return { output: include }
  }
