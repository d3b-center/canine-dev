cwlVersion: v1.2
class: ExpressionTool
id: expr_sex_guess
doc: |
  Given config_sex and sex_check_sex, pick the right one. 
requirements:
  - class: InlineJavascriptRequirement
inputs:
  config_sex:
    type:
      - 'null'
      - type: enum
        name: config_sex
        symbols: ["Female","Male"]
    doc: "Sex of the sample"
  sex_check_sex: { type: 'string?' }
outputs:
  output: { type: string }

expression: |
  ${
    var out_sex = (["Male", "Female"].indexOf(inputs.sex_check_sex) != -1 ? inputs.sex_check_sex : ["Male", "Female"].indexOf(inputs.config_sex) != -1 ? inputs.config_sex : "Female")

    return {
      'output': out_sex
    };
  }
