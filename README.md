# BITACORA-pipeline

Snakemake pipeline for identification and annotation of Insect Chemosensory gene families in genome assemblies using BITACORA. This pipeline is set up to run BITACORA in "full mode" which requires a genome assembly and genome annotation file. 

## Dependencies
1. Users need to be familiar with [Conda](https://docs.conda.io/en/latest/) package management system and [Snakemake](https://snakemake.readthedocs.io/en/stable/) workflow management system. Both conda and snakemake need to be installed. It's recommended that users have a dedicated snakemake environment.
```python 
conda install -n base -c conda-forge mamba
conda activate base
mamba create -c conda-forge -c bioconda -n snakemake snakemake
conda activate snakemake
snakemake --help
```
2. 
3.


## Protein databases
This repositor