<div align = "center">

<h1><a href="https://github.com/2kabhishek/utils.nvim">utils.nvim</a></h1>

<a href="https://github.com/2KAbhishek/utils.nvim/blob/main/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/2kabhishek/utils.nvim?style=flat&color=eee&label="> </a>

<a href="https://github.com/2KAbhishek/utils.nvim/graphs/contributors">
<img alt="People" src="https://img.shields.io/github/contributors/2kabhishek/utils.nvim?style=flat&color=ffaaf2&label=People"> </a>

<a href="https://github.com/2KAbhishek/utils.nvim/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/2kabhishek/utils.nvim?style=flat&color=98c379&label=Stars"></a>

<a href="https://github.com/2KAbhishek/utils.nvim/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/2kabhishek/utils.nvim?style=flat&color=66a8e0&label=Forks"> </a>

<a href="https://github.com/2KAbhishek/utils.nvim/watchers">
<img alt="Watches" src="https://img.shields.io/github/watchers/2kabhishek/utils.nvim?style=flat&color=f5d08b&label=Watches"> </a>

<a href="https://github.com/2KAbhishek/utils.nvim/pulse">
<img alt="Last Updated" src="https://img.shields.io/github/last-commit/2kabhishek/utils.nvim?style=flat&color=e06c75&label="> </a>

<h3>Powerful Utilities for Neovim Plugin Devs 🛠️🧰</h3>

</div>

`utils.nvim` is a Neovim plugin that provides a collection of utilities to simplify the development of your Neovim plugins.

## ✨ Features

- **Picker Absctraction**: Offers a simple interface for popular pickers, no need to write custom picker anymore!
- **Caching Mechanism**: Implements a caching system to store data and reduce unnecessary command execution, optimizing performance.
- **Notification Management**: Offers functions to queue and display notifications, allowing seamless user communication within plugins.
- **Shell Execution**: Includes capabilities to execute commands async, work with system tools, improving workflow efficiency.
- More!

## ⚡ Setup

### ⚙️ Requirements

- Latest version of `neovim`
- `plenary.nvim`

### 💻 Installation

`utils.nvim` is not meant to be installed by itself, but rather as a dependency for another plugin.

If you are building a plugin that requires the utilities provided by `utils.nvim`, you can add it as a dependency as shown below:

```lua
-- Lazy
{
    'yourname/plugin.nvim',
    dependencies = {
        '2kabhishek/utils.nvim'
    },
},
```

#### ⚙️ Configuration

`utils.nvim` can optionally be configured by specifying `opts` with Lazy or alternatively with the `setup` function like so:

```lua
-- Lazy opts:
{
    'yourname/plugin.nvim',
    dependencies = {
        {
            '2kabhishek/utils.nvim',
            opts = {
                -- 'telescope', 'fzf_lua', or 'snacks' (default)
                picker_provider = "snacks",
            }
        }
    },
}

-- using `setup` function:
require("utils").setup({
    picker_provider = "telescope"
})
```

## 🚀 Usage

### Modules

`utils.nvim` is divided into several modules, each providing specific functionalities:

- `picker`: a module providing abstractions over various picker providers, supports `telescope`, `fzf_lua`, and `snacks`.
- `cache`: a module for caching data and managing cache files.
- `notification`: a module for simplifying notification queues.
- `shell`: a module for executing shell commands and opening URLs, files.
- `json`: a module for handling JSON data.
- `time`: a module for working with time and date.

### Commands

`utils.nvim` adds the following command:

- **`UtilsClearCache`**: Clears all cache files saved by the plugin. To execute it, run:

### Help

Run `:help utils.txt` for more details.

## 🏗️ What's Next

Planning to add `<feature/module>`.

### ✅ To-Do

- You tell me!

## ⛅ Behind The Code

### 🌈 Inspiration

utils.nvim was created while working on [octohub.nvim](https://github.com/2kabhishek/octohub.nvim) which relied on a lot of common utilities like async shell execution, notifications, and caching.

### 💡 Challenges/Learnings

- Figuring out the callback mechanism for async functions was a bit tricky.
- Learned better ways to handle caching and notifications.

### 🔍 More Info

- [octohub.nvim](https://github.com/2kabhishek/octohub.nvim) — All your GitHub features in Neovim, uses utils.nvim
- [nerdy.nvim](https://github.com/2kabhishek/nerdy.nevim) — Find nerd glyphs easily
- [tdo.nvim](https://github.com/2KAbhishek/tdo.nvim) — Fast and simple notes in Neovim

<hr>

<div align="center">

<strong>⭐ hit the star button if you found this useful ⭐</strong><br>

<a href="https://github.com/2KAbhishek/utils.nvim">Source</a>
| <a href="https://2kabhishek.github.io/blog" target="_blank">Blog </a>
| <a href="https://twitter.com/2kabhishek" target="_blank">Twitter </a>
| <a href="https://linkedin.com/in/2kabhishek" target="_blank">LinkedIn </a>
| <a href="https://2kabhishek.github.io/links" target="_blank">More Links </a>
| <a href="https://2kabhishek.github.io/projects" target="_blank">Other Projects </a>

</div>
