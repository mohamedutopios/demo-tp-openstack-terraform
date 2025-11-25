#!/usr/bin/env bash
set -euo pipefail

#############################
# Paramètres à adapter au besoin
#############################
EXTERNAL_BRIDGE=${EXTERNAL_BRIDGE:-"br-ex"}
EXT_NET_CIDR=${EXT_NET_CIDR:-"9.12.93.0/24"}
EXT_GATEWAY_IP=${EXT_GATEWAY_IP:-"9.12.93.1"}   # Gateway NAT VirtualBox
DOCKER=${DOCKER:-"sudo docker"}

banner() {
  echo
  echo "============================================================"
  echo "== $*"
  echo "============================================================"
}

pause() {
  echo
  read -rp "👉 Appuie sur Entrée pour continuer... " || true
  echo
}

#############################
# 0. Vérifications de base
#############################
banner "0. Vérifications de base"

if ! command -v openstack >/dev/null 2>&1; then
  echo "❌ La commande 'openstack' n'est pas disponible. Charge ton env (source admin-openrc.sh) puis relance ce script."
  exit 1
fi

if ! ip link show "$EXTERNAL_BRIDGE" >/dev/null 2>&1; then
  echo "❌ Le bridge $EXTERNAL_BRIDGE n'existe pas au niveau Linux."
else
  echo "✅ Bridge $EXTERNAL_BRIDGE trouvé."
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "⚠️ 'docker' non trouvé. Kolla utilise peut-être 'podman' ou autre. Adapte la variable DOCKER dans le script."
fi

pause

#############################
# 1. État réseau Linux (br-ex, routes, ping gateway)
#############################
banner "1. État réseau Linux (interfaces, routes, ping gateway)"

echo "👉 Interfaces liées à $EXTERNAL_BRIDGE et au réseau $EXT_NET_CIDR :"
ip -4 a | grep -E "($EXTERNAL_BRIDGE|$EXT_NET_CIDR|enp0s9)" || true

echo
echo "👉 Route vers $EXT_NET_CIDR :"
ip route show | grep "$EXT_NET_CIDR" || echo "⚠️ Pas de route trouvée pour $EXT_NET_CIDR"

echo
echo "👉 Ping de la gateway NAT $EXT_GATEWAY_IP depuis $EXTERNAL_BRIDGE :"
ping -c 4 -I "$EXTERNAL_BRIDGE" "$EXT_GATEWAY_IP" || echo "⚠️ Ping échoué (à analyser)"

pause

#############################
# 2. État des agents Neutron (L3 / OVS)
#############################
banner "2. État des agents Neutron (L3 / OVS)"

echo "👉 Liste des network agents (on filtre L3, OVS, DHCP) :"
openstack network agent list --long | egrep -i "l3|openvswitch|dhcp" || echo "⚠️ Aucun agent trouvé (bizarre)"

pause

#############################
# 3. Namespaces réseau Neutron
#############################
banner "3. Namespaces réseau Neutron (qrouter / qdhcp)"

echo "👉 Namespaces réseaux présents :"
sudo ip netns || echo "⚠️ Aucun namespace réseau (le L3 n'a peut-être rien créé)"

pause

#############################
# 4. Routers Neutron et gateways externes
#############################
banner "4. Routers Neutron et gateways externes"

echo "👉 Liste des routers :"
openstack router list

echo
echo "👉 Détail de chaque router (interfaces + gateway externe) :"
for r in $(openstack router list -f value -c ID); do
  echo
  echo "----- Router $r -----"
  openstack router show "$r" -f yaml
done

pause

#############################
# 5. Inspection des qrouter-* (IP, routes, ping)
#############################
banner "5. Inspection des namespaces qrouter-*"

for ns in $(sudo ip netns | awk '/qrouter-/{print $1}'); do
  echo
  echo "----- Namespace $ns -----"

  echo
  echo "👉 Interfaces IPv4 dans $ns :"
  sudo ip netns exec "$ns" ip -4 a

  echo
  echo "👉 Table de routage dans $ns :"
  sudo ip netns exec "$ns" ip route

  echo
  echo "👉 Ping de la gateway NAT $EXT_GATEWAY_IP depuis $ns :"
  sudo ip netns exec "$ns" ping -c 3 "$EXT_GATEWAY_IP" || echo "⚠️ Ping échoué depuis $ns"

done

if ! sudo ip netns | grep -q qrouter-; then
  echo
  echo "⚠️ Aucun namespace qrouter- trouvé : le L3 agent ne gère aucun router (ou n'arrive pas à les créer)."
fi

pause

#############################
# 6. Réseaux (public / privé) et provider
#############################
banner "6. Réseaux OpenStack (public / privé)"

echo "👉 Liste des réseaux :"
openstack network list

echo
echo "👉 Détail de chaque réseau (type, physical_network, etc.) :"
for net in $(openstack network list -f value -c ID); do
  echo
  echo "----- Network $net -----"
  openstack network show "$net" -f yaml
done

pause

#############################
# 7. Vérification des bridge_mappings dans l'agent OVS
#############################
banner "7. Vérification bridge_mappings dans neutron_openvswitch_agent"

echo "👉 bridge_mappings dans openvswitch_agent.ini :"
$DOCKER exec neutron_openvswitch_agent bash -c "grep -n 'bridge_mappings' /etc/neutron/plugins/ml2/openvswitch_agent.ini || echo 'bridge_mappings non trouvé dans ce fichier'" || echo "⚠️ Impossible de lire la conf OVS"

pause

#############################
# 8. Floating IPs et adresses des VMs
#############################
banner "8. Floating IPs et adresses des VMs"

echo "👉 Liste des serveurs (VMs) :"
openstack server list

echo
echo "👉 Liste des Floating IPs :"
openstack floating ip list

echo
echo "👉 Détails 'addresses' et 'security_groups' pour chaque VM :"
for s in $(openstack server list -f value -c ID); do
  echo
  echo "----- Server $s -----"
  openstack server show "$s" -c name -c addresses -c security_groups -f yaml
done

pause

#############################
# 9. Rappel du problème iptables / update-alternatives
#############################
banner "9. Log neutron_l3_agent : rappel de l'erreur update-alternatives (informatif)"

echo "👉 Dernières lignes de log du conteneur neutron_l3_agent :"
$DOCKER logs neutron_l3_agent --tail 40 || echo "⚠️ Impossible de lire les logs docker de neutron_l3_agent"

echo
echo "💡 Si tu veux supprimer l'erreur 'update-alternatives' dans les logs, tu peux tenter dans le conteneur :"
echo "   - ln -s /usr/sbin/update-alternatives /usr/bin/update-alternatives"
echo "   ou installer le paquet qui contient update-alternatives selon la distro."

echo
echo "✅ Fin du script de diagnostic réseau OpenStack."
echo "Analyse les blocs ci-dessus :"
echo " - qrouter-* existe ?"
echo " - qg-xxxx en 9.12.93.x présent ?"
echo " - bridge_mappings = public:br-ex ?"
echo " - router avec external_gateway_info défini ?"
echo " - Floating IP bien attachée + security group OK ?"

