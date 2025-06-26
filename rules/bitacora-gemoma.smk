###--- run bitacora in genome mode using gemoma---###   
rule bitacora_gemoma:
    conda:
        os.path.join(workflow.basedir, config["env-GeMoMA"])
    input:
        unpack(genome_input),
        db= config["outdir"] + "/{db}/{db}_db.fasta",
        hmm = config["outdir"] + "/{db}/{db}_db.hmm"
    output:
         bed = config["outdir"] + "/GeMoMa/{sample}/{db}/{db}tblastn_parsed_list_genomic_positions_nogff_filtered.bed",
         fasta = config["outdir"] + "/GeMoMa/{sample}/{db}/{db}_genomic_proteins_trimmed.fasta",
         gff =  config["outdir"] + "/GeMoMa/{sample}/{db}/{db}_genomic_genes_trimmed.gff3"
    params:
        BITA = os.path.join(workflow.basedir, config["BITACORA"]), # path to commandline script for bitacora
        mode = "genome", #bitacora mode
        DB = os.path.join(workflow.basedir, config["outdir"] + "/{db}/"), #path to folder containing database
        name = genome_key, #prefix for output
        blast = config["use_blast"], #conduct an additional BLASTP search in addition to HMMER to validate novel genes
        algorithm = 'gemoma', #Algorithm used to predict novel genes. Specify 'gemoma' or 'proximity'
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
        outdir = config["outdir"] + "/GeMoMa/{sample}/" #output directory
    threads: 
        config["cpus"] #number of threads avaliable per bitacora run
    message:
        "Running BITACORA in genome mode using GeMoMa for sample {wildcards.sample} with database {wildcards.db}"
    log:
        config["outdir"] + "/GeMoMa/{sample}/bitacora_{db}.out"
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

rule identify_similar_sequence_clusters_gemoma:
    conda:
        os.path.join(workflow.basedir, config["env-GeMoMA"])
    input:
        fasta = config["outdir"] + "/GeMoMa/{sample}/{db}/{db}_genomic_proteins_trimmed.fasta"
    output:
        config["outdir"] + "/GeMoMa/{sample}/{db}/seq_cluster/{db}_genomic_proteins_trimmed_idseqsclustered.fasta"
    params:
        tools = os.path.join(workflow.basedir, config["tools"]),
        dir = config["outdir"] + "/GeMoMa/{sample}/{db}/seq_cluster/", #Directory for output
        length = lambda wildcards: protein_min_length(wildcards)["min_length"], #Minimum length to retain identified genes
        ident =  config["identity_percentage"] #Percent of identity to filter sequences
    threads:
        config["cpus"] #Threads to use in blastp search
    shell:
        """
        #mkdir output direcotry
        mkdir -p {params.dir}

        #check if input file is empty
        if [[ ! -s {input.fasta} ]]; then
            echo "Skipping: {input.fasta} is empty."
            touch "{output}"
        else
        cd {params.dir}
        echo "Running sequence clustering for {wildcards.sample} with DB {wildcards.db}"
        file=$(basename "{input.fasta}")
        ln -s ../"$file" "$file"
        perl {params.tools}/identify_similar_sequence_clusters.pl "$file" {params.length} {params.ident} {threads}
        rm -f "$file" #remove symlink
        fi
        """

rule additional_filter_gemoma:
    conda:
        os.path.join(workflow.basedir, config["env-GeMoMA"])
    input:
        fasta = config["outdir"] + "/GeMoMa/{sample}/{db}/{db}_genomic_proteins_trimmed.fasta",
        gff =  config["outdir"] + "/GeMoMa/{sample}/{db}/{db}_genomic_genes_trimmed.gff3"
    output:
        fasta = config["outdir"] + "/GeMoMa/{sample}/{db}/{db}_genomic_proteins_trimmed_idseqsclustered.fasta",
        gff = config["outdir"] + "/GeMoMa/{sample}/{db}/{db}_genomic_genes_trimmed_idseqsclustered.gff3"
    params:
        tools =  os.path.join(workflow.basedir, config["tools"]), #Path to bitacora helper tools
        dir = config["outdir"] + "/GeMoMa/{sample}/{db}/", #Directory for output
        length = lambda wildcards: protein_min_length(wildcards)["min_length"], #Minimum length to retain identified genes
        ident = config["identity_percentage"] #Percent of identity to filter sequences
    threads:
        config["cpus"] #Threads to use in blastp search
    shell:
        """
        # Check if input file is empty
        if [[ ! -s {input.fasta} ]]; then
            echo "Skipping additional filtering gemoma: {input.fasta} is empty."
            touch {output.fasta}
            touch {output.gff}
        else
            cd {params.dir}
            echo "Running additional filtering for {wildcards.sample} with DB {wildcards.db}"
            file=$(basename "{input.fasta}")
            gff_file=$(basename "{input.gff}")
            ln -s ../"$file" "$file"
            ln -s ../"$gff_file" "$gff_file"
            perl {params.tools}/exclude_similar_sequences_infasta_andgff.pl ../"$file" ../"$gff_file" {params.length} {params.ident} {threads}
            rm -f "$file" #remove symlink
            rm -f "$gff_file" #remove symlink
        fi
        """