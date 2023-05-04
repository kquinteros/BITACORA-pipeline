# BITACORA-pipeline

Snakemake pipeline for identification and annotation of Insect Chemosensory gene families in genome assemblies using BITACORA. This pipeline is set up to run BITACORA in "full mode" which requires a genome assembly and genome annotation file. 

## Getting started
1. Users need to be familiar with [Conda](https://docs.conda.io/en/latest/) package management system and [Snakemake](https://snakemake.readthedocs.io/en/stable/) workflow management system. It's recommended that users have a dedicated snakemake environment. We have provided some commandline prompts (assuming conda is installed) for the installation of Snakmake.
```python 
conda install -n base -c conda-forge mamba
conda activate base
mamba create -c conda-forge -c bioconda -n snakemake snakemake
conda activate snakemake
snakemake --help
```
2. Clone BITACORA-pipeline repository. 
```
cd /PATH/TO/DESIRED/DIRECTORY
git clone https://github.com/kquinteros/BITACORA-pipeline.git
```
3. Clone BITACORA repository within the BITACORA-pipeline directory. Read BITACORA computational requirement and documentation [here](https://github.com/molevol-ub/bitacora). 
```
cd /PATH/TO/BITACORA-pipeline/
git clone https://github.com/molevol-ub/bitacora.git
```
   BITACORA repository can also be cloned outside of the ```BITACORA-pipeline/```. In that case create a softlink within the BITACORA-pipeline
```
cd /PATH/TO/DESIRED/DIRECTORY/
git clone https://github.com/molevol-ub/bitacora.git
cd /PATH/TO/BITACORA-pipeline/
ln -s /PATH/TO/bitacora-repository/ bitacora
```
4. Download [GeMoMa v1.9](http://www.jstacs.de/download.php?which=GeMoMa) zip file within the BITACORA-pipeline directory. 

```
cd /PATH/TO/BITACORA-pipeline/
mkdir GeMoMa-1/
cd GeMoMa-1/
wget -O GeMoMa.zip http://www.jstacs.de/download.php?which=GeMoMa
unzip GeMoMa.zip
```
   As mentioned above GeMoMA can also be installed outside of the ```BITACORA-pipeline/```. You'll just need to create a softline to to the GeMoMa install directory. 
```
cd /PATH/TO/DESIRED/DIRECTORY/
mkdir GeMoMa/
cd GeMoMa/
wget -O GeMoMa.zip http://www.jstacs.de/download.php?which=GeMoMa
unzip GeMoMa.zip
cd /PATH/TO/BITACORA-pipeline/
ln -s /PATH/TO/GeMoMA/ GeMoMa/
```   
## Setting up configuration file
The ```03_config/config.yaml``` file allows you to adjust BITACORA parameters. Currently, all parameters are set to the default values. You can read the BITACORA documentation for more information. 

```python
##--- Path To Executable And Dependencies ---#
BITACORA: "bitacora" #PATH to BITACORA commandline script, if error check params for rule "bitacora_full" in 02_rules/bitacora-pipeline.smk
scripts: "bitacora/Scripts" #Path to BITACORA Scripts directory, if error check params for rule "bitacora_full" in 02_rules/bitacora-pipeline.smk
GeMoMa: "GeMoMa/GeMoMa-1.9.jar" #Path to GeMoMa executable jar file, if error check params for rule "bitacora_full" in 02_rules/bitacora-pipeline.smk
tools: "bitacora/Scripts/Tools" #Bitacora tools
blast: "$CONDA_PREFIX/bin/" #Path to BLAST executable
hmmer: "$CONDA_PREFIX/bin/" #Path to HMMER executable

##--- setting for BITACORA ---#
use_blast: "T" #conduct BLASTP (T or F)
maxintron: 15000 #Maximum length of an intron
algorithm: "gemoma" #Algorithm used to predict novel genes. Specify 'gemoma' or 'proximity'
addition_filter: "T" #Conduct an additional filtering of the annotations if True. Specify 'T' or 'F' 
evalue: 1e-3 #Evalue for BLAST and HMMER
min_length: 30 #Minimum length to retain identified genes
tools: "bitacora/Scripts/Tools" #Bitacora tools
retain_genes: "T" #Retain all annotated genes, without any clustering of identical copies
clean_out: "T" #Clean output files

##--- computational resources ---#
num_threads: 10 #number of threads avaliable per bitacora run 
```

## Input data

1. ```00_data/00_protein_sequences``` contains curated protein sequences for five different gene families of insect chemosensory gene families. You can use your own files for your specific gene families. Just be sure to put files within this folder. 

2. ```00_data/01_protein_domains``` contain HMM profiles which are found in InterPro or PFAM databases associated to known protein domains.

3. ```00_data/01_protein_domains``` contains genome assemblies and their associated genome annotations. You can place your own genomes (fasta) and annotations (gff) here. 


### Input data configuration files

1. ```target_genomes.tsv``` This file is necessary for the snakemake workflow. Edit the table to your needs. Just be sure to us sequential sample ID for the "Sample" column if you have more than one target genome. 

| Sample | Key  | Species         | FASTA                                                                       | GFF                                                                                     |
|--------|------|-----------------|-----------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| S001   | Dmel | D. melanogaster | 00_data/02_target_genome/Drosophila_melanogaster.BDGP6.dna.chromosome.2R.fa | 00_data/02_target_genome/rosophila_melanogaster.BDGP6.95.chromosome.2R.reformatted.gff3 |

2. ```03_config/protein_database.tsv``` This file is necessary for the snakemake workflow. Edit the table to your needs. Just be sure to us sequential sample ID for the "Samples" column. 

| Samples | Gene_family                   | Domain                                  | Sequences                                 |
|---------|-------------------------------|-----------------------------------------|-------------------------------------------|
| P1      | Olfactory Receptors           | 00_data/01_protein_domains/7tm_6.hmm    | 00_data/00_protein_sequences/OR_db.fasta  |
| P2      | Gustatory Receptors           | 00_data/01_protein_domains/7tm_7.hmm    | 00_data/00_protein_sequences/GR_db.fasta  |
| P3      | Chemosensory Binding Proteins | 00_data/01_protein_domains/Lig_chan.hmm | 00_data/00_protein_sequences/CSP_db.fasta |
| P4      | Odorant Binding Proteins      | 00_data/01_protein_domains/OS-D.hmm     | 00_data/00_protein_sequences/OBP_db.fasta |
| P5      | Ionotropic Receptors          | 00_data/01_protein_domains/PBP_GOBP.hmm | 00_data/00_protein_sequences/IR_db.fasta  |

## Run snakemake workflow

Be sure you are in the BITACORA-pipeline directory. Activate your snakemake environment. 

```
cd /PATH/TO/BITACORA-pipeline/
conda activate snakemake 
snakemake -s snakefile --cores {Number_Cores} --use-conda 
```
Some jobs can take a few hours to run depending on the size of the  target genome and the number of sequences in your protein database. In that case, you may want to run snakemake workflow in the background. 

```
nohup snakemake -s snakefile --cores {Number_Cores} --use-conda > bitacora_fullmode.out 2>&1 &
```