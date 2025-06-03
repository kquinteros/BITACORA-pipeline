# BITACORA-SNAKEMAKE-PIPELINE

This pipeline runs BITACORA in “genome mode,” requiring a genome assembly along with a curated database of protein sequences and corresponding HMM domain profiles for targeted annotation of chemosensory gene families.

You can find more information about Bitacora on their [GitHub repo](https://github.com/molevol-ub/bitacora).

Please make sure to cite the original Bitacora paper when using this pipeline

Vizueta, J., Sánchez-Gracia, A., Rozas, J. (2020). BITACORA: A comprehensive tool for the identification and annotation of gene families in genome assemblies. Molecular Ecology Resources. 20: 1445-1452. doi:10.1111/1755-0998.13202.

## Getting started
Users need to be familiar with [Conda](https://docs.conda.io/en/latest/) package management system and [Snakemake](https://snakemake.readthedocs.io/en/stable/) workflow management system. It's recommended that users have a dedicated snakemake environment. We have provided some commandline prompts (assuming conda is installed) for the installation of Snakmake.

```python 
conda install -n base -c conda-forge mamba
conda activate base
mamba create -c conda-forge -c bioconda -n snakemake snakemake
conda activate snakemake
snakemake --help
```

## Setting up configuration file
The ```configuration/config.yaml``` file allows you to adjust BITACORA parameters. Currently, all parameters are set to the default values. You can read the BITACORA documentation for more information. 

```python
# non-slurm profile defaults
use-conda: True
printshellcmds: True

##--- Protein sequence, protein domains and target genomes --##
protein_table: 'configuration/protein_database.tsv'
target_genomes: 'configuration/target_genomes.tsv'

##--- Path To Executable And Dependencies ---##
bitacora_repo_url: "https://github.com/YourUsername/BITACORA.git"
BITACORA: "bin/bitacora" #PATH to BITACORA commandline script, if error check params for rule "bitacora_full" in 02_rules/bitacora-pipeline.smk
scripts: "bin/bitacora/Scripts" #Path to BITACORA Scripts directory, if error check params for rule "bitacora_full" in 02_rules/bitacora-pipeline.smk
GeMoMa: "$CONDA_PREFIX/bin/GeMoMa" #Path to GeMoMa executable jar file, if error check params for rule "bitacora_full" in 02_rules/bitacora-pipeline.smk
tools: "bin/bitacora/Scripts/Tools" #Bitacora tools
blast: "$CONDA_PREFIX/bin/" #Path to BLAST executable
hmmer: "$CONDA_PREFIX/bin/" #Path to HMMER executable

##--- setting for BITACORA ---##
use_blast: "T" #conduct BLASTP (T or F)
algorithm: "gemoma" #Algorithm used to predict novel genes. Specify 'gemoma' or 'proximity'
maxintron: 15000 #Maximum length of an intron if using proximity algorithm
addition_filter: "T" #Conduct an additional filtering of the annotations if -r T. Specify 'T' or 'F' 
evalue: 1e-5 #Evalue for BLAST and HMMER
min_length: 30 #Minimum length to retain identified genes
retain_genes: "F" #Retain all annotated genes, without any clustering of identical copies
clean_out: "T" #Clean output files
outdir: ""

##--- computational resources ---##
cpus: 48 #number of threads avaliable per bitacora run 

##--- conda environments --##
env-GeMoMA: "envs/GeMoMa.yaml"
```

## Input data

1. ```00_data/00_protein_sequences``` contains curated protein sequences for five different gene families of insect chemosensory gene families. You can use your own files for your specific gene families. Just be sure to put files within this folder. 

2. ```00_data/01_protein_domains``` contain HMM profiles which are found in InterPro or PFAM databases associated to known protein domains.

3. ```00_data/02_target_genome``` contains genome assemblies and their associated genome annotations. You can place your own genomes (fasta) and annotations (gff) here. 


### Input data configuration files

1. ```configuration/target_genomes.tsv``` This file is necessary for the snakemake workflow. Edit the table to your needs. Just be sure to us sequential sample ID for the "Sample" column if you have more than one target genome. 

| Sample | Key  | Species         | FASTA                                                                       | 
|--------|------|-----------------|-----------------------------------------------------------------------------|
| S001   | Dmel | D. melanogaster | 00_data/02_target_genome/Drosophila_melanogaster.BDGP6.dna.chromosome.2R.fa |

2. ```configuration/protein_database.tsv``` This file is necessary for the snakemake workflow. Edit the table to your needs. Just be sure to us sequential sample ID for the "Samples" column. 

| Samples | Gene_family                   | Domain                                  | Sequences                                 |
|---------|-------------------------------|-----------------------------------------|-------------------------------------------|
| P1      | Olfactory Receptors           | 00_data/01_protein_domains/7tm_6.hmm    | 00_data/00_protein_sequences/OR_db.fasta  |
| P2      | Gustatory Receptors           | 00_data/01_protein_domains/Trehalose_recp.hmm    | 00_data/00_protein_sequences/GR_tre_db.fasta  |
| P3      | Gustatory Receptors           | 00_data/01_protein_domains/7tm_7.hmm    | 00_data/00_protein_sequences/GR_7tm7_db.fasta  |
| P4      | Chemosensory Binding Proteins | 00_data/01_protein_domains/OS-D.hmm     | 00_data/00_protein_sequences/CSP_db.fasta |
| P5      | Odorant Binding Proteins      | 00_data/01_protein_domains/PBP_GOBP.hmm | 00_data/00_protein_sequences/OBP_db.fasta |
| P6      | Ionotropic Receptors          | 00_data/01_protein_domains/Lig_chan.hmm | 00_data/00_protein_sequences/IR_db.fasta  |

## Run snakemake workflow

Be sure you are in the BITACORA-pipeline directory. Activate your snakemake environment. 

```
cd /PATH/TO/BITACORA-pipeline/
conda activate snakemake 
snakemake -s snakefile --use-conda 
```
Some workflows can take a few hours to run depending on the size of the  target genome and the number of sequences in your protein database. In that case, you may want to run snakemake workflow in the background. 

```
nohup snakemake -s snakefile --use-conda > bitacora_fullmode.out 2>&1 &
```
