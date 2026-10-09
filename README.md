<p align="center">
  <a href="https://norynhub.com/">
    <img src="https://norynhub.com/apple-touch-icon.png" alt="Noryn" width="128" />
  </a>
</p>

# noryn

Binário para usar uma Workstation. Cada release traz Linux, macOS e Windows.

O runtime desta linha é o número da tag, sem o `v`. A release `v1.3.0` é o binário `1.3.0`.

## Instalar

Baixe o arquivo do seu sistema na [release](https://github.com/norynhub/client/releases), confira `SHA256SUMS` e coloque o binário no `PATH`.

| Sistema | Arquivo |
| --- | --- |
| Linux x86_64 | `noryn-linux-amd64` |
| Linux arm64 | `noryn-linux-arm64` |
| macOS Intel | `noryn-darwin-amd64` |
| macOS Apple Silicon | `noryn-darwin-arm64` |
| Windows x86_64 | `noryn-windows-amd64.exe` |

```bash
chmod +x noryn-linux-amd64
sudo mv noryn-linux-amd64 /usr/local/bin/noryn
noryn version
```

No Windows, renomeie para `noryn.exe` ou chame o arquivo direto.

## Usar a Workstation example

```bash
noryn auth github --token "$GITHUB_TOKEN"
ver=$(curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github.raw" https://api.github.com/repos/norynhub/example/contents/channels/engineering/stable)
noryn install "example/engineering" --env-file .env
noryn run example/engineering --target cursor --projection temp --once
noryn run example/engineering --target codex --projection temp --once
noryn run example/engineering --target claude --projection temp --once
noryn run example/engineering --target opencode --projection temp --once
```

O token também pode vir de `NORYN_GITHUB_TOKEN` ou de `gh auth token`. Sem control plane, baixe o `.noryn` da release `engineering-v<versão>` em `norynhub/example` e rode `noryn install` no arquivo.

`--env-file` grava credenciais do operador fora do pacote. Chaves soltas entram, no `noryn run`, só no MCP que declara o nome. Para um servidor específico:

```bash
noryn mcp env set example/engineering firecrawl-mcp --env-file .env.firecrawl
noryn mcp env show example/engineering
```

`show` lista nomes, sem valores.

`noryn version` avisa quando uma release mais nova deste repositório pede outro binário. Para isso, defina `NORYN_HUB_TOKEN`.
