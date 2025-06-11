###--- create softlink to protein sequences and protein domains ---###
rule link_protein_data:
    input:
        unpack(protein_DB_input)
    output:
        db= config["outdir"] + "/{id}_db.fasta",
        hmm = config["outdir"] + "/{id}_db.hmm"
    message:
        "Linking protein sequences and HMM domain profiles for Bitacora genome-mode analysis"
    shell:
        """
        ln -sf {input.seq} {output.db}
        ln -sf {input.dom} {output.hmm}
        """