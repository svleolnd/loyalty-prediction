# Loyalty Predict

Construindo uma solução de Data Science!


# Índice

- [Objetivo](#objetivo)
- [Sobre o Ecosistema](@sobre-o-ecosistema)
- [Ações](#ações)
- [Etapas](#etapas)
- [Fonte de Dados](#fontes-de-dados)

## Objetivo

Identificar perda ou ganho de engajamento dos usuários da comunidade TEO ME WHY, e prever qual o comportamento do usuário após 28 dias que ele entrou na base

## Sobre o Ecosistema 

O cadastro do usuário é feito quando ele utiliza do recurso !join, por uma primeira e unica vez, o que gera um ID de usuário no sistema de pontos.

O engajamento é medido através do sistema de pontos (cubos) que os usuários recebem ao assistirem e enviarem mensagems no chat das lives do Teo realizadas na plataforma da twich. 

O recurso !presente, assina a lista de presença em cada dia de live e gera mais cubos ao usuário.

A plataforma de cursos, lista todos os cursos disponiveis no youtube do TEO, que ao logar com a twitch gera um outro ID de usuário que pode ou não ser vinculado ao ID gerado no !join mencionado acima.

Quando vinculado, cada curso sinalizado como finalizado gera novos pontos que podem ser resgatados ou não pelo usuário.

A base de usuários ativos só considera usuários que participam ou participaram da live em algum momento.


## Tipos de usuários

- Curioso
- Fiel
- Reborn
- Reconquistado
- Turista
- Desencantado

## Ações

- Métricas gerais do TMW;
- Definição do Ciclo de Vida dos usuários;
- Análise de Agrupamento dos diferentes perfís de usuários;
- Criar modelo de Machine Learning que detecte a perda ou ganho de engajamento;
- Incentivo por meio de pontos para usuários mais engajados;

## Etapas

- Entendimento do negócio;
- Extração dos dados;
- Entendimento dos dados;
- Definição das variáveis;
- Criação das Feature Stores;
- Treinamento do modelo;
- Registro do modelo no MLFlow;
- Criação de App para Inferência em Tempo Real;


## Fontes de Dados

- [Sistema de Pontos](https://www.kaggle.com/datasets/teocalvo/teomewhy-loyalty-system)
- [Plataforma de Cursos](https://www.kaggle.com/datasets/teocalvo/teomewhy-education-platform)



