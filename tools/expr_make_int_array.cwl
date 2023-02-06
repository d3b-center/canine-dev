cwlVersion: v1.2
class: ExpressionTool
id: expr_make_int_array
doc: |
  Make an array of input length with values beginning at 1 and ending inputs.length.
requirements:
  - class: InlineJavascriptRequirement
inputs:
  length:
    type: int
outputs:
  output:
    type: int[] 
expression: |
  ${ return { output: Array(inputs.length).fill(1).map(function(x, y) { return  x + y }) } }
