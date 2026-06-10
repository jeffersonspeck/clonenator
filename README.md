# Beam Search Decision Tree — Visualizador Interativo

Aplicativo Flutter que demonstra como uma arvore de decisao se forma dinamicamente durante uma sessao no estilo Akinator, mantendo multiplas hipoteses em paralelo por meio de Beam Search para lidar com respostas incertas do usuario.

---

## Video de demonstracao

<!-- Cole abaixo o link do seu video no YouTube -->

**URL:** `https://www.youtube.com/watch?v=SEU_VIDEO_AQUI`

---

## Fundamentacao teorica

### ID3 e arvores de decisao

O algoritmo classico mais proximo deste projeto e o **ID3** (Iterative Dichotomiser 3), proposto por Ross Quinlan em 1986. O ID3 constroi arvores de decisao escolhendo, a cada no, o atributo que maximiza o ganho de informacao — medida derivada do conceito de entropia de Shannon:

```
Entropia(S) = -sum( $p_i$ * $log2$($p_i$) )

GanhoDeInformacao(S, A) = Entropia(S) - sum( |S_v|/|S| * Entropia(S_v) )
```

Neste projeto a logica e semelhante, mas simplificada: em vez de calcular entropia, o sistema escolhe a pergunta que produz a divisao mais equilibrada entre candidatos que tendem ao "sim" e candidatos que tendem ao "nao". A funcao de pontuacao da pergunta e:

```
splitScore(pergunta) = |positivos - negativos| + desconhecidos * 0.5
```

Quanto menor o score, mais equilibrada a divisao — portanto melhor a pergunta.

### Beam Search

O **Beam Search** e uma heuristica de busca em largura limitada amplamente usada em processamento de linguagem natural, traducao automatica e sistemas de recomendacao. Em vez de manter todas as hipoteses possiveis (busca em largura completa) ou apenas a melhor (busca gulosa), ele mantem as `k` melhores hipoteses simultaneamente — chamadas de *beam*.

Neste projeto cada *estado* da busca representa:

- o conjunto de candidatos ainda em disputa,
- as perguntas ja feitas,
- a penalidade acumulada por incerteza,
- o caminho de decisoes tomadas ate ali.

Quando o usuario responde "provavelmente sim" ou "provavelmente nao", o sistema **bifurca o estado atual em dois** — um tratando a resposta como afirmativa (penalidade baixa) e outro como negativa (penalidade alta) — e ambos continuam sendo avaliados em paralelo. Apenas os `beamWidth` melhores estados sobrevivem a cada rodada.

### Funcao de pontuacao dos estados

O estado com menor score e considerado o melhor caminho:

```
stateScore(estado) = |candidatos| + penalidade
```

A penalidade e acumulada conforme o tipo de resposta:

| Resposta do usuario         | Penalidade no caminho principal | Penalidade no caminho alternativo |
|-----------------------------|---------------------------------|-----------------------------------|
| Sim                         | 0.00                            | —                                 |
| Nao                         | 0.00                            | —                                 |
| Provavelmente sim           | 0.25                            | 1.00                              |
| Provavelmente nao           | 0.25                            | 1.00                              |
| Nao sei                     | 0.15                            | —                                 |
| Resposta contraditoria      | +2.00 (sem eliminar ninguem)    | —                                 |

---

## Diagrama de decisao

O diagrama abaixo mostra o fluxo de uma rodada completa, desde a escolha da pergunta ate a atualizacao dos estados no beam.

```
+---------------------------+
|   INICIO DA RODADA        |
|   beamWidth estados ativos|
+---------------------------+
             |
             v
+---------------------------+
|  Selecionar melhor estado |
|  (menor stateScore)       |
+---------------------------+
             |
             v
+---------------------------+
|  Escolher melhor pergunta |
|  (menor splitScore entre  |
|   perguntas nao feitas)   |
+---------------------------+
             |
             v
+---------------------------+
|  Exibir pergunta          |
|  ao usuario               |
+---------------------------+
             |
      +------+------+
      |             |
   CERTO        INCERTO
  (sim/nao)  (prob./nao sei)
      |             |
      v             v
+----------+  +-----------+
| 1 estado |  | 2 estados |
| novo     |  | novos:    |
| sem penl.|  | principal |
|          |  | + altern. |
+----------+  +-----------+
      |             |
      +------+------+
             |
             v
+---------------------------+
|  Ordenar todos os estados |
|  por stateScore           |
|  Manter apenas beamWidth  |
+---------------------------+
             |
             v
+---------------------------+
|  1 candidato restante?    |
|  ou perguntas esgotadas?  |
+---------------------------+
      |             |
     SIM           NAO
      |             |
      v             v
+----------+  +-----------+
| PALPITE  |  | proxima   |
| final    |  | rodada    |
+----------+  +-----------+
```

---

## Gabarito — Perguntas x Professores

As respostas abaixo representam o **gabarito do sistema**. O usuario pode responder com "provavelmente sim", "provavelmente nao" ou "nao sei" para introducir incerteza — mas o gabarito interno usa apenas Sim e Nao.

| Pergunta                                         | Ana | Bruno | Carla | Diego | Eduarda | Fabio | Gabriela | Henrique | Isabela | Jonas | Kamila | Leandro |
|--------------------------------------------------|-----|-------|-------|-------|---------|-------|----------|----------|---------|-------|--------|---------|
| Usa oculos?                                      | Sim | Nao   | Sim   | Nao   | Sim     | Nao   | Nao      | Sim      | Nao     | Sim   | Nao    | Sim     |
| Costuma falar bastante em publico?               | Nao | Sim   | Sim   | Nao   | Sim     | Sim   | Sim      | Nao      | Nao     | Sim   | Sim    | Nao     |
| Trabalha com tecnologia ou programacao?          | Sim | Sim   | Nao   | Sim   | Nao     | Nao   | Nao      | Nao      | Sim     | Nao   | Nao    | Sim     |
| Usa exemplos praticos ao explicar?               | Sim | Sim   | Nao   | Sim   | Nao     | Sim   | Sim      | Nao      | Sim     | Sim   | Nao    | Sim     |
| Pratica esporte com regularidade?                | Nao | Nao   | Sim   | Nao   | Sim     | Sim   | Sim      | Nao      | Sim     | Sim   | Nao    | Nao     |
| Tem habilidade artistica?                        | Nao | Nao   | Sim   | Nao   | Nao     | Sim   | Sim      | Sim      | Nao     | Nao   | Sim    | Nao     |
| Trabalha ou estuda na area de saude?             | Nao | Nao   | Nao   | Sim   | Sim     | Nao   | Sim      | Nao      | Nao     | Nao   | Nao    | Nao     |
| Prefere trabalhar sozinho a em equipe?           | Sim | Nao   | Sim   | Sim   | Nao     | Nao   | Nao      | Sim      | Sim     | Nao   | Nao    | Sim     |
| Cozinha com frequencia?                          | Nao | Sim   | Sim   | Nao   | Sim     | Nao   | Sim      | Sim      | Nao     | Sim   | Sim    | Nao     |
| Le livros com frequencia?                        | Sim | Sim   | Sim   | Sim   | Sim     | Nao   | Nao      | Nao      | Sim     | Sim   | Sim    | Sim     |
| Tem filhos?                                      | Nao | Sim   | Sim   | Nao   | Sim     | Nao   | Nao      | Sim      | Sim     | Sim   | Nao    | Nao     |
| Costuma chegar antes do horario?                 | Sim | Sim   | Nao   | Sim   | Nao     | Nao   | Sim      | Sim      | Sim     | Nao   | Sim    | Sim     |
| Usa redes sociais com frequencia?                | Nao | Sim   | Sim   | Nao   | Sim     | Sim   | Sim      | Nao      | Nao     | Sim   | Sim    | Nao     |
| Ja fez alguma viagem internacional?              | Sim | Nao   | Sim   | Sim   | Nao     | Sim   | Nao      | Nao      | Sim     | Nao   | Sim    | Sim     |
| Tem animal de estimacao?                         | Sim | Nao   | Sim   | Nao   | Sim     | Sim   | Sim      | Nao      | Nao     | Sim   | Sim    | Nao     |

---

## Estrutura de pastas

```
akinator_decision/
|
|-- pubspec.yaml                  Dependencias do projeto (Flutter + google_fonts)
|
|-- lib/
    |
    |-- main.dart                 Ponto de entrada. Inicializa o MaterialApp com o tema
    |                             e define a GameScreen como tela inicial.
    |
    |-- theme.dart                Paleta de cores, tipografia e utilitarios visuais.
    |                             Centraliza todas as decisoes de estilo: cores de fundo,
    |                             superficies, cores das respostas e metodos auxiliares
    |                             como answerColor(), answerLabel() e answerEmoji().
    |
    |-- models/
    |   |-- models.dart           Definicao de todos os tipos de dados do dominio:
    |                             UserAnswer (respostas do usuario),
    |                             ExpectedAnswer (gabarito do sistema),
    |                             Person, Question, DecisionState, GuessResult
    |                             e StepRecord (registro de cada rodada para o historico).
    |
    |-- data/
    |   |-- game_data.dart        Base de dados do jogo: lista de 12 professores (gamePeople)
    |                             e 15 perguntas (gameQuestions) com seus gabaritos.
    |                             Todos os gabaritos usam apenas ExpectedAnswer.yes ou
    |                             ExpectedAnswer.no — nunca probably ou unknown.
    |
    |-- engine/
    |   |-- decision_engine.dart  Algoritmo principal. Implementa o Beam Search:
    |   |                         - nextQuestion(): escolhe a pergunta que melhor divide
    |   |                           os candidatos restantes pelo splitScore.
    |   |                         - answerCurrentQuestion(): aplica a resposta a todos os
    |   |                           estados ativos, bifurca em caso de incerteza e descarta
    |   |                           os estados alem do beamWidth.
    |   |                         - guesses(): retorna os candidatos mais provaveis ordenados
    |   |                           pelo stateScore.
    |   |
    |   |-- game_controller.dart  Camada entre o algoritmo e a interface. Extende
    |                             ChangeNotifier para acionar rebuilds no Flutter.
    |                             Gerencia o ciclo de vida da partida (idle, playing,
    |                             guessing), monta o historico de StepRecord e
    |                             constroi as explicacoes textuais exibidas ao usuario.
    |
    |-- screens/
    |   |-- game_screen.dart      Tela principal do aplicativo. Exibe em sequencia:
    |                             tela de boas-vindas, grade de candidatos, painel de
    |                             hipoteses do Beam Search, card da pergunta atual com
    |                             botoes de resposta, historico expansivel de rodadas
    |                             e card de resultado final.
    |
    |-- widgets/
        |-- answer_buttons.dart   Cinco botoes de resposta (Sim, Nao, Provavelmente sim,
        |                         Provavelmente nao, Nao sei) com animacao de pressao
        |                         e cores derivadas do theme.dart.
        |
        |-- candidate_grid.dart   Grade visual de todos os professores. Candidatos ativos
        |                         aparecem destacados; eliminados aparecem com linha
        |                         cortada e opacidade reduzida. Anima a transicao
        |                         suavemente quando um candidato e eliminado.
        |
        |-- beam_visualizer.dart  Painel que exibe cada estado ativo do Beam Search:
        |                         quais candidatos pertencem ao estado, qual e a
        |                         penalidade acumulada e qual e o stateScore. O estado
        |                         principal recebe destaque visual.
        |
        |-- step_card.dart        Card colapsavel do historico. Ao expandir, mostra
                                  a resposta dada, a explicacao do que o algoritmo
                                  decidiu, a lista de candidatos antes e depois da
                                  rodada e os caminhos ativos na arvore naquele momento.
```

---

## Como executar

**Requisitos:** Flutter SDK 3.10 ou superior.

```bash
# Instalar dependencias
flutter pub get

# Rodar no navegador (Edge ou Chrome)
flutter run -d edge
flutter run -d chrome

# Rodar em dispositivo Android conectado
flutter run -d android

# Rodar no iOS (requer macOS)
flutter run -d ios
```

---

## Dependencias

| Pacote         | Versao  | Uso                                      |
|----------------|---------|------------------------------------------|
| flutter        | SDK     | Framework base                           |
| google_fonts   | ^6.1.0  | Tipografia Inter para a interface        |

---

## Referencia bibliografica

QUINLAN, J. R. **Induction of decision trees**. Machine Learning, v. 1, n. 1, p. 81-106, 1986.

RUSSELL, S.; NORVIG, P. **Artificial Intelligence: A Modern Approach**. 4. ed. Pearson, 2020. Cap. 3 (Busca em espacos de estados) e Cap. 18 (Aprendizado por arvores de decisao).
