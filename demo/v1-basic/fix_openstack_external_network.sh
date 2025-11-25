#!/usr/bin/env bash

set -u -o pipefail

# --------- PARAMÈTRES À ADAPTER SI BESOIN ---------
PHYS_IF="${PHYS_IF:-enp0s9}"        # interface qui va vers VirtualBox NAT "External"
PUBLIC_IP="${PUBLIC_IP:-9.12.93.4}" # IP que tu veux sur br-ex
PUBLIC_CIDR="${PUBLIC_CIDR:-9.12.93.4/24}"
PUBLIC_NET="${PUBLIC_NET:-9.12.93.0/24}"
PHYSNET_NAME="${PHYSNET_NAME:-physnet1}"

OVS_AGENT_CONTAINER="${OVS_AGENT_CONTAINER:-neutron_openvswitch_agent}"
L3_AGENT_CONTAINER="${L3_AGENT_CONTAINER:-neutron_l3_agent}"

echo "============================================================"
echo "== Fix OpenStack external network (br-ex / OVS / physnet1) =="
echo "============================================================"
echo
echo "-> Interface physique utilisée : ${PHYS_IF}"
echo "-> IP publique attendue        : ${PUBLIC_CIDR} (${PUBLIC_NET})"
echo "-> physnet                     : ${PHYSNET_NAME}"
echo

read -p "OK pour continuer ? [Entrée pour oui / Ctrl+C pour annuler] " _

# 0. Vérifications de base
echo
echo "== 0. Vérifications de base ==============================="
if ! ip link show "${PHYS_IF}" &>/dev/null; then
  echo "❌ Interface ${PHYS_IF} introuvable. Adapte PHYS_IF dans le script."
  exit 1
fi
echo "✅ Interface ${PHYS_IF} trouvée."

# 1. Nettoyage de br-ex côté Linux + OVS
echo
echo "== 1. Nettoyage et recréation de br-ex en OVS ============="

echo "-> Suppression éventuelle de br-ex (Linux + OVS)..."
sudo ip link set br-ex down 2>/dev/null || true
sudo ip link del br-ex 2>/dev/null || true
sudo ovs-vsctl --if-exists del-br br-ex

echo "-> Création du bridge OVS br-ex..."
sudo ovs-vsctl add-br br-ex

echo "-> Délier ${PHYS_IF} d'un éventuel bridge Linux..."
sudo ip link set "${PHYS_IF}" nomaster 2>/dev/null || true

echo "-> Ajout de ${PHYS_IF} comme port OVS de br-ex..."
sudo ovs-vsctl --may-exist add-port br-ex "${PHYS_IF}"

echo "-> Flush des IP sur ${PHYS_IF} et mise de ${PUBLIC_CIDR} sur br-ex..."
sudo ip addr flush dev "${PHYS_IF}"
sudo ip addr add "${PUBLIC_CIDR}" dev br-ex

echo "-> Mise UP des interfaces br-ex et ${PHYS_IF}..."
sudo ip link set br-ex up
sudo ip link set "${PHYS_IF}" up

echo
echo "Etat rapide :"
ip a | grep -E 'br-ex|'"${PHYS_IF}" | sed 's/^/  /'

echo
echo "Route vers le réseau ${PUBLIC_NET} :"
ip route show | grep "${PUBLIC_NET}" || echo "  (aucune route trouvée)"

# 2. Test de ping vers la gateway NAT (9.12.93.1) depuis le host
echo
echo "== 2. Test de ping depuis le host vers 9.12.93.1 =========="
ping -I br-ex -c 4 9.12.93.1 || echo "⚠️ Ping depuis le host échoué (à vérifier)."

read -p "Appuie sur Entrée pour continuer vers la conf Neutron... " _

# 3. Mise à jour du bridge_mappings dans la conf Neutron OVS
echo
echo "== 3. Configuration bridge_mappings (physnet1:br-ex) ======"

CONF_DIR="/etc/kolla/neutron-openvswitch-agent"
CANDIDATES=(
  "${CONF_DIR}/openvswitch_agent.ini"
  "${CONF_DIR}/ml2_conf.ini"
)

FOUND_CONF=""

for f in "${CANDIDATES[@]}"; do
  if [[ -f "$f" ]]; then
    FOUND_CONF="$f"
    break
  fi
done

if [[ -z "${FOUND_CONF}" ]]; then
  echo "⚠️ Aucun fichier de conf trouvé dans ${CONF_DIR}."
  echo "   Tu devras mettre manuellement :"
  echo "   [ovs]"
  echo "   bridge_mappings = ${PHYSNET_NAME}:br-ex"
else
  echo "-> Fichier de conf détecté : ${FOUND_CONF}"

  if grep -qi "^bridge_mappings" "${FOUND_CONF}"; then
    echo "   bridge_mappings déjà présent, voici les lignes :"
    grep -i "^bridge_mappings" "${FOUND_CONF}" | sed 's/^/     /'
    echo "   ⚠️ Vérifie qu'il contient bien ${PHYSNET_NAME}:br-ex."
  else
    echo "   bridge_mappings absent, ajout d'un bloc [ovs]..."
    sudo bash -c "cat >> '${FOUND_CONF}' <<EOF

[ovs]
bridge_mappings = ${PHYSNET_NAME}:br-ex
EOF"
    echo "   ✅ Bloc [ovs] ajouté avec bridge_mappings = ${PHYSNET_NAME}:br-ex"
  fi
fi

# 4. Redémarrage des conteneurs Neutron
echo
echo "== 4. Redémarrage des agents Neutron ======================"
echo "-> Restart ${OVS_AGENT_CONTAINER} et ${L3_AGENT_CONTAINER}..."
sudo docker restart "${OVS_AGENT_CONTAINER}" || echo "⚠️ Echec restart ${OVS_AGENT_CONTAINER}"
sudo docker restart "${L3_AGENT_CONTAINER}"   || echo "⚠️ Echec restart ${L3_AGENT_CONTAINER}"

echo
echo "Attente 5 secondes que les agents se stabilisent..."
sleep 5

# 5. Test de ping depuis les namespaces qrouter vers 9.12.93.1
echo
echo "== 5. Test depuis les qrouter-* vers 9.12.93.1 ============"
for ns in $(ip netns list | awk '/^qrouter-/{print $1}'); do
  echo
  echo "---- Namespace ${ns} ----"
  ip netns exec "${ns}" ip -4 addr show | sed 's/^/   /'
  echo "   Ping 9.12.93.1 :"
  if ip netns exec "${ns}" ping -c 3 9.12.93.1; then
    echo "   ✅ OK pour ${ns}"
  else
    echo "   ❌ Ping échoué pour ${ns}"
  fi
done

# 6. Test optionnel d'une Floating IP
echo
echo "== 6. Test optionnel d'une Floating IP ===================="
read -p "Entrez une Floating IP à tester (ou laisse vide pour passer) : " FIP
if [[ -n "${FIP}" ]]; then
  echo "-> Ping de ${FIP} depuis le host..."
  ping -c 4 "${FIP}" || echo "⚠️ Ping vers ${FIP} échoué."
else
  echo "Pas de Floating IP fournie, étape sautée."
fi

echo
echo "✅ Script de correction terminé."
echo "Vérifie :"
echo " - ping 9.12.93.1 OK depuis host et qrouter-*"
echo " - ping / SSH sur la Floating IP de ta VM"

