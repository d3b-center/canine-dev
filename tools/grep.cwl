cwlVersion: v1.2
id: grep
requirements:
  - class: DockerRequirement
    dockerPull: 'ubuntu:20.04'
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
class: CommandLineTool
baseCommand: [grep]
stdout: $(inputs.outfile)
inputs:
  enable_tool: { type: 'string?', doc: "Killswitch for tool in workflow" }
  infile: { type: 'File', inputBinding: { position: 9, prefix: "--file"}, doc: "Obtain patterns from FILE, one per line.  If this option is used multiple times or is combined with the -e (--regexp) option, search for all patterns given.  The  empty  file  contains zero patterns, and therefore matches nothing." }
  outfile: { type: 'string', default: "out.txt", doc: "Output filename" }
  regexp: { type: 'string', inputBinding: { position: 8, prefix: "--regexp"}, doc: "Use  PATTERN  as  the  pattern.   If this option is used multiple times or is combined with the -f (--file) option, search for all patterns given.  This option can be used to protect a pattern beginning with '-'." }
  ignore_case: { type: 'boolean?', inputBinding: { position: 2, prefix: "--ignore-case"}, doc: "Ignore case distinctions, so that characters that differ only in case match each other." }
  invert_match: { type: 'boolean?', inputBinding: { position: 2, prefix: "--invert-match"}, doc: "Invert the sense of matching, to select non-matching lines." }
  word_regexp: { type: 'boolean?', inputBinding: { position: 2, prefix: "--word-regexp"}, doc: "Select  only  those  lines  containing  matches  that  form whole words.  The test is that the matching substring must either be at the beginning of the line, or preceded by a non-word constituent character.  Similarly, it must be either at the end of the line or followed by a non-word constituent character.  Word-constituent characters are letters, digits,  and  the underscore.  This option has no effect if -x is also specified." }
  line_regexp: { type: 'boolean?', inputBinding: { position: 2, prefix: "--line-regexp"}, doc: "Select only those matches that exactly match the whole line.  For a regular expression pattern, this is like parenthesizing the pattern and then surrounding it with ^ and $." }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 2
    doc: "GB size of RAM to allocate to this task."
outputs:
  output:
    type: stdout
