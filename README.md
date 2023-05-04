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
addition_filter: "T" #Conduct an additional filtering of the annotations if -r T. Specify 'T' or 'F' 
evalue: 1e-3 #Evalue for BLAST and HMMER
min_length: 30 #Minimum length to retain identified genes
tools: "bitacora/Scripts/Tools" #Bitacora tools
retain_genes: "T" #Retain all annotated genes, without any clustering of identical copies
clean_out: "T" #Clean output files
```

## Protein databases
This repositor