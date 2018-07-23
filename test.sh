#!/bin/sh

#SBATCH --job-name=Test
#SBATCH --output=test.out
#SBATCH --error=test.err

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=GPUNodes
#SBATCH --gres=gpu:1
#SBATCH --gres-flags=enforce-binding

echo "Je suis un script bash et je m'exécute sur osirim"

# srun tf-py3 python3 "$HOME/Tuto/code.py"

srun tf-py3 /venv/bin/python code.py

