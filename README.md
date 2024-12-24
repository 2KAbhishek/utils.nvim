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

`utils.nvim` is a Neovim plugin that provides a collection of utilities to simplify the development of other Neovim plugins.

## ✨ Features

- **Notification Management**: Offers functions to queue and display notifications, allowing seamless user communication within plugins.
- **Command Execution**: Includes capabilities to open commands or directories using the system's default tools, improving workflow efficiency.
- **Asynchronous Shell Commands**: Execute shell commands asynchronously with callback support, facilitating non-blocking operations.
- **JSON Handling**: Provides safe JSON decoding, making it easier to work with external data without risking errors.
- **Caching Mechanism**: Implements a caching system to store data and reduce unnecessary command execution, optimizing performance.
- **Human-Readable Timestamps**: Converts ISO 8601 timestamps to a more understandable format, enhancing date and time representation in the UI.
- **Cache Management**: Functions to clear cache files, helping maintain a clean environment.

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
-- Lazy:
{
    'yourname/plugin.nvim',
    dependencies = {
        {
            '2kabhishek/utils.nvim',
            opts = {
                -- provider for results from `open_dir`
                -- can be either 'telescope' or 'fzf_lua'
                -- defaults to 'telescope'
                fuzzy_provider = "telescope"
            }
        }
    },
}

-- using `setup` function:
require("utils").setup({
    fuzzy_provider = "telescope"
})
```

Currently, there is only a single configurable option `fuzzy_provider` which allows the user to switch the backend for the `open_dir` function provided by the plugin. The default is to use Telescope, with the option of switching to fzf-lua instead.

## 🚀 Usage

### Functions

The utilities provided by `utils.nvim` can be directly used in your plugin as shown below:

```lua
local utils = require('utils')

utils.show_notification('Hello World!')
```

Below is a list of all the functions provided by `utils.nvim`.

> `utils.queue_notification(message: string, level?: number, title?: string, timeout?: number)`

Adds a notification to the queue, to be processed and displayed later.

- **Input**:
  - `message`: The content of the notification.
  - `level` (optional): The log level of the notification (defaults to `INFO`).
  - `title` (optional): The title of the notification (defaults to `"Notification"`).
  - `timeout` (optional): Duration to show the notification (defaults to `5000ms`).
- **Output**: No return value. Adds a notification to the queue and schedules it.

> `utils.show_notification(message: string, level?: number, title?: string, timeout?: number)`

Immediately shows a notification to the user.

- **Input**:

  - `message`: The content of the notification.
  - `level` (optional): The log level of the notification (defaults to `INFO`).
  - `title` (optional): The title of the notification (defaults to `"Notification"`).
  - `timeout` (optional): Duration to show the notification (defaults to `5000ms`).

- **Output**: No return value. Displays the notification.

> `utils.open_command(command: string)`

Opens the given command in the default browser/terminal, depending on the system.

- **Input**:
  - `command`: A string that represents the URL or command to be opened.
- **Output**: No return value. Executes the open command using the system’s default tool.

> `utils.open_dir(dir: string)`

Opens a directory inside a tmux session if running within tmux, or directly navigates in Neovim otherwise.

- **Input**:

  - `dir`: Path to the directory to be opened.

- **Output**: No return value. Either navigates to the directory in Neovim or attempts to open the directory in tmux.

> `utils.async_shell_execute(command: string, callback: fun(result: string))`

Executes a shell command asynchronously and calls the callback with the result.

- **Input**:
  - `command`: The shell command to be executed.
  - `callback`: A function that is called with the result of the command execution.
- **Output**: No return value. The command result is passed to the callback function.

> `utils.safe_json_decode(str: string) -> table|nil`

Safely decodes a JSON string into a Lua table, with error handling.

- **Input**:

  - `str`: The JSON string to decode.

- **Output**:
  - On success: Returns a Lua table representation of the JSON string.
  - On failure: Returns `nil` and logs an error notification.

> `utils.get_data_from_cache(cache_key: string, command: string, callback: fun(data: any), cache_timeout: number)`

Fetches data from a cached file or executes a command to get fresh data if the cache is expired or missing.

- **Input**:

  - `cache_key`: The cache key to identify the cached data.
  - `command`: The shell command to execute if the cache is expired or missing.
  - `callback`: A function that receives the data (either from cache or after executing the command).
  - `cache_timeout`: The time (in seconds) before the cache expires.

- **Output**: No return value. The data is passed to the callback function.

> `utils.human_time(timestamp: string) -> string`

Converts an ISO 8601 timestamp into a human-readable format.

- **Input**:

  - `timestamp`: A string in ISO 8601 format (e.g., `"2024-10-10T14:00:00"`).

- **Output**:
  - Returns the formatted date and time (e.g., `"10 Oct 2024, 02:00 PM"`).

> `utils.clear_cache(prefix: string)`

Clears the cache by deleting all cached files.

- **Input**:
  - `prefix`: The prefix to identify cached files.
- **Output**: No return value. Clears all cache files and shows a notification confirming the action.

### Commands

`utils.nvim` adds the following command:

- **`UtilsClearCache`**: Clears all cache files saved by the plugin. To execute it, run:

### Help

Run `:help nerdy` for more details.

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
