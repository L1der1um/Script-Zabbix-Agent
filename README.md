# 🤖 Zabbix Agent Installer

<p align="center">

![Bash](https://img.shields.io/badge/Bash-Script-4EAA25?style=for-the-badge\&logo=gnubash\&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Compatible-FCC624?style=for-the-badge\&logo=linux\&logoColor=black)
![Debian](https://img.shields.io/badge/Debian-Supported-A81D33?style=for-the-badge\&logo=debian\&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-Supported-E95420?style=for-the-badge\&logo=ubuntu\&logoColor=white)
![Zabbix](https://img.shields.io/badge/Zabbix-Agent-D40000?style=for-the-badge)
![Systemd](https://img.shields.io/badge/Systemd-Service-1793D1?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

</p>

Script desenvolvido para realizar a **instalação e configuração automatizada do Zabbix Agent** em servidores Linux baseados em Debian e Ubuntu.

O objetivo é simplificar a implantação do agente, reduzindo a necessidade de configurações manuais e padronizando parâmetros como **Zabbix Server, ServerActive e Hostname**.

---

# 📦 Este repositório

Este repositório contém um instalador interativo para o **Zabbix Agent**.

O script realiza automaticamente a instalação do pacote, configuração do agente, inicialização do serviço e validação final do ambiente.

---

# ✨ Funcionalidades

* 🤖 Instalação automática do Zabbix Agent
* 🐧 Compatível com Debian e Ubuntu Server
* 🔐 Validação de privilégios de root
* 🌐 Configuração do IP do Zabbix Server
* 🖥️ Configuração do Hostname do agente
* 💾 Backup automático do arquivo de configuração
* ⚙️ Configuração automática do `Server`
* ⚡ Configuração automática do `ServerActive`
* 🔄 Reinicialização automática do serviço
* 🚀 Inicialização automática com o sistema
* 🔍 Validação do status do serviço
* 📡 Verificação da porta do agente
* 🎨 Interface interativa com mensagens coloridas

---

# 🖥️ Sistemas suportados

O script foi desenvolvido para sistemas Linux baseados em Debian.

Atualmente suporta:

* Debian 11
* Debian 12
* Debian 13
* Ubuntu Server

A instalação utiliza o gerenciador de pacotes **APT** e o pacote `zabbix-agent` disponível nos repositórios configurados no sistema.

---

# 📦 Componente instalado

O script instala:

```text
Zabbix Agent
```

O agente permite que o servidor Zabbix monitore o sistema operacional, coletando informações como:

* CPU
* Memória
* Disco
* Processos
* Interfaces de rede
* Sistema operacional
* Disponibilidade do host

A coleta efetiva dos dados depende da configuração realizada no **Zabbix Server** e dos templates associados ao host.

---

# ⚙️ Como funciona

A configuração é dividida em quatro etapas principais.

---

## 1️⃣ Instalação

O script atualiza os repositórios e instala automaticamente o pacote:

```bash
apt update -y
apt install -y zabbix-agent
```

---

## 2️⃣ Backup da configuração

Antes de modificar o arquivo original, o script cria um backup:

```text
/etc/zabbix/zabbix_agentd.conf.bak
```

O arquivo principal utilizado pelo agente é:

```text
/etc/zabbix/zabbix_agentd.conf
```

---

## 3️⃣ Configuração do agente

O script solicita:

### 🌐 IP do Zabbix Server

Exemplo:

```text
192.168.0.153
```

### 🖥️ Hostname

O hostname atual da máquina é utilizado como sugestão padrão.

Exemplo:

```text
SRV-LINUX-01
```

Essas informações são utilizadas para configurar:

```ini
Server=192.168.0.153
ServerActive=192.168.0.153
Hostname=SRV-LINUX-01
```

### Server

Define o servidor autorizado a realizar **checagens passivas** no agente.

### ServerActive

Define o servidor utilizado para **checagens ativas**.

### Hostname

Define o nome utilizado pelo Zabbix para identificar o host.

---

## 4️⃣ Inicialização e validação

Após aplicar as configurações, o script executa:

```bash
systemctl restart zabbix-agent
systemctl enable zabbix-agent
```

O serviço é reiniciado e configurado para iniciar automaticamente durante o boot.

Por fim, o script verifica se o serviço está ativo.

Caso ocorra algum erro, os últimos registros do `systemd` são exibidos automaticamente:

```bash
journalctl -xeu zabbix-agent --no-pager -n 20
```

---

# 🔄 Fluxo da instalação

```text
Validar Root
      │
      ▼
Solicitar IP do Zabbix Server
      │
      ▼
Solicitar Hostname
      │
      ▼
Atualizar Repositórios
      │
      ▼
Instalar Zabbix Agent
      │
      ▼
Criar Backup
      │
      ▼
Configurar Server
      │
      ▼
Configurar ServerActive
      │
      ▼
Configurar Hostname
      │
      ▼
Reiniciar Serviço
      │
      ▼
Habilitar no Boot
      │
      ▼
Validar Serviço
```

---

# ▶️ Execução

Conceda permissão de execução:

```bash
chmod +x install_zabbix_agent.sh
```

Execute:

```bash
sudo ./install_zabbix_agent.sh
```

Ou execute diretamente como `root`:

```bash
su -
./install_zabbix_agent.sh
```

---

# 🖥️ Exemplo de execução

Durante a execução será solicitado o endereço do Zabbix Server:

```text
👉 Digite o IP do Zabbix Server (ex: 192.168.0.153):
```

Em seguida:

```text
👉 Digite o Hostname desejado para o Zabbix [Padrão: servidor01]:
```

Antes da instalação, o script apresenta um resumo:

```text
Configurando com os seguintes parâmetros:

• Zabbix Server IP : 192.168.0.153
• Hostname Zabbix  : servidor01
```

---

# 📡 Porta utilizada

O Zabbix Agent utiliza normalmente:

| Porta | Protocolo | Função       |
| ----: | --------- | ------------ |
| 10050 | TCP       | Zabbix Agent |

A porta `10050/TCP` é utilizada para **checagens passivas**.

A comunicação ativa utiliza a conexão iniciada pelo próprio agente em direção ao Zabbix Server.

---

# 🌐 Cadastro no Zabbix Server

Após executar o script, o host deve ser cadastrado na interface do Zabbix.

Utilize os mesmos parâmetros configurados durante a instalação:

| Parâmetro  | Exemplo                 |
| ---------- | ----------------------- |
| Host name  | `servidor01`            |
| IP address | `192.168.0.100`         |
| Template   | `Linux by Zabbix agent` |

É importante que o **Host name** cadastrado no Zabbix corresponda ao valor configurado no agente:

```ini
Hostname=servidor01
```

---

# ✅ Validação

Após a instalação, o script apresenta informações como:

```text
✅ ZABBIX AGENT CONFIGURADO COM SUCESSO!

Status do Serviço: Ativo (running)
IP desta máquina : 192.168.0.100
Hostname no ZBX  : servidor01
Server Permitido : 192.168.0.153
Porta em Escuta  : 10050/TCP (Passivo)
```

---

# 📋 Comandos úteis

Verificar o serviço:

```bash
sudo systemctl status zabbix-agent
```

Reiniciar:

```bash
sudo systemctl restart zabbix-agent
```

Parar:

```bash
sudo systemctl stop zabbix-agent
```

Iniciar:

```bash
sudo systemctl start zabbix-agent
```

Verificar se está habilitado no boot:

```bash
sudo systemctl is-enabled zabbix-agent
```

Verificar a porta:

```bash
sudo ss -tulpn | grep 10050
```

Visualizar logs:

```bash
sudo journalctl -u zabbix-agent
```

Visualizar os últimos eventos:

```bash
sudo journalctl -u zabbix-agent --no-pager -n 20
```

---

# 📁 Arquivos importantes

| Arquivo                              | Função                                               |
| ------------------------------------ | ---------------------------------------------------- |
| `/etc/zabbix/zabbix_agentd.conf`     | Configuração principal                               |
| `/etc/zabbix/zabbix_agentd.conf.bak` | Backup da configuração original                      |
| `/var/log/zabbix/`                   | Diretório de logs, conforme configuração do ambiente |

---

# 📌 Pré-requisitos

* Debian 11, 12 ou 13
* Ubuntu Server
* Conexão com a Internet
* Acesso de `root` ou `sudo`
* Repositórios APT configurados
* Zabbix Server acessível pela rede

---

# ⚠️ Observações

O script utiliza `sed` para alterar as diretivas:

```ini
Server=
ServerActive=
Hostname=
```

Por isso, o arquivo `zabbix_agentd.conf` precisa conter essas diretivas em formato compatível com o padrão utilizado pelo pacote instalado.

O script também cria um backup da configuração original antes de realizar as alterações.

---

# 🔧 Possíveis melhorias

Algumas funcionalidades podem ser adicionadas futuramente:

* 🔥 Configuração automática de firewall
* 🔐 Configuração de TLS/PSK
* 🌐 Teste automático de conectividade com o Zabbix Server
* 🔍 Validação completa do endereço IP
* 📦 Seleção da versão do Zabbix Agent
* 🛠️ Suporte a parâmetros via linha de comando
* 🔄 Detecção automática de distribuição e versão
* 📡 Teste automático da porta `10050/TCP`
* 🤖 Integração com a API do Zabbix para cadastro automático do host

---

# 🛠️ Tecnologias utilizadas

* Bash
* Zabbix Agent
* Linux
* Debian
* Ubuntu
* APT
* systemd
* sed
* ip
* ss

---

# ✅ Benefícios

* 🚀 Instalação rápida
* ⚙️ Configuração padronizada
* 💾 Backup automático
* 🤖 Redução da configuração manual
* 🔍 Validação automática do serviço
* 🐧 Compatível com ambientes Linux
* 📡 Configuração simplificada do monitoramento
* 🛠️ Fácil manutenção e adaptação

---

# 🔗 Projetos relacionados

Este projeto pode ser utilizado em conjunto com instaladores automatizados do **Zabbix Server**, permitindo separar a implantação do servidor de monitoramento da implantação dos agentes.

Exemplo:

* 🟥 **Zabbix Server Auto Installer**
* 🤖 **Zabbix Agent Installer**

A separação permite instalar o **Zabbix Server** e posteriormente distribuir o **Zabbix Agent** para os servidores que serão monitorados.

---

# 📄 Licença

Este projeto está licenciado sob a licença **MIT**.

Você pode utilizar, modificar e distribuir este projeto livremente, desde que mantenha os créditos e o texto da licença.

---

# 👨‍💻 Autor

Desenvolvido para automatizar a implantação do **Zabbix Agent** em ambientes Linux, reduzindo configurações manuais, padronizando a instalação e acelerando a preparação de servidores para monitoramento.
