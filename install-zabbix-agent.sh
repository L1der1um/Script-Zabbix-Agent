#!/usr/bin/env bash
# ==============================================================================
# Script de Instalação e Configuração Interativa - Zabbix Agent
# Compatibilidade: Debian 11/12/13 e Ubuntu Server
# ==============================================================================

set -e

# Cores para saída visual
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. Validação de privilégios de superusuário
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}❌ ERRO: Execute este script como root (utilize 'su -' ou 'sudo').${NC}" >&2
    exit 1
fi

# 2. Coleta de dados interativa
clear
echo -e "${BLUE}======================================================"
echo -e "   CONFIGURAÇÃO AUTOMATIZADA - ZABBIX AGENT"
echo -e "======================================================${NC}\n"

# Pergunta o IP do Zabbix Server com validação básica
while true; do
    read -rp "👉 Digite o IP do Zabbix Server (ex: 192.168.0.153): " ZBX_SERVER_IP
    if [[ "$ZBX_SERVER_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        break
    else
        echo -e "${RED}Formato de IP inválido. Tente novamente.${NC}"
    fi
done

# Pergunta o Hostname (oferece o nome atual da máquina como sugestão padrão)
CURRENT_HOSTNAME=$(hostname)
read -rp "👉 Digite o Hostname desejado para o Zabbix [Padrão: ${CURRENT_HOSTNAME}]: " ZBX_HOSTNAME
ZBX_HOSTNAME=${ZBX_HOSTNAME:-$CURRENT_HOSTNAME}

echo -e "\n${YELLOW}Configurando com os seguintes parâmetros:${NC}"
echo -e "  • Zabbix Server IP : ${GREEN}${ZBX_SERVER_IP}${NC}"
echo -e "  • Hostname Zabbix  : ${GREEN}${ZBX_HOSTNAME}${NC}\n"

read -rp "Pressione [ENTER] para iniciar a instalação..."

# 3. Instalação do pacote
echo -e "\n${BLUE}🔄 [1/4] Atualizando repositórios e instalando o Zabbix Agent...${NC}"
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install -y zabbix-agent

# 4. Backup do arquivo de configuração original
CONFIG_FILE="/etc/zabbix/zabbix_agentd.conf"
if [ ! -f "${CONFIG_FILE}.bak" ]; then
    echo -e "${BLUE}💾 [2/4] Criando backup de segurança da configuração original...${NC}"
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
fi

# 5. Parametrização do arquivo de configuração
echo -e "${BLUE}⚙️  [3/4] Aplicando parâmetros no arquivo ${CONFIG_FILE}...${NC}"

# Ajusta Server (checagens passivas)
sed -i "s/^Server=.*/Server=${ZBX_SERVER_IP}/" "$CONFIG_FILE"

# Ajusta ServerActive (checagens ativas)
sed -i "s/^ServerActive=.*/ServerActive=${ZBX_SERVER_IP}/" "$CONFIG_FILE"

# Ajusta Hostname
sed -i "s/^Hostname=.*/Hostname=${ZBX_HOSTNAME}/" "$CONFIG_FILE"

# 6. Reinicialização e habilitação do serviço no boot
echo -e "${BLUE}🚀 [4/4] Reiniciando e ativando o serviço no systemd...${NC}"
systemctl restart zabbix-agent
systemctl enable zabbix-agent

# 7. Validação de integridade
if systemctl is-active --quiet zabbix-agent; then
    AGENT_PORT=$(ss -tulpn | grep 10050 || true)
    LOCAL_IP=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{print $7}' || hostname -I | awk '{print $1}')

    echo -e "\n${GREEN}======================================================"
    echo -e "   ✅ ZABBIX AGENT CONFIGURADO COM SUCESSO!"
    echo -e "======================================================${NC}"
    echo -e "📌 ${YELLOW}Status do Serviço:${NC} Ativo (running)"
    echo -e "📌 ${YELLOW}IP desta máquina :${NC} ${LOCAL_IP}"
    echo -e "📌 ${YELLOW}Hostname no ZBX  :${NC} ${ZBX_HOSTNAME}"
    echo -e "📌 ${YELLOW}Server Permitido :${NC} ${ZBX_SERVER_IP}"
    echo -e "📌 ${YELLOW}Porta em Escuta  :${NC} 10050/TCP (Passivo)"
    echo -e "------------------------------------------------------"
    echo -e "💡 Cadastre este host na UI do Zabbix utilizando:"
    echo -e "   - Host name : ${ZBX_HOSTNAME}"
    echo -e "   - IP address: ${LOCAL_IP}"
    echo -e "   - Template  : Linux by Zabbix agent"
    echo -e "${GREEN}======================================================${NC}\n"
else
    echo -e "\n${RED}❌ ERRO: O serviço do Zabbix Agent falhou ao iniciar.${NC}"
    journalctl -xeu zabbix-agent --no-pager -n 20
    exit 1
fi