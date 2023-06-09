###--- copy to protein sequences and protein domains ---###
rule copy_protein_data:
    input:
        unpack(protein_DB_input)
    output:
        db="04_output/{sample}_db.fasta",
        hmm="04_output/{sample}_db.hmm"
    message:
        "Copying protein sequences and hmm domain profiles to the bitacora full-mode analysis folder"
    shell:
        """
        cp {input.seq} {output.db}
        cp {input.dom} {output.hmm} 
        """
###--- copy genomic data to output directory ---###        
rule copy_genomic_data:
    input:
        unpack(genome_input)
    output:
        fas = "04_output/{sample}/{sample}.fasta",
        gff = "04_output/{sample}/{sample}.gff"
    message:
        "Copying protein sequences and hmm domain profiles to the bitacora full-mode analysis folder"
    shell:
        """
        cp {input.fasta} {output.fas}
        cp {input.gff} {output.gff} 
        """ 
###--- convert gff to protein sequences ---###
rule gff2fasta:
    input:
        gff = "04_output/{sample}/{sample}.gff",
        genome = "04_output/{sample}/{sample}.fasta"
    params:
        prefix = "{sample}_convert",
        tools = config["tools"],
        work_dir = "04_output/{sample}"
    output:
        "04_output/{sample}/{sample}_convert.pep.fasta"
    message:
        "Using bitacora script to convert gff file extract CDS sequences" 
    conda:
        config['env-bitacora']
    shell:
        """
        cd {params.work_dir}
        perl ../../{params.tools}/gff2fasta_v3.pl ../../{input.genome} ../../{input.gff} {params.prefix}
        """
        
###--- remove protein isoforms ---###
rule isoforms:
    input:
        gff = "04_output/{sample}/{sample}.gff",
        faa = "04_output/{sample}/{sample}_convert.pep.fasta"
    params:
        tools = config["tools"],
        out = "04_output/{sample}/{sample}_isoforms.log"
    output:
        "04_output/{sample}/{sample}_convert.pep_noiso.fasta"
    message:
        "Script to cluster genes (longest gene as representative) in overlapping positions(being putative isoforms or bad-annotations). It uses the positions in CDS fields for a gene, it is more precise than using the mRNA field, but it takes long to run with big gffs"
    shell:
        "perl {params.tools}/exclude_isoforms_fromfasta_usingcdsfield.pl {input.gff} {input.faa} > {params.out}"
        
###--- run bitacora in full mode ---###   
rule bitacora_full:
    input:
        fasta = "04_output/{sample}/{sample}.fasta", #genome
        gff = "04_output/{sample}/{sample}.gff", #annotation
        no_isoforms = "04_output/{sample}/{sample}_convert.pep_noiso.fasta" #protein sequences with no isoforms
    output:
        "04_output/{sample}/bitacora_successful.txt"
    params:
        BITA = "../../" + config["BITACORA"], #commandline script for bitacora
        mode = "full", #bitacora mode
        DB = "../", #path to folder containing databases
        name = genome_key, #prefix for output
        blast = config["use_blast"], #conduct BLASTP (T or F)
        algorithm = config["algorithm"], #Algorithm used to predict novel genes. Specify 'gemoma' or 'proximity'
        sp = "../../" + config["scripts"], #path to bitacora scripts 
        gp = "../../" + config["GeMoMa"], #path to GeMoMa executable
        bp = config["blast"], #path to BLAST executable
        hp = config["hmmer"], #path hmmer executable
        e = config["evalue"], #e-value
        i = config["maxintron"], #maximum intron length 
        r = config["addition_filter"], #Conduct an additional filtering of the annotations if -r T. Specify 'T' or 'F' 
        l = config["min_length"], #Minimum length to retain identified genes
        z = config["retain_genes"], #Retain all annotated genes, without any clustering of identical copies
        c = config["clean_out"], #Clean output files
        outdir = "04_output/{sample}" #output directory
    threads: config["num_threads"] #number of threads avaliable per bitacora run
    message:
        "Running BITACORA in full mode"
    conda:
        config['env-bitacora']
    shell:
        """
        cd {params.outdir}
        {params.BITA}/runBITACORA_command_line.sh -m {params.mode} -a {params.algorithm} -q {params.DB} -g ../../{input.fasta} -f ../../{input.gff} -p ../../{input.no_isoforms} -n {params.name} -sp {params.sp} -gp {params.gp} -bp {params.bp} -hp {params.bp}  -t {threads} -b {params.blast} -e {params.e} -i {params.i} -r {params.r} -l {params.l} -z {params.z} -c {params.c}
        touch bitacora_successful.txt
        """
