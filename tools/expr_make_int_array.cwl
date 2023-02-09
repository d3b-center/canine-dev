cwlVersion: v1.2
class: ExpressionTool
id: expr_make_int_array
doc: |
  Make an array of input length with values beginning at 0 and ending inputs.length - 1.
requirements:
  - class: InlineJavascriptRequirement
inputs:
  index:
    type: int?
    default: 0
  length:
    type: int
outputs:
  output:
    type: int[] 
expression: |
  ${ return { output: Array(inputs.length).fill(inputs.index).map(function(x, y) { return  x + y }) } }
