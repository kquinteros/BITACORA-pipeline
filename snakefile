## Snakemake
##
## @Kevin Quinteros
##

#check minimum snakemake version utility 
from snakemake.utils import min_version

#####set minimum snakemakeversion####
min_version("5.30.1")

##--- Importing Configuration Files ---##
configfile: 'configuration/config.yaml' 
        
#--- include rules ---#
include: 'rules/utils.smk' #contains input/output and helper functions. Additional output arrays and libraries defined
include: 'rules/setup.smk' #contains setup rules
include: 'rules/bitacora-gemoma.smk' #contains the main rules for bitacora pipeline using GeMoMA algorithm
include: 'rules/bitacora-proximity.smk' #contains the main rules for bitacora pipeline using Proximity algorithm

#universal rule that checks the output of every rule  
rule all:
    input:
        copy_protein_domains_output,
        copy_protein_data_output,
        bitacora_gemoma_output,
        bitacora_proximity_output
        