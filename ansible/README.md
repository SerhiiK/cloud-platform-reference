# Ansible — homelab provisioning

Ansible-код для налаштування homelab-нод. Наразі містить роль
[`nvidia-drivers`](roles/nvidia-drivers/README.md), яка встановлює пропрієтарний
драйвер NVIDIA на Ubuntu Server.

## Структура

```
ansible/
├── deployment.yaml            # головний playbook
├── inventory.ini              # хости (homelab)
├── roles/
│   └── nvidia-drivers/        # роль встановлення драйвера NVIDIA
├── .ansible-lint              # конфіг ansible-lint
└── .yamllint                  # конфіг yamllint
```

Inventory:

```ini
[homelab]
gpu-node ansible_host=192.168.0.102

[homelab:vars]
ansible_user=ubuntu
```

## Передумови

- Ansible на керуючій машині: `pip install ansible-core` (або `brew install ansible`).
- `sshpass` — потрібен для парольної автентифікації (`--ask-pass`):
  - macOS: `brew install hudochenkov/sshpass/sshpass`
  - Ubuntu: `sudo apt install sshpass`
- Мережевий доступ до ноди по SSH (порт 22).

## 1. Перевірити зв'язок з машиною

### ICMP-ping (просто чи жива нода в мережі)

```bash
ping -c 4 192.168.0.102
```

### Ansible-ping (перевіряє SSH + автентифікацію + Python на ноді)

Це головна перевірка — вона підтверджує, що Ansible реально може керувати нодою,
а не лише що вона відповідає в мережі.

```bash
ansible -i inventory.ini homelab -m ping --ask-pass
```

Очікувана відповідь:

```
gpu-node | SUCCESS => {
    "ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"},
    "changed": false,
    "ping": "pong"
}
```

> При першому підключенні SSH запитає підтвердження host key. Щоб не заважало
> в автоматиці: `export ANSIBLE_HOST_KEY_CHECKING=False` (ок для homelab).

Якщо на ноді налаштований SSH-ключ замість пароля — прибери `--ask-pass`.

## 2. Запустити роль

Паролі **не зберігаються** в репо — запитуються під час запуску:

- `--ask-pass` (`-k`) — SSH-пароль користувача `ubuntu`
- `--ask-become-pass` (`-K`) — sudo-пароль (роль ставить пакети через `become`)

### Перевірка перед реальним запуском (dry-run)

```bash
ansible-playbook -i inventory.ini deployment.yaml --ask-pass --ask-become-pass --check --diff
```

### Реальний запуск

```bash
ansible-playbook -i inventory.ini deployment.yaml --ask-pass --ask-become-pass
```

Тільки завдання з тегом `nvidia`:

```bash
ansible-playbook -i inventory.ini deployment.yaml --ask-pass --ask-become-pass --tags nvidia
```

> ⚠️ Роль **перезавантажить ноду**, коли це потрібно для активації драйвера
> (керується змінною `nvidia_driver_reboot`, за замовчуванням `true`).

### Що робить роль

Встановлює `nvidia-driver-580-server` (остання гілка з підтримкою Pascal / GTX 1050),
блокує `nouveau`, за потреби перезавантажує ноду й перевіряє результат через
`nvidia-smi`. Змінні та деталі — у [roles/nvidia-drivers/README.md](roles/nvidia-drivers/README.md).

## 3. Перевірити результат

Після завершення playbook виводить `nvidia-smi`. Вручну на ноді:

```bash
ssh ubuntu@192.168.0.102 nvidia-smi
```

## Лінтинг (локально)

CI (`.github/workflows/ansible-ci.yml`) ганяє це на кожен PR, але можна й локально:

```bash
pip install ansible-lint yamllint
yamllint .
ansible-lint
ansible-playbook --syntax-check -i inventory.ini deployment.yaml
```
