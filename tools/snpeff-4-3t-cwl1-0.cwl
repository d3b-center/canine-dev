class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://sevenbridges.com'
id: d3b-bixu/dev-canine-workflow/snpeff-4-3t-cwl1-0/0
baseCommand: []
inputs:
  - 'sbg:category': Annotations options
    'sbg:toolDefaultValue': 'True'
    id: add_hgvs_anno
    type:
      - 'null'
      - type: enum
        symbols:
          - 'True'
          - 'False'
        name: add_hgvs_anno
    inputBinding:
      position: 175
      prefix: ''
      shellQuote: false
      valueFrom: |-
        ${
            if (inputs.add_hgvs_anno == 'True')
            {
                return  ' -hgvs '
            }
            else if (inputs.add_hgvs_anno == 'False')
            {
                return ' -noHgvs '
            }
            else
            {
                return ''
            }
        }
    label: Use HGVS annotations for amino acid sub-field
    doc: 'Use HGVS annotations for amino acid sub-field. Default: True.'
  - 'sbg:category': Annotations options
    id: add_lof_tag
    type:
      - 'null'
      - type: enum
        symbols:
          - 'True'
          - 'False'
        name: add_lof_tag
    inputBinding:
      position: 205
      prefix: ''
      shellQuote: false
      valueFrom: |-
        ${
            if (inputs.add_lof_tag == 'True')
            {
                return ' -lof '
            }
            else if (inputs.add_lof_tag == 'False')
            {
                return ' -noLof '
            }
            else
            {
                ''
            }
        }
    label: Add loss of function (LOF) and nonsense mediated decay (NMD) tags
    doc: Add loss of function (LOF) and nonsense mediated decay (NMD) tags.
  - 'sbg:category': Inputs
    id: assembly
    type: string
    inputBinding:
      position: 2005
      separate: false
      shellQuote: false
    label: Assembly (genome version)
    doc: >-
      Genome version matching the SnpEff database used (for example GRCh37.75 or
      GRCh38.86).
  - 'sbg:category': Annotations options
    'sbg:toolDefaultValue': 'False'
    id: cancer
    type: boolean?
    inputBinding:
      position: 145
      prefix: '-cancer'
      shellQuote: false
    label: Perform 'cancer' comparisons (somatic vs. germline)
    doc: Perform 'cancer' comparisons (somatic vs. germline).
  - 'sbg:category': Annotations options
    id: cancersamples
    type: File?
    inputBinding:
      position: 155
      prefix: '-cancerSamples'
      shellQuote: false
    label: Two column TXT file defining 'original and derived' samples
    doc: Two column TXT file defining 'original \t derived' samples.
    'sbg:fileTypes': TXT
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': 'False'
    id: canon
    type: boolean?
    inputBinding:
      position: 305
      prefix: '-canon'
      shellQuote: false
    label: Only use canonical transcripts
    doc: Only use canonical transcripts.
  - 'sbg:category': Database options
    id: canonList
    type: File?
    inputBinding:
      position: 5
      prefix: '-canonList'
      shellQuote: false
    label: Canon list file
    doc: "Only use canonical transcripts, replace some transcripts using the 'gene_id \t transcript_id' entries in <file>."
  - 'sbg:category': Options
    id: chr
    type: string?
    inputBinding:
      position: 60
      prefix: '-chr'
      shellQuote: false
    label: String to prepend to chromosome names
    doc: >-
      Prepend 'string' to chromosome name (e.g. 'chr1' instead of '1'). Only on
      TXT output.
  - 'sbg:category': General options
    'sbg:toolDefaultValue': 'False'
    id: classic
    type: boolean?
    inputBinding:
      position: 15
      prefix: '-classic'
      shellQuote: false
    label: Use old style annotations
    doc: Use old style annotations instead of Sequence Ontology and Hgvs.
  - 'sbg:category': Generic options
    id: configOption
    type: 'string[]?'
    inputBinding:
      position: 5
      prefix: '-configOption'
      itemSeparator: ' -configOption '
      shellQuote: false
    label: Override a config file option (name=value format)
    doc: >-
      Override a config file option. Please note that the options should be
      entered in name=value format.
  - 'sbg:category': Generic options
    'sbg:altPrefix': '-config'
    id: configuration_file
    type: File?
    inputBinding:
      position: 265
      prefix: '-c'
      shellQuote: false
    label: Configuration file
    doc: Specify config file.
    'sbg:fileTypes': config
  - 'sbg:category': Options
    'sbg:toolDefaultValue': 'False'
    default: 0
    id: csvstats
    type: boolean?
    inputBinding:
      position: 25
      prefix: '-csvStats'
      shellQuote: false
      valueFrom: |-
        ${
            if (self == 0) {
                self = null;
                inputs.csvstats = null
            };


            if (inputs.csvstats) 
            {
                if (inputs.stats)
                {
                    return inputs.stats.concat('.csv')
                }
                else
                {
                    test = [].concat(inputs.in_variants)
                    filename = test[0].path.split('/').pop()
                    primename = filename.split('.vcf')[0]
                    return primename.concat(".csv")
                }
            }
        }
    label: Create CSV summary file alongside HTML
    doc: Create CSV summary file alongside HTML.
  - 'sbg:category': File type inputs
    id: database
    type: File
    label: SnpEff database file
    doc: >-
      SnpEff database file is zip archive that can be downloaded from the SnpEff
      official site, or using the SnpEff download app.
    'sbg:fileTypes': ZIP
  - 'sbg:category': Results filter options
    'sbg:altPrefix': '-fi'
    id: filterinterval
    type: 'File[]?'
    inputBinding:
      position: 85
      prefix: '-filterInterval'
      itemSeparator: ' -filterInterval '
      shellQuote: false
    label: >-
      Only analyze changes that intersect with the intervals specified in this
      file (you may use this option many times)
    doc: >-
      Only analyze changes that intersect with the intervals specified in this
      file.
    'sbg:fileTypes': interval
  - 'sbg:category': Annotations options
    'sbg:toolDefaultValue': 'False'
    id: format_eff
    type: boolean?
    inputBinding:
      position: 165
      prefix: '-formatEff'
      shellQuote: false
    label: Use EFF field
    doc: Use 'EFF' field compatible with older versions (instead of 'ANN').
  - 'sbg:category': Annotations options
    'sbg:toolDefaultValue': 'False'
    id: geneid
    type: boolean?
    inputBinding:
      position: 175
      prefix: '-geneId'
      shellQuote: false
    label: Use gene ID instead of gene name (VCF output)
    doc: 'Use gene ID instead of gene name (VCF output). Default: false.'
  - 'sbg:category': Annotations options
    'sbg:toolDefaultValue': 'False'
    id: hgvsOld
    type: boolean?
    inputBinding:
      position: 5
      prefix: '-hgvsOld'
      shellQuote: false
    label: Use old HGVS notation
    doc: Use old HGVS notation.
  - 'sbg:category': Annotations options
    'sbg:toolDefaultValue': 'False'
    id: hgvs_1_letter
    type: boolean?
    inputBinding:
      position: 185
      prefix: '-hgvs1LetterAa'
      shellQuote: false
    label: Use one letter amino acid codes in HGVS
    doc: 'Use one letter amino acid codes in HGVS notation. Default: false.'
  - 'sbg:category': Annotations options
    'sbg:toolDefaultValue': 'False'
    id: hgvs_tr_id
    type: boolean?
    inputBinding:
      position: 195
      prefix: '-hgvsTrId'
      shellQuote: false
    label: Use transcript ID in HGVS
    doc: 'Use transcript ID in HGVS notation. Default: false.'
  - 'sbg:category': Options
    'sbg:toolDefaultValue': vcf
    id: input_format
    type:
      - 'null'
      - type: enum
        symbols:
          - vcf
          - ' bed'
        name: input_format
    inputBinding:
      position: 45
      prefix: '-i'
      shellQuote: false
    label: Input format
    doc: 'Input format. Possible values: {vcf, txt, pileup, bed}. [Default: vcf].'
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': 'True'
    id: interaction
    type:
      - 'null'
      - type: enum
        symbols:
          - 'True'
          - 'False'
        name: interaction
    inputBinding:
      position: 315
      prefix: ''
      shellQuote: false
      valueFrom: |-
        ${
            if (inputs.interaction == 'True')
            {
                return ' -interaction '
            }
            else if (inputs.interaction == 'False')
            {
                return ' -noInteraction '
            }
            else
            {
                ''
            }
        }
    label: Annotate using interactions
    doc: 'Annotate using inteactions (requires interaciton database). Default: true.'
  - 'sbg:category': Database options
    id: interval
    type: 'File[]?'
    inputBinding:
      position: 325
      prefix: '-interval'
      itemSeparator: ' -interval '
      shellQuote: false
    label: >-
      Use a custom intervals in TXT/BED/BigBed/VCF/GFF file (you may use this
      option many times)
    doc: >-
      Use a custom intervals in TXT/BED/BigBed/VCF/GFF file (you may use this
      option many times).
    'sbg:fileTypes': 'TXT, BED, BigBed, VCF, GFF'
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': 'null'
    id: max_tsl
    type: int?
    inputBinding:
      position: 335
      prefix: '-maxTSL'
      shellQuote: false
    label: Max TSL
    doc: >-
      Only use transcripts having Transcript Support Level lower than this
      cutoff.
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': 'True'
    id: motif
    type:
      - 'null'
      - type: enum
        symbols:
          - 'True'
          - 'False'
        name: motif
    inputBinding:
      position: 345
      prefix: ''
      shellQuote: false
      valueFrom: |-
        ${
            if (inputs.motif == 'True')
            {
                return ' -motif '
            }
            else if (inputs.motif == 'False')
            {
                return ' -noMotif '
            }
            else
            {
                return ''
            }
        }
    label: Annotate using motifs (requires Motif database)
    doc: Annotate using motifs (requires Motif database).
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': 'True'
    id: nextprot
    type:
      - 'null'
      - type: enum
        symbols:
          - 'True'
          - 'False'
        name: nextprot
    inputBinding:
      position: 355
      prefix: ''
      shellQuote: false
      valueFrom: |-
        ${
            if (inputs.nextprot == 'True')
            {
                return ' -nextProt '
            }
            else if (inputs.nextprot == 'False')
            {
                return ' -noNextProt '
            }
            else
            {
                ''
            }
        }
    label: Annotate using NextProt (requires NextProt database)
    doc: Annotate using NextProt (requires NextProt database).
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': 'False'
    id: noExpandIUB
    type: boolean?
    inputBinding:
      position: 5
      prefix: '-noExpandIUB'
      shellQuote: false
    label: Disable IUB code expansion
    doc: Disable IUB code expansion in input variants.
  - 'sbg:category': Results filter options
    id: no_EffectType
    type: 'string[]?'
    inputBinding:
      position: 5
      prefix: '-no'
      itemSeparator: ' -no '
      shellQuote: false
    label: Do not show EffectType
    doc: Do not show 'EffectType'. This option can be used several times.
  - 'sbg:category': Results filter options
    'sbg:toolDefaultValue': 'False'
    id: no_downstream
    type: boolean?
    inputBinding:
      position: 95
      prefix: '-no-downstream'
      shellQuote: false
    label: Do not show downstream changes
    doc: Do not show downstream changes.
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': 'False'
    id: no_genome
    type: boolean?
    inputBinding:
      position: 365
      prefix: '-noGenome'
      shellQuote: false
    label: Do not load any genomic database
    doc: Do not load any genomic database (e.g. annotate using custom files).
  - 'sbg:category': Results filter options
    'sbg:toolDefaultValue': 'False'
    id: no_intergenic
    type: boolean?
    inputBinding:
      position: 105
      prefix: '-no-intergenic'
      shellQuote: false
    label: Do not show intergenic changes
    doc: Do not show intergenic changes.
  - 'sbg:category': Results filter options
    'sbg:toolDefaultValue': 'False'
    id: no_intron
    type: boolean?
    inputBinding:
      position: 115
      prefix: '-no-intron'
      shellQuote: false
    label: Do not show intron changes
    doc: Do not show intron changes.
  - 'sbg:category': Annotations options
    'sbg:toolDefaultValue': 'False'
    id: no_shift_hgvs
    type: boolean?
    inputBinding:
      position: 235
      prefix: '-noShiftHgvs'
      shellQuote: false
    label: Do not shift variants according to HGVS
    doc: Do not shift variants according to HGVS notation (most 3-prime end).
  - 'sbg:category': Results filter options
    'sbg:toolDefaultValue': 'False'
    id: no_upstream
    type: boolean?
    inputBinding:
      position: 125
      prefix: '-no-upstream'
      shellQuote: false
    label: Do not show upstream changes
    doc: Do not show upstream changes.
  - 'sbg:category': Results filter options
    'sbg:toolDefaultValue': 'False'
    id: no_utr
    type: boolean?
    inputBinding:
      position: 135
      prefix: '-no-utr'
      shellQuote: false
    label: Do not show 5_PRIME_UTR or 3_PRIME_UTR changes
    doc: Do not show 5_PRIME_UTR or 3_PRIME_UTR changes.
  - 'sbg:category': Options
    'sbg:toolDefaultValue': 'False'
    id: nostats
    type: boolean?
    inputBinding:
      position: 75
      prefix: '-noStats'
      shellQuote: false
    label: Do not create stats (summary) file
    doc: Do not create stats (summary) file.
  - 'sbg:category': Annotations options
    'sbg:toolDefaultValue': 'False'
    id: oicr
    type: boolean?
    inputBinding:
      position: 245
      prefix: '-oicr'
      shellQuote: false
    label: Add OICR tag in VCF file
    doc: Add OICR tag in VCF file.
  - 'sbg:category': Database options
    id: onlyTr
    type: File?
    inputBinding:
      position: 5
      prefix: '-onlyTr'
      shellQuote: false
    label: Only use transcripts from this file
    doc: 'Only use the transcripts in this file. Format: One transcript ID per line.'
    'sbg:fileTypes': TXT
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': 'False'
    id: only_protein
    type: boolean?
    inputBinding:
      position: 415
      prefix: '-onlyProtein'
      shellQuote: false
    label: Only use protein coding transcripts
    doc: 'Only use protein coding transcripts. Default: false.'
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': 'False'
    id: onlyreg
    type: boolean?
    inputBinding:
      position: 405
      prefix: '-onlyReg'
      shellQuote: false
    label: Only use regulation tracks
    doc: Only use regulation tracks.
  - 'sbg:category': Options
    'sbg:toolDefaultValue': vcf
    id: output_format
    type:
      - 'null'
      - type: enum
        symbols:
          - vcf
          - gatk
          - bed
          - bedAnn
        name: output_format
    inputBinding:
      position: 55
      prefix: '-o'
      shellQuote: false
    label: Output format
    doc: 'Output format. Possible values: {txt, vcf, gatk, bed, bedAnn}.'
  - 'sbg:category': Database options
    id: reg
    type: 'string[]?'
    inputBinding:
      position: 425
      prefix: '-reg'
      itemSeparator: ' -reg '
      shellQuote: false
    label: Regulation track to use (this option can be used add several times)
    doc: Regulation track to use (this option can be used add several times).
  - 'sbg:category': Annotations options
    'sbg:toolDefaultValue': 'True'
    id: sequenceontology
    type:
      - 'null'
      - type: enum
        symbols:
          - 'True'
          - 'False'
        name: sequenceontology
    inputBinding:
      position: 255
      prefix: ''
      shellQuote: false
      valueFrom: |-
        ${
            if (inputs.sequenceontology == 'True')
            {
                return '-sequenceOntology'
            }
            else
            {
                return ''
            }
        }
    label: Use Sequence Ontology terms
    doc: Use Sequence Ontology terms.
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': '3'
    id: splice_region_exons_size
    type: int?
    inputBinding:
      position: 445
      prefix: '-spliceRegionExonSize'
      shellQuote: false
    label: Set size for splice site region within exons
    doc: 'Set size for splice site region within exons. Default: 3 bases.'
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': '3'
    id: splice_region_intron_min
    type: int?
    inputBinding:
      position: 5
      prefix: '-spliceRegionIntronMin'
      shellQuote: false
    label: Set minimum number of bases for splice site region within intron
    doc: >-
      Set minimum number of bases for splice site region within intron. Default:
      3 bases.
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': '8'
    id: splice_site_region_intron_max
    type: int?
    inputBinding:
      position: 5
      prefix: '-spliceRegionIntronMax'
      shellQuote: false
    label: Set maximum number of bases for splice site region within intron
    doc: >-
      Set maximum number of bases for splice site region within intron. Default:
      8 bases.
  - 'sbg:category': Database options
    'sbg:altPrefix': '-ss'
    'sbg:toolDefaultValue': '2'
    id: splicesitesize
    type: int?
    inputBinding:
      position: 435
      prefix: '--spliceSiteSize'
      shellQuote: false
    label: Set size for splice sites (donor and acceptor) in bases
    doc: Set size for splice sites (donor and acceptor) in bases.
  - 'sbg:category': Options
    'sbg:altPrefix': '-s'
    'sbg:toolDefaultValue': snpEff_summary.html
    default: 0
    id: stats
    type: string?
    inputBinding:
      position: 65
      prefix: '-stats'
      shellQuote: false
      valueFrom: |-
        ${
            if (self == 0) {
                self = null;
                inputs.stats = null
            };


            if (inputs.stats) {
                return inputs.stats.concat(".html")
            } else if (!inputs.nostats) {
                test = [].concat(inputs.in_variants)
                filename = test[0].path.split('/').pop()
                primename = filename.split('.vcf')[0]
                return primename.concat(".html")
            }
        }
    label: Name of stats file (summary)
    doc: Name of stats file (summary).
  - 'sbg:category': Database options
    'sbg:toolDefaultValue': 'False'
    id: strict
    type: boolean?
    inputBinding:
      position: 485
      prefix: '-strict'
      shellQuote: false
    label: Only use validated transcripts
    doc: >-
      Only use 'validated' transcripts (i.e. sequence has been checked).
      Default: false.
  - 'sbg:category': Other input types
    'sbg:toolDefaultValue': 'False'
    id: threads
    type: boolean?
    inputBinding:
      position: 285
      prefix: '-t'
      shellQuote: false
    label: Use multiple threads (implies '-noStats')
    doc: 'Use multiple threads (implies ''-noStats''). Default: False.'
  - 'sbg:category': Execution and Platform
    'sbg:toolDefaultValue': '8092'
    id: mem_per_job
    type: int?
    label: 'Java memory requirement [MB]'
    doc: 'RAM requirement for the java process execution [MB].'
  - 'sbg:category': Database options
    'sbg:altPrefix': '-ud'
    id: up_down_stream_len
    type: int?
    inputBinding:
      position: 495
      prefix: '-upDownStreamLen'
      shellQuote: false
    label: Upstream downstream interval length
    doc: Set upstream downstream interval length (in bases).
  - 'sbg:category': File type inputs
    id: in_variants
    type: File
    inputBinding:
      position: 2006
      shellQuote: false
    label: Input variants file
    doc: Input variants file.
    'sbg:fileTypes': 'VCF, TXT, PILEUP, BED, VCF.GZ'
  - id: prefix
    type: string?
    label: Prefix
    doc: Prefix to use for output naming
  - 'sbg:category': Execution and Platform
    'sbg:toolDefaultValue': '100'
    id: mem_overhead_per_job
    type: int?
    label: 'Memory overhead per job [MB]'
    doc: >-
      Memory overhead per job [MB]. The value of this parameter is added to
      mem_per_job (Memory per job [MB]) when requesting resources for the task,
      but is left unused by the tool (does not feature in -Xmx).
outputs:
  - id: out_variants
    doc: SnpEff annotated file.
    label: SnpEff annotated file
    type: File?
    outputBinding:
      glob: '*.snpEff_annotated.*'
      outputEval: '$(inheritMetadata(self, inputs.in_variants))'
    'sbg:fileTypes': 'VCF, TXT, GATK, BED, BEDANN'
  - id: summary
    doc: SnpEff summary file in HTML or CSV file format.
    label: Summary file
    type: 'File[]?'
    outputBinding:
      glob: '*.html'
      outputEval: '$(inheritMetadata(self, inputs.in_variants))'
    'sbg:fileTypes': 'HTML, CSV'
  - id: summary_text
    doc: SnpEff Summary in text format.
    label: Summary
    type: File?
    outputBinding:
      glob: '*.txt'
      outputEval: '$(inheritMetadata(self, inputs.in_variants))'
    'sbg:fileTypes': TXT
  - id: csv_summary
    doc: CSV summary file.
    label: CSV summary file
    type: File?
    outputBinding:
      glob: '*.csv'
      outputEval: '$(inheritMetadata(self, inputs.in_variants))'
    'sbg:fileTypes': CSV
doc: "**SnpEff** is a variant annotation and effect prediction​ tool, which annotates and predicts the effects of variants on genes, such as amino acid changes [1].\n\n*A list of **all inputs and parameters** with corresponding descriptions can be found at the end of the page.*\n\n### Common Use Cases\n\nTypical usage assumes predicted variants (SNPs, insertions, deletions, and MNPs) as input, usually in variant call format (VCF). **SnpEff** analyzes and annotates input variants and calculates the effects they produce on known genes [1]. The output file can be in several file formats, most common being VCF.\n\n**SnpEff** requires an annotation database to run. Official SnpEff annotation databases can be downloaded from [here](https://sourceforge.net/projects/snpeff/files/databases/v4_3/); however, human databases are also hosted on Seven Bridges, in Public Reference Files section (files snpEff_v4_3_GRCh38.86.zip and\tsnpEff_v4_3_GRCh37.75.zip) and can be [imported](https://docs.sevenbridges.com/docs/copy-files-using-the-visual-interface).\n\n### Changes Introduced by Seven Bridges\n\n* Input VCF file (**Input variants file**) is required (as opposed to default input being STDIN).\n* Parameter **Java memory requirement [MB]** which controls the amount of RAM available to **SnpEff** was included in the wrapper.\n* The following parameters have been excluded from the wrapper:  \n    * `-fileList` - Processing multiple files can be achieved by using batch tasks or scatter mode in workflows.\n    * `-dataDir <path>`  - In the wrapper, data directory is always the same and corresponds to the location of the prepared **SnpEff** database.\n    * `-download`  - Supplying a database archive as an input is required. Downloading missing data for a genome from command line is not supported.\n    * `-help`, `-quiet`, `-verbose`, `-debug` and `-version` - These options are not usually included in Seven Bridges wrappers.\n    * **Prefix** input parameter was added to allow setting custom prefixes for output file names.\n    * Complementary parameters `-hgvs/-noHgvs`, `-lof/-noLof`, `-interaction/-noInteraction` , `-motif/-noMotif` and `-nextProt/noNextProt` were wrapped together as enum inputs **Use HGVS annotations for amino acid sub-field**, **Add loss of function (LOF) and nonsense mediated decay (NMD) tags**, **Annotate using interactions**, **Annotate using motifs (requires Motif database)** and **Annotate using NextProt (requires NextProt database)**, respectively. \n\n### Common Issues and Important Notes\n\n* Required inputs are **Input variants file** (a VCF or VCF.GZ file to be annotated), **SnpEff database file** (SnpEff database ZIP archive matching the major version of SnpEff used [2], which is 4.3 for this wrapper; e.g. snpEff_v4_3_GRCh38.86.zip or snpEff_v4_3_GRCh37.75.zip from Public Reference Files section), and **Assembly (genome version)**, which is a string representing genome version/assembly (e.g., GRCh38.86, GRCh37.75, hg19), matching the SnpEff database used (GRCh38.86 and GRCh37.75 should be used for the files in the Public Reference Files section).\n* As **SnpEff** is a java tool, it may be occasionally necessary to increase the amount of allocated RAM (default value: 8192 MB), using the **Java memory requirement [MB]** parameter.\n* A number of **SnpEff** command line options are designed in mutually exclusive pairs (for example `-noStats` and `-stats` or `-lof` and `-noLof`) with some redundancy. These options should not be used together, to avoid task failure.\n* Multithreading parameter **Use multiple threads (implies '-noStats')** (`-t`) will disable statistics. \n* If using VCFs with mitochondrial DNA marked as chrM with GRCh38 database, chromosome not found error can be addressed by renaming chrM to chrMT in the input VCF files, for example using sed: `sed \"s/^chrM/chrMT/g\" input.vcf > input_renamed.vcf`\n* Disabling statistics using **Do not create stats (summary) file** (`-noStats`) will in general speed-up execution.\n\n### Performance Benchmarking\n\nAnnotating NA12878 genome (GRCh38, ~220 Mb as VCF.GZ) with default annotation parameters, 1 CPU, and 8192 MB RAM took 25 minutes with a cost of $0.17 using on-demand default AWS instance.\nBy default, **SnpEff** is allocated 8192 MB of memory. Allocating less memory is not recommended when working with whole genome VCF files.\n\n*Cost can be significantly reduced by **spot instance** usage. Visit [knowledge center](https://docs.sevenbridges.com/docs/about-spot-instances) for more details.*            \n\n### References\n\n[1] [SnpEff documentation](http://snpeff.sourceforge.net/SnpEff_manual.html)\n\n[2] [Official SnpEff 4.3 databases download location](https://sourceforge.net/projects/snpeff/files/databases/v4_3/)"
label: SnpEff - CWL 1.0
arguments:
  - position: 0
    shellQuote: false
    valueFrom: |-
      ${
          return 'unzip -o ' + inputs.database.path + ' -d /opt/snpEff ;'
      }
  - position: 1
    shellQuote: false
    valueFrom: java
  - position: 2
    prefix: ''
    shellQuote: false
    valueFrom: |-
      ${
          if (inputs.mem_per_job) {
              mem_mb = parseInt(inputs.mem_per_job)
              return '-Xmx'.concat(mem_mb, 'M')
          }
          return '-Xmx8092M'
      }
  - position: 3
    shellQuote: false
    valueFrom: '-jar'
  - position: 4
    shellQuote: false
    valueFrom: /opt/snpEff/snpEff.jar
  - position: 5005
    prefix: ''
    shellQuote: false
    valueFrom: |-
      ${
          test = [].concat(inputs.in_variants)
          filename = test[0].path
          basename = filename.split('.').slice(0, filename.split('.').length - 1).join('.').replace(/^.*[\\\/]/, '')
          
          if (inputs.prefix)
          {
              basename = inputs.prefix.concat('.', basename)
          }
          if (inputs.output_format === "txt") {
              name = basename.concat(".snpEff_annotated.txt")
          } else if (inputs.output_format === "bed" || inputs.output_format === "bedAnn") {
              name = basename.concat(".snpEff_annotated.bed")
          } else {
              name = basename.concat(".snpEff_annotated.vcf")
          }
          return '> ' + name
      }
  - position: 5
    shellQuote: false
    valueFrom: '-nodownload'
  - position: 5
    shellQuote: false
    valueFrom: '-noLog'
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: |-
      ${
          if (inputs.mem_per_job) {
              if (inputs.mem_overhead_per_job)
              {
                  return inputs.mem_per_job + inputs.mem_overhead_per_job
              }
              else
              {
                  return inputs.mem_per_job + 100
              }
          } else {
              return 8192
          }
      }
    coresMin: 1
  - class: DockerRequirement
    dockerImageId: aae3dcb89b53
    dockerPull: 'images.sbgenomics.com/jrandjelovic/snpeff-4-3t:1'
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.configuration_file)
  - class: InlineJavascriptRequirement
    expressionLib:
      - |-
        var updateMetadata = function(file, key, value) {
            file['metadata'][key] = value;
            return file;
        };


        var setMetadata = function(file, metadata) {
            if (!('metadata' in file)) {
                file['metadata'] = {}
            }
            for (var key in metadata) {
                file['metadata'][key] = metadata[key];
            }
            return file
        };

        var inheritMetadata = function(o1, o2) {
            var commonMetadata = {};
            if (!Array.isArray(o2)) {
                o2 = [o2]
            }
            for (var i = 0; i < o2.length; i++) {
                var example = o2[i]['metadata'];
                for (var key in example) {
                    if (i == 0)
                        commonMetadata[key] = example[key];
                    else {
                        if (!(commonMetadata[key] == example[key])) {
                            delete commonMetadata[key]
                        }
                    }
                }
            }
            if (!Array.isArray(o1)) {
                o1 = setMetadata(o1, commonMetadata)
            } else {
                for (var i = 0; i < o1.length; i++) {
                    o1[i] = setMetadata(o1[i], commonMetadata)
                }
            }
            return o1;
        };

        var toArray = function(file) {
            return [].concat(file);
        };

        var groupBy = function(files, key) {
            var groupedFiles = [];
            var tempDict = {};
            for (var i = 0; i < files.length; i++) {
                var value = files[i]['metadata'][key];
                if (value in tempDict)
                    tempDict[value].push(files[i]);
                else tempDict[value] = [files[i]];
            }
            for (var key in tempDict) {
                groupedFiles.push(tempDict[key]);
            }
            return groupedFiles;
        };

        var orderBy = function(files, key, order) {
            var compareFunction = function(a, b) {
                if (a['metadata'][key].constructor === Number) {
                    return a['metadata'][key] - b['metadata'][key];
                } else {
                    var nameA = a['metadata'][key].toUpperCase();
                    var nameB = b['metadata'][key].toUpperCase();
                    if (nameA < nameB) {
                        return -1;
                    }
                    if (nameA > nameB) {
                        return 1;
                    }
                    return 0;
                }
            };

            files = files.sort(compareFunction);
            if (order == undefined || order == "asc")
                return files;
            else
                return files.reverse();
        };
      - |-

        var setMetadata = function(file, metadata) {
            if (!('metadata' in file)) {
                file['metadata'] = {}
            }
            for (var key in metadata) {
                file['metadata'][key] = metadata[key];
            }
            return file
        };

        var inheritMetadata = function(o1, o2) {
            var commonMetadata = {};
            if (!Array.isArray(o2)) {
                o2 = [o2]
            }
            for (var i = 0; i < o2.length; i++) {
                var example = o2[i]['metadata'];
                for (var key in example) {
                    if (i == 0)
                        commonMetadata[key] = example[key];
                    else {
                        if (!(commonMetadata[key] == example[key])) {
                            delete commonMetadata[key]
                        }
                    }
                }
            }
            if (!Array.isArray(o1)) {
                o1 = setMetadata(o1, commonMetadata)
            } else {
                for (var i = 0; i < o1.length; i++) {
                    o1[i] = setMetadata(o1[i], commonMetadata)
                }
            }
            return o1;
        };
'sbg:toolkit': SnpEff
'sbg:revisionsInfo':
  - 'sbg:revision': 0
    'sbg:modifiedBy': kogantit
    'sbg:modifiedOn': 1585846813
    'sbg:revisionNotes': Copy of admin/sbg-public-data/snpeff-4-3t-cwl1-0/10
'sbg:image_url': null
'sbg:cmdPreview': >-
  unzip -o /path/to/database/GRCh37.75.zip -d /opt/snpEff ; java -Xmx3072M -jar
  /opt/snpEff/snpEff.jar  -nodownload  -noLog GRCh37.75 
  path/to/variants/variants_file.vcf  > variants_file.snpEff_annotated.vcf
'abg:revisionNotes': 'cosmetic, label typo'
'sbg:license': GNU Lesser General Public License v3.0 only
'sbg:links':
  - id: 'http://snpeff.sourceforge.net/index.html'
    label: Homepage
  - id: 'https://github.com/pcingola/SnpEff'
    label: Source Code
  - id: 'http://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip'
    label: Download
  - id: 'http://snpeff.sourceforge.net/SnpEff_paper.pdf'
    label: Publication
  - id: 'http://snpeff.sourceforge.net/SnpEff_manual.html'
    label: Documentation
'sbg:toolAuthor': Pablo Cingolani/Broad Institue
'sbg:toolkitVersion': 4.3t
'sbg:projectName': dev-canine-workflow
'sbg:categories':
  - Annotation
  - VCF-Processing
  - CWL1.0
  - Utilities
'sbg:appVersion':
  - v1.0
'sbg:id': d3b-bixu/dev-canine-workflow/snpeff-4-3t-cwl1-0/0
'sbg:revision': 0
'sbg:revisionNotes': Copy of admin/sbg-public-data/snpeff-4-3t-cwl1-0/10
'sbg:modifiedOn': 1585846813
'sbg:modifiedBy': kogantit
'sbg:createdOn': 1585846813
'sbg:createdBy': kogantit
'sbg:project': d3b-bixu/dev-canine-workflow
'sbg:sbgMaintained': false
'sbg:validationErrors': []
'sbg:contributors':
  - kogantit
'sbg:latestRevision': 0
'sbg:publisher': sbg
'sbg:content_hash': a0f4b76065f3d40c95ed5d8fa3b3c9d9449d191951be62883efe2287040bd7c84
'sbg:copyOf': admin/sbg-public-data/snpeff-4-3t-cwl1-0/10
