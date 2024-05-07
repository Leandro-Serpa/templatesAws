#!/bin/bash
pasta_principal="./"
branch_destino="main"
diretorio_atual=$(pwd)
for diretorio in "$pasta_principal"/*; do
    if [ -d "$diretorio" ]; then
    echo "Atualizando $diretorio"
    cd "$diretorio" && git fetch && git checkout "$branch_destino" && git pull origin "$branch_destino"
    cd "$diretorio_atual" || exit
    fi
done