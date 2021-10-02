#!/usr/bin/env bash
declare -A current_map
declare -A next_map
declare -A install
declare name
declare vers
declare vers_next

declare -r green='\033[32m'   # foreground green
declare -r yellow='\033[33m'  # foreground yellow
declare -r nt='\033[0m'       # normal text

# store currently installed binary names and versions in `current_map`
current_versions() {
  local -a arr
  mapfile -t arr < <(cargo install --list \
    | awk '/^[[:alnum:]]/{print $1 "\n" $2}')
  local -r loop_len="${#arr[@]}"
  for (( i=0; i < loop_len; i+=2 )); do
    name="${arr[${i}]}"
    vers="${arr[$(( i+1 ))]}"
    vers="${vers//[!0-9.]/}"
    current_map["${name}"]="${vers}"
  done
}

# store `cargo search` versions in `next_map`
next_versions() {
  for crate in "${!current_map[@]}"; do
    vers="$(cargo search --limit 1 "${crate}")"
    name="$(awk 'NR==1{print $1}' <<<"${vers}")"
    if [[ -n "${vers}" && "${crate}" == "${name}" ]]; then
      vers="$(awk 'NR==1{print $3}' <<<"${vers}")"
      vers="${vers//[!0-9.]/}"
    else
      vers="${current_map[${crate}]}"
    fi
    next_map["${crate}"]="${vers}"
  done
}

# compare versions and add outdated to `install`; echo outdated and versions
compare_and_echo() {
  for crate in "${!current_map[@]}"; do
    vers="${current_map[${crate}]}"
    vers_next="${next_map[${crate}]}"
    if [[ "${vers}" != "${vers_next}" ]]; then
      install["${crate}"]="${vers_next}"
    fi
  done

  for crate in "${!install[@]}"; do
    vers="${current_map[${crate}]}"
    vers_next="${install[${crate}]}"
    echo -e "${crate} ${yellow}${vers}${nt} -> ${green}${vers_next}${nt}"
  done | column -t
}

# prompt to install outdated crates in `install`
prompt_and_install() {
  for crate in "${!install[@]}"; do
    vers="${install[${crate}]}"
    echo -en "Install ${crate} ${green}${vers}${nt}? [y/N] "
    read -r -p '' y_n
    case "${y_n}" in
        [yY][eE][sS]|[yY])
          read -r -p "Extra args for 'cargo install': " eargs
          case "${eargs}" in
            '') cargo install -f "${crate}" ;;
            *)  cargo install -f "${eargs}" "${crate}" ;;
          esac
          ;;
        *)
          continue
          ;;
    esac
  done
}

# install all outdated crates in `install` without prompting
prompt_and_install_y() {
  for crate in "${!install[@]}"; do
    cargo install -f "${crate}" || exit 1
  done
}

main() {
  current_versions
  next_versions
  compare_and_echo

  if [[ "$#" -eq 1 && "${1,,}" == '-y' ]]; then
    prompt_and_install_y
  else
    prompt_and_install
  fi
}

main "$@"
