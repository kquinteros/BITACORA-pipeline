#loading python libraries 
from snakemake.utils import validate
import pandas as pd
import yaml
from smart_open import open

##--- validate configuration file --##
validate(config, schema="../configuration/config.schema.yaml")

##--- load and validate protein sequences and hmmer protein domains files ---##
proteins = pd.read_csv(config["protein_table"], sep="\t", dtype = str).set_index("Samples", drop=False)
proteins.index.names = ["Index"]
validate(proteins, schema = "../configuration/Protein_database.schema.yaml")

##--- load and validate genome sequences and annotations ---##
genomes = pd.read_csv(config["target_genomes"], sep="\t", dtype = str).set_index("Sample", drop=False)
genomes.index.names = ["Index"]
validate(genomes, schema = "../configuration/target_genomes.schema.yaml")

##--- helper functions ---##
#This function retrieves protein sequences and protein domains input files from proteins object
#Attribute information is also avaliable
def protein_DB_input(wildcards):
    return {
        "seq": proteins.loc[wildcards.sample, "Sequences"], 
        "dom": proteins.loc[wildcards.sample, "Domain"]
  }

#This function retrieves genome seqences and annotations from genomes object
def genome_input(wildcards):
    return {
        "fasta": genomes.loc[wildcards.sample, "FASTA"], 
    }
        
#This function returns species abbreviation   
def genome_key(wildcards):
    return{
        genomes.loc[wildcards.sample, "Key"]
    }

#Output functions for bitacora pipeline
def link_protein_data_output(wildcards):
    return expand("output/00_protein_sequences/{DB}_db.fasta", DB=proteins['Samples'])
def bitacora_output(wildcards):
    return expand("output/{sample}/bitacora_successful.txt", sample=genomes['Sample'])

    