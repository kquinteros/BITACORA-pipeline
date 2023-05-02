##--- validate configuration file --##
validate(config, schema="../03_config/config.schema.yaml")

##--- load and validate protein sequences and hmmer protein domains files ---##
proteins = pd.read_csv(config["protein_table"], sep="\t", dtype = str).set_index("Samples", drop=False)
proteins.index.names = ["Index"]
validate(proteins, schema = "../03_config/Protein_database.schema.yaml")

##--- load and validate genome sequences and annotations ---##
genomes = pd.read_csv(config["target_genomes"], sep="\t", dtype = str).set_index("Sample", drop=False)
genomes.index.names = ["Index"]
validate(genomes, schema = "../03_config/target_genomes.schema.yaml")

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
        "gff": genomes.loc[wildcards.sample, "GFF"],
        "cds": genomes.loc[wildcards.sample, "CDS"],
        "faa": genomes.loc[wildcards.sample, "FAA"]
    }
        
#This function returns species abbreviation   
def genome_key(wildcards):
    return{
        genomes.loc[wildcards.sample, "Key"]
    }

#Output functions for bitacora pipeline
#rule 1
def copy_protein_data_output(wildcards):
    return expand("04_output/{DB}_db.fasta", DB=proteins['Samples'])
#rule 2
def copy_genomic_data_output(wildcards):
    return expand("04_output/{sample}/{sample}.gff", sample=genomes['Sample'])
#rule 3
def gff2fasta_output(wildcards):
    return expand("04_output/{sample}/{sample}_convert.pep.fasta", sample=genomes['Sample'])
#rule 4
def isoforms_output(wildcards):
    return expand("04_output/{sample}/{sample}_convert.pep_noiso.fasta", sample=genomes['Sample'])
#rule 5
def bitacora_output(wildcards):
    return expand("04_output/{sample}/bitacora_successful.txt", sample=genomes['Sample'])

    