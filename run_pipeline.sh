#!/bin/bash
#SBATCH --job-name=hgsoc_nf
#SBATCH --account=amc-general
#SBATCH --output=log_hgsoc_nf.log
#SBATCH --error=errorhgsoc_nf.err
#SBATCH --time=08:00:00
#SBATCH --partition=amilan
#SBATCH --qos=normal
#SBATCH --ntasks-per-node=64
#SBATCH --nodes=1 

set -eo pipefail

# --------------------------------------------------
# 0) Resolve project root (directory of this script)
# --------------------------------------------------
PRJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${PRJ_DIR}"

# --------------------------------------------------
# 1) Ensure that Nextflow is installed
# --------------------------------------------------
if ! command -v nextflow &> /dev/null
then
    echo "Error: Nextflow is not installed or not found in your PATH."
    echo "Please install Nextflow and ensure it's accessible in your system's PATH."
    echo "You can typically install it with: curl -s https://get.nextflow.io | bash"
    echo "Then move the 'nextflow' executable to a directory in your PATH (e.g., ~/bin or /usr/local/bin)."
    exit 1 # Exit the script with an error code
fi

# --------------------------------------------------
# 2) Load Conda and activate env_hgsoc
# --------------------------------------------------
source "$(conda info --base)/etc/profile.d/conda.sh"

ENV_YML="${PRJ_DIR}/env_hgsoc.yml"

# create the env once; reuse afterwards
if ! conda env list | grep -q '^env_hgsoc '; then
    echo "••• Creating Conda environment env_hgsoc"
    conda env create -f "${ENV_YML}"
fi
conda activate env_hgsoc

# --------------------------------------------------
# 3) Run the pipeline
# --------------------------------------------------
echo "••• Launching Nextflow"
nextflow run main.nf -profile local -resume
# or nextflow run main.nf -profile slurm -resume, if on HPC

echo "••• Pipeline finished 🎉"