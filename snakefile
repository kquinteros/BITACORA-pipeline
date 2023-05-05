## Snakemake
##
## @Kevin Quinteros
##

#check minimum snakemake version utility 
from snakemake.utils import min_version

#####set minimum snakemakeversion####
min_version("5.30.1")

##--- Importing Configuration Files ---##
configfile: '03_config/config.yaml' 
        
#--- include rules ---#
include: '02_rules/common.smk' #contains input/output and helper functions. Additional output arrays and libraries defined
include: '02_rules/bitacora-pipeline.smk' #contains the main rules for bitacora pipeline
 
#universal rule that checks the output of every rule  
rule all:
    input:
        copy_protein_data_output,
        copy_genomic_data_output,
        gff2fasta_output,
        isoforms_output,
        bitacora_output
        