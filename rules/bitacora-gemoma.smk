###--- run bitacora in genome mode using gemoma---###   
rule bitacora_gemoma:
    conda:
        os.path.join(workflow.basedir, config["env-GeMoMA"])
    input:
        unpack(genome_input)
    output:
         success_flag = config["outdir"] + "/GeMoMa/{sample}/bitacora_gemoma_successful.txt"
    params:
        BITA = os.path.join(workflow.basedir, config["BITACORA"]), # path to commandline script for bitacora
        mode = "genome", #bitacora mode
        DB = os.path.join(workflow.basedir,config["outdir"]), #path to folder containing databases
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
        outdir = config["outdir"] + "/GeMoMA/{sample}/" #output directory
    threads: 
        config["cpus"] #number of threads avaliable per bitacora run
    message:
        "Running BITACORA in genome mode using GeMoMa"
    log: 
        config["outdir"] + "/GeMoMa/{sample}/" +"log.out"
    shell:
        """
        cd {params.outdir}
        {params.BITA}/runBITACORA_command_line.sh \
        -m {params.mode} -a {params.algorithm} -q {params.DB} -g {input.fasta} \
        -n {params.name} -sp {params.sp} -gp {params.gp} -bp {params.bp} \
        -hp {params.bp} -t {threads} -b {params.blast} -e {params.e} -i {params.i} -r {params.r} \
        -l {params.l} -z {params.z} -c {params.c}
        touch bitacora_gemoma_successful.txt
        """



