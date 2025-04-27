# dots
:zap: Dots: Making computers feel like home.

## Installation

### Minimal Installation (for everyone)
```
git clone https://github.com/aamir-sultan/dots.git ~/.dots
cd .dots

./init/install
```
### Full Installation (Install different tools binaries)

Full installation should be proceeded with caution. It install different binaries which are given in the list.

| Tools                     | Binary  |
| ------------------------- | ------- |
| Fuzzy Finder              | fzf     |
| bat (Alternative to cat)  | bat     |
| fd (Alternative to find)  | fd      |
| RipGrep                   | rg      |
| Terminal Multiplexer      | tmux    |
| NeoVim                    | nvim    |

```
git clone https://github.com/aamir-sultan/dots.git ~/.dots
cd .dots

./init/install.sh --all
```


## Uninstallation

Change directory area where dots are cloned.
```
dots uninstall --all

OR

cd path/to/.dots
./init/uninstall.sh --all
```  

## Call Help

Invoke help command to check other options which can different results based on different options provided. [WIP]
```
dots help
dots install --help

OR

cd path/to/.dots
./init/install.sh --help
```

