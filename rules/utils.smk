#loading python libraries 
from snakemake.utils import validate
import pandas as pd
import yaml
from smart_open import open

##--- validate configuration file --##
validate(config, schema="../configuration/config.schema.yaml")

##--- load and validate protein sequences and hmmer protein domains files ---##
proteins = pd.read_csv(config["protein_table"], sep="\t", dtype = str).set_index("DB", drop=False)
proteins.index.names = ["Index"]
validate(proteins, schema = "../configuration/Protein_database.schema.yaml")

##--- load and validate genome sequences and annotations ---##
genomes = pd.read_csv(config["target_genomes"], sep="\t", dtype = str).set_index("Sample", drop=False)
genomes.index.names = ["Index"]
validate(genomes, schema = "../configuration/target_genomes.schema.yaml")

# Convert relative FASTA paths to absolute paths
genomes["FASTA"] = genomes["FASTA"].apply(os.path.abspath)

##--- helper functions ---##
#This function retrieves protein sequences and protein domains input files from proteins object
#Attribute information is also avaliable
def protein_DB_input(wildcards):
    return {
        "seq": proteins.loc[wildcards.db, "Sequences"], 
        "dom": proteins.loc[wildcards.db, "Domain"]
  }

def protein_min_length(wildcards):
    return {
        "min_length": proteins.loc[wildcards.db, "Min_length"]
    }

#This function retrieves genome seqences and annotations from genomes object
def genome_input(wildcards):
    return {
        "fasta": genomes.loc[wildcards.sample, "FASTA"]
    }
        
#This function returns species abbreviation   
def genome_key(wildcards):
    return{
        genomes.loc[wildcards.sample, "Key"]
    }

#Output functions for bitacora pipeline

def sequence_clusters_output(wildcards):
    return expand(
        "{outdir}/{algo}/{sample}/{db}/seq_cluster/{db}_genomic_proteins_trimmed_idseqsclustered.fasta",
        algo = ["GeMoMa", "Proximity"]
        sample=genomes['Sample'],
        db=proteins['DB'], 
        outdir=config["outdir"])

def Additional_filter_fasta(wildcards):
    return expand(
        "{outdir}/{algo}/{sample}/{db}/{db}_genomic_proteins_trimmed_idseqsclustered.fasta",
        algo = ["GeMoMa", "Proximity"]
        sample=genomes["Sample"],
        db=proteins["DB"],
        outdir=config["outdir"]
    )

def Additional_filter_gff(wildcards):
    return expand(
        "{outdir}/{algo}/{sample}/{db}/{db}_genomic_genes_trimmed_idseqsclustered.gff3",
        algo = ["GeMoMa", "Proximity"]
        sample=genomes["Sample"],
        db=proteins["DB"],
        outdir=config["outdir"]
    )