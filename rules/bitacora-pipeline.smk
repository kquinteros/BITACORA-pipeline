###--- run bitacora in genome mode---###   
rule bitacora:
    conda:
        os.path.join(workflow.basedir, config["env_bitacora"])
    input:
        unpack(genome_input),
        config["bitacora"] + "/runBITACORA_command_line.sh"
    output:
        config["outdir"] + "/{sample}/bitacora_successful.txt"
    params:
        BITA = os.path.join(workflow.basedir,config["BITACORA"]) # path to commandline script for bitacora
        mode = "genome", #bitacora mode
        DB = os.path.join(workflow.basedir,config["outdir"]), #path to folder containing databases
        name = genome_key, #prefix for output
        blast = config["use_blast"], #conduct BLASTP (T or F)
        algorithm = config["algorithm"], #Algorithm used to predict novel genes. Specify 'gemoma' or 'proximity'
        sp = os.path.join(workflow.basedir, config["scripts"]), #path to bitacora scripts 
        gp = config["GeMoMa"], #path to GeMoMa executable
        bp = config["blast"], #path to BLAST executable
        hp = config["hmmer"], #path hmmer executable
        e = config["evalue"], #e-value
        i = config["maxintron"], #maximum intron length 
        r = config["addition_filter"], #Conduct an additional filtering of the annotations if -r T. Specify 'T' or 'F' 
        l = config["min_length"], #Minimum length to retain identified genes
        z = config["retain_genes"], #Retain all annotated genes, without any clustering of identical copies
        c = config["clean_out"], #Clean output files
        outdir = config["outdir"] #output directory
    threads: config["cpus"] #number of threads avaliable per bitacora run
    message:
        "Running BITACORA in full mode"
    shell:
        """
        cd {params.outdir}
        {params.BITA}/runBITACORA_command_line.sh \
        -m {params.mode} -a {params.algorithm} -q {params.DB} -g {input.fasta} \
        -n {params.name} -sp {params.sp} -gp {params.gp} -bp {params.bp} \
        -hp {params.bp} -t {threads} -b {params.blast} -e {params.e} -i {params.i} -r {params.r} \
        -l {params.l} -z {params.z} -c {params.c}
        touch bitacora_successful.txt
        """
