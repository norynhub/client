#!/usr/bin/env sh
# Instala o cliente noryn.
#
#   curl -fsSL https://raw.githubusercontent.com/norynhub/client/main/install.sh | sh
#
# Sem argumento pega a release mais nova. Para fixar uma versão:
#
#   curl -fsSL .../install.sh | sh -s v1.6.0
#
# O binário vai para NORYN_BIN, ou ~/.local/bin. O script confere o sha256
# contra o SHA256SUMS publicado antes de instalar: um download truncado
# viraria "assinatura inválida" na primeira Workstation, que é um diagnóstico
# ruim de um problema simples.
set -eu

repo="norynhub/client"
bin_dir="${NORYN_BIN:-${HOME}/.local/bin}"
tag="${1:-}"

erro() { printf '%s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || erro "curl é necessário para baixar o cliente"

case "$(uname -s)" in
  Linux)  os=linux ;;
  Darwin) os=darwin ;;
  *) erro "sistema $(uname -s) sem binário publicado; veja https://github.com/${repo}/releases" ;;
esac
case "$(uname -m)" in
  x86_64|amd64) arch=amd64 ;;
  arm64|aarch64) arch=arm64 ;;
  *) erro "arquitetura $(uname -m) sem binário publicado; veja https://github.com/${repo}/releases" ;;
esac
asset="noryn-${os}-${arch}"

if [ -z "$tag" ]; then
  tag="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
  [ -n "$tag" ] || erro "não consegui descobrir a release mais nova de ${repo}"
fi

base="https://github.com/${repo}/releases/download/${tag}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

printf 'baixando noryn %s para %s-%s\n' "$tag" "$os" "$arch"
curl -fsSL "${base}/${asset}" -o "${tmp}/${asset}" \
  || erro "não achei ${asset} em ${tag}; veja https://github.com/${repo}/releases"

# O SHA256SUMS é publicado junto. Sem ele o script para, em vez de instalar
# bytes que ninguém conferiu.
curl -fsSL "${base}/SHA256SUMS" -o "${tmp}/SHA256SUMS" \
  || erro "SHA256SUMS ausente em ${tag}; não instalo sem conferir"

esperado="$(sed -n "s/^\([0-9a-f]\{64\}\)[[:space:]]*\*\{0,1\}${asset}\$/\1/p" "${tmp}/SHA256SUMS" | head -1)"
[ -n "$esperado" ] || erro "SHA256SUMS não lista ${asset}"

if command -v sha256sum >/dev/null 2>&1; then
  obtido="$(sha256sum "${tmp}/${asset}" | cut -d' ' -f1)"
elif command -v shasum >/dev/null 2>&1; then
  obtido="$(shasum -a 256 "${tmp}/${asset}" | cut -d' ' -f1)"
else
  erro "preciso de sha256sum ou shasum para conferir o download"
fi
[ "$obtido" = "$esperado" ] || erro "sha256 não confere: ${obtido} contra ${esperado}"

mkdir -p "$bin_dir"
chmod +x "${tmp}/${asset}"
mv "${tmp}/${asset}" "${bin_dir}/noryn"
printf 'noryn %s instalado em %s/noryn\n' "$tag" "$bin_dir"

case ":${PATH}:" in
  *":${bin_dir}:"*) ;;
  *) printf '\n%s não está no PATH. Acrescente:\n  export PATH="%s:$PATH"\n' "$bin_dir" "$bin_dir" ;;
esac

printf '\nPróximo passo, com a Workstation da sua organização:\n'
printf '  noryn auth github\n'
printf '  noryn install <org>/<nome> --tenant-key chave-<org>.key\n'
