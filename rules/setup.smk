###--- create softlink to protein sequences and protein domains ---###
rule link_protein_data:
    input:
        unpack(protein_DB_input)
    output:
        db= config["outdir"] + "/{sample}_db.fasta",
        hmm = config["outdir"] + "/{sample}_db.hmm"
    message:
        "Linking protein sequences and HMM domain profiles for Bitacora genome-mode analysis"
    shell:
        """
        ln -sf {input.seq} {output.db}
        ln -sf {input.dom} {output.hmm}
        """
###--- down github repo for BITACORA ---###
rule download_bitacora:
    input:
        db= config["outdir"] + "/{sample}_db.fasta",
    output:
        config["bitacora"] + "runBITACORA_command_line.sh"  # or any file that confirms it's downloaded
    params:
        config["bitacora_repo_url"]
    message:
        "Cloning BITACORA from GitHub if not already present"
    shell:
        """
        if [ ! -d bin/bitacora ]; then
            git clone {params} {output}
        fi
        """