# StudyMatch

O **StudyMatch** é um aplicativo Flutter inspirado na mecânica do Tinder, mas pensado para encontrar pessoas com interesses de estudo em comum. Ele foi criado para a disciplina de Desenvolvimento Mobile.

Você não precisa conhecer Flutter ou Android Studio para seguir este guia. Faça os passos na ordem e, sempre que aparecer um comando, copie exatamente como está.

## O que o aplicativo demonstra

- **Splash screen animada** com gradiente roxo, logo e a mensagem "Bem-vindo ao StudyMatch".
- **Onboarding** em blocos deslizáveis com as regras de segurança do app.
- **Login** com usuário fixo (`admin` / `123`) e botões simulados de Google e Apple.
- **Tema claro/escuro** com um botão único no topo que muda o app inteiro.
- Perfis de estudo de demonstração com interesses diferentes.
- Swipe para passar ou curtir um perfil, com cards estilo Tinder (tags em #hashtag, animação ao trocar de perfil).
- Match automático quando existem interesses em comum.
- Tela **"É um match!"** comemorativa (animação de entrada) com acesso ao chat.
- Chat bot simulado com indicador de digitação animado, avatar, horário das mensagens e conversa roteirizada por perfil.
- Filtro de segurança que bloqueia ofensas, palavrões, agressões em frases e variações com maiúsculas, acentos, pontos ou hífens.
- Denúncia que encerra o chat e informa que a conta será avaliada.
- Cadastro, consulta, edição e exclusão de assuntos de estudo.
- Navegação por rotas entre splash, onboarding, login, perfis, matches, chat, assuntos e perfil.

## Fluxo de telas

```text
Splash  →  Onboarding (regras)  →  Login  →  Perfis (swipe)  →  Match  →  Chat
                                                    ↑                       │
                                                    └──── Denúncia (24h) ◄──┘
```

1. **Splash:** tela de abertura animada; após ~3s segue para o onboarding.
2. **Onboarding/Políticas:** explica respeito, filtro de mensagens, denúncia e proteção de dados; botão **Próximo** (ou **Pular**) leva ao login.
3. **Login:** entre com `admin` / `123` (ou use os botões Google/Apple simulados) para chegar aos perfis.
4. **Perfis (Match/Swipe), Match, Chat:** o coração do app, descritos no roteiro abaixo.

## O que é necessário em outra máquina

Instale estes programas antes de abrir o projeto:

1. [Android Studio](https://developer.android.com/studio).
2. [Flutter SDK](https://docs.flutter.dev/get-started/install).
3. Um emulador Android configurado no Android Studio **ou** um celular Android com depuração USB ativada.

O Flutter já inclui o Dart; não é necessário instalar Dart separadamente.

> Dica: no Windows, aceite a opção de instalar o Android SDK e o Android Emulator durante a instalação do Android Studio.

## Parte 1 - Instalar e configurar o Flutter

### 1. Baixar o Flutter SDK

1. Abra o link de instalação do Flutter acima.
2. Baixe o Flutter para o sistema operacional da máquina (Windows, macOS ou Linux).
3. Extraia a pasta em um local simples, por exemplo:

   - Windows: `C:\src\flutter`
   - macOS/Linux: dentro da pasta pessoal, por exemplo `~/development/flutter`

Evite extrair dentro de `Arquivos de Programas` no Windows, pois permissões do sistema podem impedir atualizações.

### 2. Colocar o Flutter no PATH (Windows)

Isso permite usar o comando `flutter` no terminal.

1. Pesquise no menu Iniciar por **Variáveis de ambiente**.
2. Abra **Editar as variáveis de ambiente do sistema**.
3. Clique em **Variáveis de Ambiente**.
4. Em `Path`, clique em **Editar** e depois em **Novo**.
5. Adicione o caminho da pasta `bin` do Flutter. Exemplo:

   ```text
   C:\src\flutter\bin
   ```

6. Confirme todas as janelas com **OK**.
7. Feche e abra novamente o Android Studio ou o terminal.

No macOS/Linux, siga a orientação do instalador do Flutter para adicionar `flutter/bin` ao arquivo de perfil do terminal (`.zshrc`, `.bashrc` ou equivalente).

### 3. Conferir se o ambiente está pronto

Abra o PowerShell, Terminal ou o terminal interno do Android Studio e execute:

```bash
flutter doctor
```

O comando mostra uma lista de verificações. É normal aparecer algo pendente na primeira vez. Para este projeto, o importante é resolver o que estiver marcado em vermelho para:

- Flutter SDK
- Android toolchain
- Android Studio
- Dispositivo Android ou emulador

Se o terminal pedir para aceitar licenças do Android, execute:

```bash
flutter doctor --android-licenses
```

Responda `y` para aceitar cada licença e rode `flutter doctor` outra vez.

## Parte 2 - Configurar o Android Studio

### 1. Instalar os plugins Flutter e Dart

1. Abra o Android Studio.
2. Na tela inicial, clique em **Plugins**. Se já tiver um projeto aberto: `File > Settings > Plugins`.
3. Pesquise por **Flutter** e clique em **Install**.
4. Quando o Android Studio sugerir o plugin **Dart**, aceite a instalação.
5. Reinicie o Android Studio se ele pedir.

### 2. Conferir o Android SDK

1. Abra `File > Settings > Languages & Frameworks > Android SDK`.
2. Na aba **SDK Platforms**, instale uma versão Android marcada como recomendada.
3. Na aba **SDK Tools**, confirme que estão instalados:

   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android SDK Platform-Tools
   - Android Emulator

4. Clique em **Apply** e aguarde os downloads terminarem.

## Parte 3 - Baixar e abrir este projeto

Escolha apenas uma das opções abaixo.

### Opção A - Clonar pelo Git (recomendado)

No terminal, execute:

```bash
git clone https://github.com/Diogo-Augusto14/study.git
cd study
```

### Opção B - Baixar como ZIP

1. Abra o repositório: <https://github.com/Diogo-Augusto14/study>.
2. Clique em **Code > Download ZIP**.
3. Extraia o arquivo ZIP em uma pasta simples, por exemplo `Documentos\study`.

### Abrir no Android Studio

1. No Android Studio, clique em **Open**.
2. Selecione a pasta principal `study` — ela é a pasta que contém o arquivo `pubspec.yaml`.
3. Não abra apenas a pasta `android`; abra a pasta principal do projeto Flutter.
4. Aguarde o Android Studio indexar os arquivos.
5. Se aparecer uma mensagem para instalar pacotes, aceite. Caso não apareça, abra o terminal na parte inferior do Android Studio e execute:

   ```bash
   flutter pub get
   ```

Esse comando baixa as dependências necessárias para o projeto.

## Parte 4 - Criar e iniciar um emulador Android

### Criar o emulador

1. No Android Studio, abra `Tools > Device Manager`.
2. Clique em **Create device**.
3. Escolha um aparelho da categoria **Phone**, como Pixel 6 ou Pixel 7, e clique em **Next**.
4. Escolha uma imagem de sistema Android marcada como **Recommended**. Se houver botão **Download**, clique nele e aguarde.
5. Clique em **Next** e depois em **Finish**.
6. No Device Manager, clique no botão de iniciar (ícone de play) ao lado do aparelho criado.

A primeira inicialização pode demorar alguns minutos. Espere aparecer a tela inicial do Android no emulador antes de executar o projeto.

### Se o emulador não abrir

Os casos mais comuns são:

- **Computador lento ou mensagem sobre virtualização:** reinicie o computador, entre na BIOS/UEFI e habilite virtualização (Intel VT-x ou AMD-V). Depois, no Windows, confirme que os recursos de virtualização recomendados pelo Android Studio estão habilitados.
- **Tela preta:** feche o emulador pelo Device Manager e inicie novamente. Se continuar, use o menu do dispositivo e escolha **Cold Boot Now**.
- **Pouca memória:** crie um emulador com um aparelho mais simples ou feche programas pesados.

## Parte 5 - Rodar o aplicativo no Android Studio

1. Com o emulador aberto, localize o seletor de dispositivo na barra superior do Android Studio.
2. Selecione o emulador criado.
3. Abra o arquivo `lib/main.dart`.
4. Clique no botão verde de **Run** (triângulo) na barra superior, ou pressione `Shift + F10` no Windows/Linux (`Control + R` ou o atalho mostrado pelo Android Studio no macOS).
5. Aguarde o primeiro build. Na primeira execução pode levar mais tempo porque o Gradle baixa componentes do Android.

Quando o aplicativo abrir, use os botões na parte inferior para navegar entre **Perfis**, **Matches** e **Perfil**.

### Rodar pelo terminal (alternativa)

Com o emulador ligado e dentro da pasta do projeto, execute:

```bash
flutter devices
flutter run
```

O primeiro comando deve listar o emulador. O segundo instala e abre o aplicativo.

## Parte 6 - Atualizar o app enquanto ele está aberto

Você não precisa fechar e abrir o projeto a cada alteração.

- **Hot Reload:** salva uma alteração visual e atualiza a tela rapidamente. No Android Studio, clique no ícone de raio ou use o botão Hot Reload.
- **Hot Restart:** reinicia o estado do aplicativo sem fazer todo o build Android novamente. Use quando alterar lógica, listas de teste ou estado da tela.
- **Run novamente:** use apenas se Hot Reload/Restart não resolver ou depois de alterar arquivos nativos na pasta `android`.

> Os perfis, matches e conversas deste projeto são dados de demonstração em memória. Ao fazer Hot Restart ou fechar o app, o estado volta ao início. Isso é esperado na versão atual.

## Roteiro de demonstração para a apresentação

Este é um fluxo curto para provar as principais funcionalidades:

1. Abra o app e mostre a **splash screen** animada; em seguida ela avança para o **onboarding**.
2. Passe pelos blocos de **regras de segurança** e toque em **Próximo/Começar** (ou **Pular**) para chegar ao **login**.
3. No login, entre com usuário `admin` e senha `123` (ou mostre os botões **Google/Apple** simulados). Você pode demonstrar o erro digitando uma senha errada para ver o aviso **"Usuário inválido"**.
4. Toque no ícone de tema no topo para alternar entre **claro e escuro** e mostrar que vale para todas as telas.
5. Na aba **Perfis**, no primeiro perfil **Luiza**, toque no coração ou arraste o card para a direita.
6. Explique que o código compara os interesses do usuário com os interesses do perfil. Luiza possui `Física` e `Doramas` em comum, então a tela **É um match!** aparece.
7. Toque em **Ir para o chat**.
8. Envie uma mensagem respeitosa, por exemplo: `Topa revisar Física esta semana?`.
9. Mostre o indicador **Luiza está digitando...** e aguarde 2 segundos pela resposta do bot simulado (a conversa avança de forma roteirizada a cada mensagem).
10. Digite uma mensagem ofensiva de teste, por exemplo: `Você é um idiota`.
11. Mostre que o botão de enviar é bloqueado imediatamente e o aviso de segurança aparece.
12. Toque na bandeira no topo do chat para denunciar o perfil.
13. Mostre a tela: **"Usuário denunciado. Nossa equipe avaliará a conta nas próximas 24h."**
14. Volte aos perfis e mostre a tela **Meus assuntos**, onde é possível cadastrar, editar e excluir temas de estudo.

## Rodar testes e verificar o código

Antes de entregar, use o terminal do Android Studio na pasta principal do projeto:

```bash
flutter analyze
flutter test
```

- `flutter analyze` procura problemas de código e avisos importantes.
- `flutter test` executa os testes automáticos do app, incluindo match, filtro de segurança, resposta do chat e denúncia.

O resultado esperado termina com algo parecido com:

```text
All tests passed!
```

## Problemas comuns e soluções

### "flutter" não é reconhecido como comando

O Flutter não está no PATH ou o terminal ainda não foi reiniciado. Revise a seção **Parte 1 - Colocar o Flutter no PATH** e abra um novo terminal.

### Nenhum dispositivo aparece para executar

1. Abra `Tools > Device Manager`.
2. Inicie o emulador pelo botão de play.
3. Aguarde a tela inicial do Android aparecer.
4. Rode `flutter devices` no terminal para conferir se ele foi reconhecido.

### Erro ao executar `flutter pub get`

1. Confirme que o terminal está na pasta que possui `pubspec.yaml`.
2. Verifique a conexão com a internet, pois o Flutter pode baixar dependências na primeira execução.
3. Execute novamente:

   ```bash
   flutter clean
   flutter pub get
   ```

### Erro sobre licenças do Android

Execute:

```bash
flutter doctor --android-licenses
```

Aceite todas as opções e depois rode `flutter doctor`.

### Erro de Gradle ou download muito demorado

Na primeira vez, o Gradle baixa arquivos grandes. Espere o download terminar e não feche o Android Studio. Se falhar por conexão, tente novamente quando a internet estiver estável.

### O app abre, mas a tela não mudou depois de editar o código

Use **Hot Restart**. Se ainda não mudar, pare a execução pelo botão quadrado e clique em **Run** novamente.

## Estrutura principal do projeto

```text
study/
├── lib/
│   └── main.dart          # Telas, match, chat, filtro e denúncia
├── test/
│   └── widget_test.dart   # Testes automáticos
├── android/               # Configuração Android gerada pelo Flutter
├── pubspec.yaml           # Nome e dependências do projeto
└── README.md              # Este guia
```

## Tecnologias utilizadas

- Flutter
- Dart
- Material Design 3
- Android Studio e Android Emulator

## Principais desafios encontrados

Criar uma demonstração de match e chat que parecesse natural sem exigir dois celulares conectados, mantendo o bloqueio de mensagens e a denúncia imediatos.
