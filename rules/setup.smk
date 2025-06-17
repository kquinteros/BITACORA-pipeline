###--- create softlink to protein sequences and protein domains ---###
rule link_protein_data:
    input:
        unpack(protein_DB_input)
    output:
        db= config["outdir"] + "/{db}/{db}_db.fasta",
        hmm = config["outdir"] + "/{db}/{db}_db.hmm"
    params: 
         config['BITACORA'] + "/runBITACORA_command_line.sh"
    message:
        "Linking protein sequences and HMM domain profiles for Bitacora genome-mode analysis"
    shell:
        """
        cp {input.seq} {output.db}
        cp {input.dom} {output.hmm}
        chmod +x {params}
        """