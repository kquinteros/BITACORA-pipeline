###--- run bitacora in genome mode using gemoma---###   
rule bitacora_proximity:
    conda:
        os.path.join(workflow.basedir, config["env-GeMoMA"])
    input:
        unpack(genome_input),
        db= config["outdir"] + "/{db}/{db}_db.fasta",
        hmm = config["outdir"] + "/{db}/{db}_db.hmm"
    output:
         config["outdir"] + "/Proximity/{sample}/{db}/{db}tblastn_parsed_list_genomic_positions_nogff_filtered.bed",
         fasta = config["outdir"] + "/Proximity/{sample}/{db}/{db}_genomic_proteins_trimmed.fasta",
         gff =  config["outdir"] + "/Proximity/{sample}/{db}/{db}_genomic_genes_trimmed.gff3"
    params:
        BITA = os.path.join(workflow.basedir, config["BITACORA"]), # path to commandline script for bitacora
        mode = "genome", #bitacora mode
        DB = os.path.join(workflow.basedir, config["outdir"] + "/{db}/"), #path to folder containing databases
        name = genome_key, #prefix for output
        blast = config["use_blast"], #conduct an additional BLASTP search in addition to HMMER to validate novel genes
        algorithm = 'proximity', #Algorithm used to predict novel genes. Specify 'gemoma' or 'proximity'
        sp = os.path.join(workflow.basedir, config["scripts"]), #path to bitacora scripts 
        gp = config["GeMoMa"], #path to GeMoMa executable
        bp = config["blast"], #path to BLAST executable
        hp = config["hmmer"], #path hmmer executable
        e = config["evalue"], #e-value
        i = config["maxintron"], #maximum intron length 
        r = "F", #Conduct an additional filtering of the annotations if -r T. Specify 'T' or 'F' 
        l = 30, #Minimum length to retain identified genes
        z = "T", #Retain all annotated genes, without any clustering of identical copies (if T ignore -r and -l)
        c = config["clean_out"], #Clean output files
        outdir = config["outdir"] + "/Proximity/{sample}/" #output directory
    threads: 
        config["cpus"] #number of threads avaliable per bitacora run
    message:
        "Running BITACORA in genome mode using proximity algorithm for sample {wildcards.sample} with database {wildcards.db}"
    log:
        config["outdir"] + "/Proximity/{sample}/bitacora_{db}.out"
    shell:
        """
         cd {params.outdir}

        # Extract file names only
        fasta_file={wildcards.db}/$(basename "{output.fasta}")
        gff_file={wildcards.db}/$(basename "{output.gff}")

        # Run main command
        echo "Starting BITACORA for sample {wildcards.sample} with DB {wildcards.db} at $(date) \n " > bitacora_{wildcards.db}.out
        {params.BITA}/runBITACORA_command_line.sh \
        -m {params.mode} -a {params.algorithm} -q {params.DB} -g {input.fasta} \
        -n {params.name} -sp {params.sp} -gp {params.gp} -bp {params.bp} \
        -hp {params.bp} -t {threads} -b {params.blast} -e {params.e} -i {params.i} -r {params.r} \
        -l {params.l} -z {params.z} -c {params.c}
        echo "Sample {wildcards.sample} with DB {wildcards.db} finished at $(date) \n" >> bitacora_{wildcards.db}.out
        cat {params.name}_genecounts_genomic_proteins.txt >> bitacora_{wildcards.db}.out

        
        # Touch output files if empty or missing (using filename only)
        if [ ! -s "$fasta_file" ]; then touch "$fasta_file"; fi
        if [ ! -s "$gff_file" ]; then touch "$gff_file"; fi
        """