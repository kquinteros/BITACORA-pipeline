###--- create softlink to protein sequences and protein domains ---###
rule link_protein_data:
    input:
        unpack(protein_DB_input)
    output:
        db= config["outdir"] + "/{db}_db.fasta",
        hmm = config["outdir"] + "/{db}_db.hmm"
    message:
        "Linking protein sequences and HMM domain profiles for Bitacora genome-mode analysis"
    shell:
        """
        echo "Copying protein databases for chemosensory {db}"
        cp {input.seq} {output.db}
        cp {input.dom} {output.hmm}
        echo "Successfully copied files"
        """