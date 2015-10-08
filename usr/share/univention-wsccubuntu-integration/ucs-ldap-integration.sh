#!/bin/bash
# echo -e "\e[38;5;87mXXX\e[0m"

echo "##########################################################"
echo "#                                                        #"
echo -e "#  \e[38;5;87mWelcome to the WALZ.systems Corporate Client Patcher\e[0m  #"
echo "# ------------------------------------------------------ #"
echo "#                                                        #"
echo -e "# \e[38;5;87mNow we'll install all UCS ldap dependencies for Ubuntu\e[0m #"
echo "#                                                        #"
echo -e "# \e[38;5;87mAfter that, you're able to login with your UCS login\e[0m   #"
echo -e "# \e[38;5;87mcredentials. BUT PLEASE WAIT FOR THE SYSTEM REBOOT!\e[0m    #"
echo "#                                                        #"
echo "##########################################################"
echo ""
echo ""
read -p "Enter the ip address from the UCS DC Master: " ipucsmaster
read -p "Are you sure that your ip address is $ipucsmaster? (Yes/No): " ipucsmaster_answer

if [[ $ipucsmaster_answer == "No" || $ipucsmaster_answer == "N" || $ipucsmaster_answer == "n" || $ipucsmaster_answer == "" ]]; then
	echo -e "\e[38;5;196mIf you want to resume the installation, you have to enter the following\e[0m"
	echo -e "\e[38;5;202msudo bash /usr/share/univention-wsccubuntu-integration/ucs-ldap-integration.sh\e[0m"
	exit 1;
fi

# Set the IP address of the UCS DC Master, 192.168.0.3 in this example
export MASTER_IP=$ipucsmaster

mkdir /etc/univention
ssh root@${MASTER_IP} ucr shell | grep -v ^hostname= >/etc/univention/ucr_master
echo "master_ip=${MASTER_IP}" >>/etc/univention/ucr_master
chmod 660 /etc/univention/ucr_master
. /etc/univention/ucr_master

echo "${MASTER_IP} ${ldap_master}" >>/etc/hosts



# Set some environment variables
. /etc/univention/ucr_master

# Download the SSL certificate
mkdir -p /etc/univention/ssl/ucsCA/
wget -O /etc/univention/ssl/ucsCA/CAcert.pem http://${ldap_master}/ucs-root-ca.crt

# Create an account and save the password
password="$(tr -dc A-Za-z0-9_ </dev/urandom | head -c20)"
ssh root@${ldap_master} udm computers/ubuntu create \
    --position "cn=computers,${ldap_base}" \
    --set name=$(hostname) --set password="${password}" \
    --set operatingSystem="$(lsb_release -is)" \
    --set operatingSystemVersion="$(lsb_release -rs)"
printf '%s' "$password" >/etc/ldap.secret
chmod 0400 /etc/ldap.secret

# Create ldap.conf
cat >/etc/ldap/ldap.conf <<__EOF__
TLS_CACERT /etc/univention/ssl/ucsCA/CAcert.pem
URI ldap://$ldap_master:7389
BASE $ldap_base
__EOF__



# Set some environment variables
. /etc/univention/ucr_master

# Install SSSD based configuration
DEBIAN_FRONTEND=noninteractive apt-get -y install sssd libnss-sss libpam-sss libsss-sudo

# Create sssd.conf
cat >/etc/sssd/sssd.conf <<__EOF__
[sssd]
config_file_version = 2
reconnection_retries = 3
sbus_timeout = 30
services = nss, pam, sudo
domains = $kerberos_realm

[nss]
reconnection_retries = 3

[pam]
reconnection_retries = 3

[domain/$kerberos_realm]
auth_provider = krb5
krb5_kdcip = ${master_ip}
krb5_realm = ${kerberos_realm}
krb5_server = ${ldap_master}
krb5_kpasswd = ${ldap_master}
id_provider = ldap
ldap_uri = ldap://${ldap_master}:7389
ldap_search_base = ${ldap_base}
ldap_tls_reqcert = never
ldap_tls_cacert = /etc/univention/ssl/ucsCA/CAcert.pem
cache_credentials = true
enumerate = true
ldap_default_bind_dn = cn=$(hostname),cn=computers,${ldap_base}
ldap_default_authtok_type = password
ldap_default_authtok = $(cat /etc/ldap.secret)
__EOF__
chmod 600 /etc/sssd/sssd.conf

# Install auth-client-config
DEBIAN_FRONTEND=noninteractive apt-get -y install auth-client-config

# Create an auth config profile for sssd
cat >/etc/auth-client-config/profile.d/sss <<__EOF__
[sss]
nss_passwd=   passwd:   compat sss
nss_group=    group:    compat sss
nss_shadow=   shadow:   compat
nss_netgroup= netgroup: nis

pam_auth=
        auth [success=3 default=ignore] pam_unix.so nullok_secure try_first_pass
        auth requisite pam_succeed_if.so uid >= 500 quiet
        auth [success=1 default=ignore] pam_sss.so use_first_pass
        auth requisite pam_deny.so
        auth required pam_permit.so

pam_account=
        account required pam_unix.so
        account sufficient pam_localuser.so
        account sufficient pam_succeed_if.so uid < 500 quiet
        account [default=bad success=ok user_unknown=ignore] pam_sss.so
        account required pam_permit.so

pam_password=
        password sufficient pam_unix.so obscure sha512
        password sufficient pam_sss.so use_authtok
        password required pam_deny.so

pam_session=
        session required pam_mkhomedir.so skel=/etc/skel/ umask=0077
        session optional pam_keyinit.so revoke
        session required pam_limits.so
        session [success=1 default=ignore] pam_sss.so
        session required pam_unix.so
__EOF__
auth-client-config -a -p sss

# Restart sssd
restart sssd



cat >/usr/share/pam-configs/ucs_mkhomedir <<__EOF__
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session:
    required    pam_mkhomedir.so umask=0022 skel=/etc/skel
__EOF__

DEBIAN_FRONTEND=noninteractive pam-auth-update --force



echo '*;*;*;Al0000-2400;audio,cdrom,dialout,floppy,plugdev,adm' \
   >>/etc/security/group.conf

cat >>/usr/share/pam-configs/local_groups <<__EOF__
Name: activate /etc/security/group.conf
Default: yes
Priority: 900
Auth-Type: Primary
Auth:
    required    pam_group.so use_first_pass
__EOF__

DEBIAN_FRONTEND=noninteractive pam-auth-update



# Add a field for a user name, disable user selection at the login screen
mkdir /etc/lightdm/lightdm.conf.d
cat >>/etc/lightdm/lightdm.conf.d/99-show-manual-userlogin.conf <<__EOF__
[SeatDefaults]
greeter-show-manual-login=true
greeter-hide-users=true
__EOF__



echo -e "\e[38;5;87m...successfully installed LDAP integrategration to UCS DC Master\e[0m"

shutdown -r now