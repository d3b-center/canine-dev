cwlVersion: v1.2
class: CommandLineTool
id: coyote_stats2lims
doc: "Module used to push sample QC stats into the LIMS. Used in conjunction with samStats2json output files"
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'dmiller15/stats2lims:1.0'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: InitialWorkDirRequirement
    listing:
    - entryname: uploadStats2Lims_1ace81f.py
      writable: false
      entry:
        $include: ../scripts/uploadStats2Lims_1ace81f.py
baseCommand: [uploadStats2Lims_1ace81f.py]

inputs:
  statsfile: { type: 'File', inputBinding: { position: 5 }, doc: "json that will be pushed to the LIMS" }
  filetype: { type: 'string', inputBinding: { position: 6 }, doc: "the file type that will be imported" }
  isilonpath: { type: 'string', inputBinding: { position: 7 }, doc: "the path where the results of the study from the pipeline were stored" }
  project: { type: 'string', inputBinding: { position: 8 }, doc: "Project ID" }
  study: { type: 'string', inputBinding: { position: 9 }, doc: "name of the study" }
  library_id: { type: 'string?', inputBinding: { position: 2, prefix: "--libraryID"}, doc: "name of the libraryID" }
  contig_list: { type: 'string?', inputBinding: { position: 2, prefix: "--contigList"}, doc: "comma separated list of contigs to push into the LIMS . (='None')" }

  cpu:
    type: 'int?'
    default: 1
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 4
    doc: "GB size of RAM to allocate to this task."
