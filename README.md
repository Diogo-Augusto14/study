# StudyMatch

Aplicativo Flutter com tema de "Tinder de estudos": a pessoa descobre assuntos em cards, arrasta para passar ou salva aqueles que quer estudar.

## Objetivo

Tornar a escolha de um novo assunto de estudo mais simples e visual, além de permitir que cada pessoa cadastre e organize os próprios assuntos.

## Tecnologias

- Flutter e Dart
- Material Design 3

## Funcionalidades

- Descoberta de assuntos com swipe ou botões de passar/salvar
- Cadastro, listagem, edição e exclusão de assuntos
- Perfis de estudo de demonstração com interesses diferentes
- Match automático quando existem interesses em comum
- Tela de match com acesso ao chat
- Chat bot simulado: indicador de digitação e resposta automática após 2 segundos
- Filtro de segurança que bloqueia ofensas, palavrões, agressões em frases e variações com maiúsculas, acentos, pontos ou hífens
- Denúncia que encerra a conversa e informa o prazo de avaliação
- Lista de matches para retomar uma conversa
- Perfil com indicadores simples
- Navegação por rotas nomeadas

## Telas

1. Descobrir perfis
2. Meus assuntos (listagem)
3. Novo assunto
4. Editar assunto
5. Meus matches
6. Perfil
7. É um match
8. Chat seguro
9. Confirmação de denúncia

## Como executar

```bash
flutter pub get
flutter run
```

## Desafios encontrados

Criar uma demonstração de match e chat que parecesse natural sem exigir dois celulares conectados, mantendo o bloqueio de mensagens e a denúncia imediatos.
