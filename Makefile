# Diretórios
VENV_DIR=.venv
ENGINEERING_DIR=src/engineering
ANALYTICS_DIR=src/analytics

# Caminho do Python dentro do ambiente virtual
PYTHON=$(VENV_DIR)/Scripts/python.exe

# Cria o ambiente virtual e instala dependências
.PHONY: setup
setup:
	@echo "Removendo ambiente virtual antigo (se existir)..."
	rm -rf $(VENV_DIR)
	@echo "Criando novo ambiente virtual..."
	python -m venv $(VENV_DIR)
	@echo "Instalando dependências..."
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -r requirements.txt

# Coleta de dados brutos
.PHONY: collect
collect:
	@echo "Executando scripts de engenharia..."
	$(PYTHON) $(ENGINEERING_DIR)/get_data.py

# ETL das features
.PHONY: etl
etl:
	@echo "Executando pipeline de feature store..."
	$(PYTHON) $(ANALYTICS_DIR)/pipeline_analytics.py

# Predição
.PHONY: predict
predict:
	@echo "Executando script de predição..."
	$(PYTHON) $(ANALYTICS_DIR)/predict_fiel.py

# Executa tudo em sequência
.PHONY: all
all: setup collect etl predict