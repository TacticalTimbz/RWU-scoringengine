#!/bin/bash

echo "127.0.0.1 mail.testbed.com" >> /etc/hosts

postconf -e myhostname=mail.testbed.com
postconf -e mydestination=mail.testbed.com
postconf -F '*/*/chroot = n'

postconf -e broken_sasl_auth_clients=yes
postconf -e smtpd_sasl_auth_enable=yes
postconf -e smtpd_recipient_restrictions=permit_sasl_authenticated,reject_unauth_destination

cat >> /etc/postfix/sasl/smtpd.conf <<EOF
pwcheck_method: auxprop
auxprop_plugin: sasldb
mech_list: PLAIN LOGIN CRAM-MD5 DIGEST-MD5 NTLM
EOF

# Create accounts
echo "testpass" | saslpasswd2 -p -c -u mail.testbed.com ttesterson
echo "redfred" | saslpasswd2 -p -c -u mail.testbed.com rpeterson

chown postfix.sasl /etc/sasldb2

postconf -e smtpd_tls_cert_file=/etc/postfix/ssl/server.crt
postconf -e smtpd_tls_key_file=/etc/postfix/ssl/server.key
chmod 400 /etc/postfix/ssl/*.*

postconf -M submission/inet="submission   inet   n   -   n   -   -   smtpd"
postconf -P "submission/inet/syslog_name=postfix/submission"
postconf -P "submission/inet/smtpd_tls_security_level=encrypt"
postconf -P "submission/inet/smtpd_sasl_auth_enable=yes"
postconf -P "submission/inet/milter_macro_daemon_name=ORIGINATING"
postconf -P "submission/inet/smtpd_recipient_restrictions=permit_sasl_authenticated,reject_unauth_destination"
