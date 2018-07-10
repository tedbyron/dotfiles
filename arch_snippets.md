# Arch Snippets

Age of an Arch installation

```sh
echo $(($(($(date +%s) - $(date -d "$(head -1 /var/log/pacman.log | cut -d ' ' -f 1,2 | tr -d '[]')" +%s))) / 86400)) days
```

Remove orphaned packages

```sh
sudo pacman -Rns $(pacman -Qtdq)
```
