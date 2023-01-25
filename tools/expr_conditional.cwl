cwlVersion: v1.2
class: ExpressionTool
id: expr_conditional
doc: |
  If you want to disable a workflow in 1.2 you'll want to set a boolean value that can disable the
  step using when. To make that CWL valid on Cavatica all inputs need to be sunk into an step. Here
  we accept that boolean value with a quick expressiontool that does nothing.
requirements:
  - class: InlineJavascriptRequirement
inputs:
  disable:
    type: boolean?
outputs:
  output:
    type: boolean?
expression: |
  ${ return { output: inputs.disable } }
