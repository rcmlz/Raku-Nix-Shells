# Raku-Nix-Shells
Showing how to set up a reproduceable Raku environment using Nix

```bash
git clone https://github.com/rcmlz/Raku-Nix-Shells
cd Raku-Nix-Shells
```
Now you can launch any of the provided shells environments like

```bash
nix-shell name-of-shell.nix
```
for example

```bash
nix-shell jupyter-chatbook.nix
```

will first setup Jupyter, Raku and the [Juypter-Chatbook](https://raku.land/zef:antononcube/Jupyter::Chatbook) kernel and then launch Jupyter Lab.

ToDo:

- figure out what system packages `zef` and `rakudo` etc. is requirering under the hood - such that we can run eventually in pure mode.

```bash
nix-shell --pure
```
