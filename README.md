# 🍏 macOS Developer Machine Setup

An interactive, transparent setup script that configures fresh macOS installations for software engineering.

Instead of running blind bulk installs, the script asks about every optimization individually. The terminal shows the exact effect of each step before it changes anything on your system, so you stay in full control of your environment.

## 🚀 Quick Start

Copy and paste this command into the macOS Terminal. There are no placeholders to edit. Standard input stays attached to your terminal, so the interactive prompts work.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theasmat/mac-setup/master/setup.sh)"
```

## 🔍 Prefer to Read It First?

Download the script, review it, then run it:

```bash
curl -fsSL [https://raw.githubusercontent.com/theasmat/mac-setup/master/setup.sh](https://raw.githubusercontent.com/theasmat/mac-setup/master/setup.sh) -o setup.sh
less setup.sh
bash setup.sh
```

## 🧭 How It Works

1. The script presents one optimization at a time.
2. The terminal explains exactly what the step will do.
3. You choose to apply or skip it.
4. Nothing on your system changes until you confirm.

## 🛠 Troubleshooting

- **404 or empty output:** Make sure the repository is public and that `setup.sh` exists on the `master` branch.
- **`syntax error near unexpected token`:** The command was copied with extra characters, such as Markdown link brackets. Copy it from the code block above, or paste it into a plain text editor first.
- **`curl: command not found`:** Run the command in the default macOS Terminal, where `curl` is preinstalled.

## 🔐 Security Note

Running remote scripts is a trust decision. Review `setup.sh` before running it, using the "Read It First" steps above.

## 📄 License

Add your license here, for example MIT.