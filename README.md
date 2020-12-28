# scoop-clink-completion
Clink completion file for [Scoop](https://scoop.sh/).

Allows you to complete bucket | app | command names.

<img src="https://raw.githubusercontent.com/Elvyria/scoop-clink-completion/master/completion.gif" height="70" width="300">

## Attention
[Cmder](http://cmder.net/) from version 1.3.17 includes updated version of [clink-completions](https://github.com/vladimir-kotikov/clink-completions) which includes own completion file for scoop and it conflicts with one from this repository.  
It's not better in amount of provided suggestions nor in startup time/performance, but for basic usage it shouldn't make a difference of which one you use.

## Installation
Download scoop.lua

### For [clink](https://mridgers.github.io/clink/)
Place it in your clink or clink profile folder.

### For [cmder](http://cmder.net/)
Place it in `%CMDER_ROOT%/config` folder.  
(From version 1.3.17 of cmder you also need to remove or replace `cmder/vendor/clink-completions/scoop.lua`)
