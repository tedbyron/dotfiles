#!/usr/bin/env bash

# store currently installed binary names and versions in `current_map`
current_versions() {
  local -a arr
  mapfile -t arr < <(cargo install --list \
    | awk '/^[[:alnum:]]/{print $1 "\n" $2}')
  local -r loop_len="${#arr[@]}"
  for (( i=0; i < loop_len; i+=2 )); do
    name="${arr[${i}]}"
    ver="${arr[$(( i+1 ))]}"
    ver="${ver//[!0-9.]/}"
    current_map["${name}"]="${ver}"
  done
}

# store `cargo search` versions in `next_map`
next_versions() {
  for crate in "${!current_map[@]}"; do
    ver="$(cargo search --limit 1 "${crate}")"
    name="$(awk 'NR==1{print $1}' <<<"${ver}")"
    if [[ -n "${ver}" && "${crate}" == "${name}" ]]; then
      ver="$(awk 'NR==1{print $3}' <<<"${ver}")"
      ver="${ver//[!0-9.]/}"
    else
      ver="${current_map[${crate}]}"
    fi
    next_map["${crate}"]="${ver}"
  done
}

# compare versions and list outdated; get values into `install`
compare_and_echo() {
  for crate in "${!current_map[@]}"; do
    ver="${current_map[${crate}]}"
    ver_next="${next_map[${crate}]}"
    if [[ "${ver}" != "${ver_next}" ]]; then
      install["${crate}"]="${ver_next}"
    fi
  done

  for crate in "${!install[@]}"; do
    ver="${current_map[${crate}]}"
    ver_next="${install[${crate}]}"
    echo -e "${crate} ${yellow}${ver}${nt} -> ${green}${ver_next}${nt}"
  done | column -t
}

# prompt to install outdated crates in `install`
prompt_and_install() {
  for crate in "${!install[@]}"; do
    ver="${install[${crate}]}"
    echo -en "Install ${crate} v${green}${ver}${nt}? [y/N] "
    read -r -p '' response
    case "${response}" in
        [yY][eE][sS]|[yY]) cargo install -f "${crate}" ;;
        *) continue ;;
    esac
  done
}

main() {
  local -A current_map
  local -A next_map
  local -A install
  local name
  local ver
  local ver_next

  local -r green='\033[32m'   # foreground green
  local -r yellow='\033[33m'  # foreground yellow
  local -r nt='\033[0m'       # normal text

  current_versions
  next_versions
  compare_and_echo
  echo
  prompt_and_install
}

main
