###--- create softlink to protein sequences and protein domains ---###
rule link_protein_data:
    input:
        unpack(protein_DB_input)
    output:
        db= config["outdir"] + "/{db}_db.fasta",
        hmm = config["outdir"] + "/{db}_db.hmm"
    params: 
         config['BITACORA'] + "/runBITACORA_command_line.sh"
    message:
        "Linking protein sequences and HMM domain profiles for Bitacora genome-mode analysis"
    shell:
        """
        ln -s {input.seq} {output.db}
        ln -s {input.dom} {output.hmm}
        chmod +x {params}
        """