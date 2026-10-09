# Changelog

Versões do binário `noryn`. A tag git usa o prefixo `v`.

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
