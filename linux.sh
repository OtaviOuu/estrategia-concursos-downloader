#!/bin/bash

set -e 

echo "🔧 Iniciando setup do projeto..."

if ! command -v python3 &> /dev/null
then
    echo "⚠️ Python3 não encontrado. Por favor, instale Python 3.10+ e tente novamente."
    exit 1
fi

if ! command -v uv &> /dev/null
then
    echo "⏬ Instalando uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

echo "📦 Instalando dependências com uv..."
uv sync  

gggggasfasdfsdffasfdsf
if [ -f ./src/main.py ]; then
    echo "🚀 Rodando main.py"
    python ./src/main.py
else
    echo "⚠️ main.py não encontrado."
fi
