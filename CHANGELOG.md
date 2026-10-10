# Changelog

Versões do binário `noryn`. A tag git usa o prefixo `v`.

## 1.8.0

- `install` lê a chave da organização de `.noryn/tenant-keys/<org>.key` no
  monorepo quando nada foi passado e nada está guardado no escopo. Enquanto só
  quem é da Noryn instala estas Workstations, isso dispensa carregar o arquivo
  à mão em cada máquina; quem não tem acesso ao monorepo recebe 404 e cai na
  mensagem que diz como importar a chave. Chave já guardada nunca é reescrita,
  pela mesma regra que vale para pino de chave pública.

Quando existir portal de distribuição, essas chaves saem do git e precisam ser
**trocadas**, não apenas apagadas: o que entrou no histórico fica.
`.noryn/tenant-keys/README.md` registra isso ao lado dos arquivos.

## 1.7.0

Instalar ficou um comando. `install org/nome` só sabia resolver pelo
marketplace do control plane, e control plane hospedado não existe: quem
recebia a entrega tinha de achar o caminho do `.noryn` dentro do repositório,
baixar à mão, copiar a chave pública, pinar e só então instalar.

- `install org/nome` resolve no repositório da entrega quando o control plane
  não responde. Lê `release.json` para a versão e o caminho do artefato,
  confere o `sha256` publicado ao lado dele, e fixa a chave de `release.pub`
  quando nada está fixado para aquele id. O nome do repositório é convenção:
  `norynhub/<org>`.
- `install --tenant-key <arquivo>` guarda a chave que abre o payload da
  organização no mesmo comando. Ela é lida e conferida antes do download:
  errar o caminho depois de 80 MB é desperdício.
- O cliente ganha instalador de uma linha, publicado junto da release:
  `curl -fsSL https://raw.githubusercontent.com/norynhub/client/main/install.sh | sh`.
  Detecta sistema e arquitetura, confere o `sha256` contra o `SHA256SUMS`
  publicado e recusa sem instalar nada quando não bate. `NORYN_BIN` escolhe o
  diretório e um argumento fixa a tag.
- O `INSTALL.md` de cada release passa a liderar com esse caminho.

Fixar a chave na primeira instalação é anunciado na saída, porque é decisão de
confiança, e nunca sobrescreve pino existente. O passo manual que isto
substitui era copiar a chave do mesmo repositório, então não se perde garantia
nenhuma, só digitação.

## 1.6.0

- `noryn run --project <pasta>` projeta na pasta que você escolher em vez da
  pasta de sessão. A projeção carrega a configuração do agente e nenhum
  código, e harness lê `AGENTS.md` e `.cursor/` da raiz do workspace aberto;
  sem isso, usar a Workstation no próprio repositório não tinha caminho, e
  `noryn dev --project` é comando de autor, ausente do cliente.

  Não vira dono da pasta: confere os conflitos todos antes de escrever o
  primeiro arquivo, recusa sem sobrescrever nada seu, e no encerramento remove
  só o que escreveu. Diretório que já tinha conteúdo fica de pé. Recusa junto
  com `--projection fuse`, que esconderia a pasta enquanto a sessão durasse.
- A estação da eadskill passa a declarar `docker`, `npx` e `lightpanda`. Os
  MCPs `eadskill-atlassian`, `firecrawl-mcp` e `lightpanda` executam esses
  três, e nenhum estava declarado: numa máquina nova o harness subia e os
  servidores falhavam em silêncio.

Um bundle de control plane não apaga mais chave pinada. `refreshTrust` gravava
as chaves do bundle no mesmo `trust/keys.json` do pino, então sincronizar
confiança contra qualquer control plane alcançável substituía em silêncio a
chave que alguém tinha pinado à mão, e o pacote do publisher passava a dar
"assinatura inválida", que é a mensagem de adulteração, para um problema de
procedência de chave.

- Pino e cópia do control plane passam a morar em arquivos separados:
  `trust/keys.json` guarda o que foi pinado, `trust/bundle-keys.json` o que o
  control plane mandou. Na verificação o pino vence.
- As chaves do bundle entram só no escopo em que o comando está operando.
  Antes uma operação de projeto escrevia também no home do usuário e mudava a
  confiança de todas as outras instalações da máquina.
- `noryn trust remove <keyId>` apaga um pino. Pinar a chave errada acontece, e
  sem isto só dava para editar o JSON à mão.
- `noryn trust add|remove|list` aceitam `--scope`, como install: a Workstation
  pode estar instalada em escopo de projeto e a chave que a verifica precisa
  poder morar ao lado dela.
- `noryn trust list` diz a origem de cada chave, pinada ou do control plane. A
  procedência era exatamente a informação que faltava.
- A recusa por assinatura passa a sugerir conferir a procedência da chave em
  vez de só dizer que a assinatura é inválida.

Migração: quem já tem `trust/keys.json` com chaves copiadas de um control
plane continua com elas como pino, e pino vence. Se alguma for de outra
origem que não quem publicou o pacote, `noryn trust remove <keyId>` resolve.

## 1.5.0

A Workstation instalada passa a executar. Até aqui `install` guardava o pacote,
conferia a assinatura e nada mais: `noryn run` só sabia carregar a Workstation
do código-fonte do monorepo, então na máquina de quem recebeu o pacote o
comando morria em "raiz Noryn não encontrada" com a estação instalada e
verificada ao lado.

- `noryn run`, `mcp`, `skill`, `capability` e `hook` abrem o pacote instalado
  quando não há código-fonte. A CEK do payload é desembrulhada pelo control
  plane mediante lease, o conteúdo é materializado num diretório temporário só
  para a leitura e apagado em seguida. Código-fonte continua na frente: na
  máquina de quem desenvolve, rodar usa a edição e não a cópia instalada.
- Abrir o pacote é onde a entitlement passa a ser cobrada. Ter o arquivo não
  basta; sem lease válida o payload não abre.
- A CEK aberta fica em cache cifrada com a chave local, para a segunda
  execução não depender de rede. Antes o cache guardava a árvore em claro, que
  custava mais do que o próprio pacote (106 MB para um de 80 MB) e deixava o
  conteúdo decifrado em disco ao lado do pacote cifrado.
- O pacote passa a registrar de qual ref veio cada dependência, e a levar
  plugin e MCP que moram fora do diretório da Workstation. Sem isso um ref
  `@componente` não resolvia depois de instalado e um plugin de registry saía
  do build sem entrar no pacote.
- `PublicUserDisplayName` usava o próprio tipo em vez do receptor e descartava
  a configuração de quem chamou.

E a entrega publicada passa a abrir. A CEK do payload é embrulhada
simetricamente com `tenant/<org>`, mas o workflow criava um KMS novo por
execução: a chave morria com o runner, e o pacote publicado ficava
verificável e inabrível por qualquer cliente, inclusive por quem o publicou.
O `release.pub` também mudava a cada execução, então quem pinou a chave de uma
release não verificava a seguinte.

- O workflow de entrega restaura o KMS de um secret e para se ele não existir,
  em vez de assinar com chave nova. `./scripts/release-kms.sh` cria o estado,
  exporta para o secret e mostra a chave da organização.
- `noryn tenant import|list` guarda no cliente a chave que abre os pacotes de
  uma organização. É o modo local do formato, o mesmo papel que `noryn trust`
  cumpre para assinatura. A ordem para abrir passa a ser: CEK em cache,
  control plane, chave local.
- `noryn-control tenant-key <org>` mostra a chave para entregar. Fica fora do
  servidor de propósito: por rota HTTP, um token administrativo vazado valeria
  acesso ao conteúdo de todos os pacotes.
- O INSTALL.md de cada release ensina o passo da chave. Ela não entra no
  repositório da entrega, pelo mesmo motivo do `.env`.
- `EnsureTenant` e `TenantKey` passam a resolver sob a mesma trava. Com duas
  seções críticas havia uma janela em que o id voltava e a chave não estava
  mais no mapa.

E instalar qualquer Workstation fica simples. O pacote não leva interpretador,
compilador nem CLI de terceiro, e não deveria; o que faltava era a Workstation
poder dizer de que ferramentas ela depende. Até aqui isso existia por plugin,
só no `validate` do autor, sem versão mínima, sem mapa por sistema e sem link:
quem instalava descobria na primeira falha de execução.

- `requirements` no `workstation.json` declara comando, versão mínima, motivo,
  link e instalador por sistema operacional. Vai também no manifesto assinado,
  então `noryn inspect` mostra antes de instalar e `noryn requirements` lê sem
  precisar da chave que abre o payload.
- `noryn requirements [org/nome] [--install] [--yes]` confere e instala o que
  falta, pedindo permissão a cada item. Não reinstala o que já está lá, não
  executa instalador que exige root (imprime a linha com `sudo`) e não oferece
  gerenciador que não está no PATH, caso em que sobra o link.
- Depois de instalar, confere de novo em vez de confiar na saída zero do
  gerenciador, que com frequência retorna sucesso sem deixar o comando no
  PATH.
- `install` e `update` imprimem o relatório ao final quando algo falta, sem
  derrubar a instalação: o pacote já está em disco e verificado.
- A estação da eadskill declara git, gh, go, python e uv.
- `install` passa a conferir o runtime mínimo do manifesto, que era gravado e
  nunca lido. Um binário velho instalava um pacote que não sabe abrir e a
  falha aparecia só no `run`, longe da causa. Valor que não parseia em três
  campos não bloqueia.

## 1.4.0

O Observatory passa a servir uma empresa de verdade, e não um cenário escrito
no código.

- O pátio mostra a organização inteira, lida do provedor de código: quem está
  na org aparece, o time de lá é o squad e o cargo é o papel. Quem não está em
  time nenhum vai para a doca "Sem squad" em vez de sumir da tela.
- As estações de uma organização compartilham o mesmo pátio por um relay que
  repassa eventos cifrados e não consegue abri-los. Quem publica não escolhe o
  próprio nome: o relay carimba o login que ele mesmo autenticou.
- `noryn observatory mesh new|show|import` cuida da chave do grupo.
- Terminal do harness dentro da página, e também numa janela do sistema. A
  página manda um identificador de pessoa; o comando é montado no servidor e é
  sempre `noryn run`, nunca um shell.
- Uma interrogação em cada símbolo do pátio explica o que ele representa e de
  onde o dado vem.
- `noryn run` emite o ciclo de vida da sessão, e o hook emite chamada de
  ferramenta e recusa de política. Nunca prompt, código ou conteúdo de tela.

Correções:

- O manifesto da Workstation passa a ser gravado de forma atômica. Uma queda
  no meio da escrita deixava o cliente sem `workstation.json`.
- O comando do terminal usava o id da máquina e montava uma referência que não
  existe; agora vem da Workstation instalada.
- A marca de ensaio passa a valer antes da primeira resposta do servidor:
  havia uma janela servindo dado simulado sem dizer que era simulado.

## 1.3.0

Primeira release do binário de cliente.

- Instala, atualiza e remove uma Workstation já publicada.
- Entra com GitHub (`noryn auth github`) e abre a sessão no harness (`noryn run`).
- Serve a ponte MCP, o hook de policy e as capabilities.
- Não inclui autoria: `init`, `add`, `dev`, `build`, `validate`, `release`.
