# Arch Snippets

Remove orphaned packages

```sh
sudo pacman -Rns $(pacman -Qtdq)
```

List packages by file size

```sh
expac -H M '%m\t%n' | sort -h
```

List installed packages not required by other packages, and which are not part of `base` or `base-devel`

```sh
comm -23 <(pacman -Qqt | sort) <(pacman -Sqg base base-devel | sort)
```

Age of an Arch installation

```sh
echo $(($(($(date +%s) - $(date -d "$(head -1 /var/log/pacman.log | cut -d ' ' -f 1,2 | tr -d '[]')" +%s))) / 86400)) days
```
