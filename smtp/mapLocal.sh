#!/bin/bash
sqlMapDir=/etc/postfix/sql/
mkdir -p $sqlMapDir

cat << EOF > $sqlMapDir/mysql_virtual_alias_domain_catchall_maps.cf
user = postfix
password = 111
hosts = data.sysnet.local
dbname = postfix
query  = SELECT goto FROM alias,alias_domain WHERE alias_domain.alias_domain = '%d' and alias.address = CONCAT('@', alias_domain.target_domain) AND alias.active = 1 AND alias_domain.active='1'
EOF

cat << EOF > $sqlMapDir/mysql_virtual_alias_domain_mailbox_maps.cf
user = postfix
password = 111
hosts = data.sysnet.local
dbname = postfix
query = SELECT maildir FROM mailbox,alias_domain WHERE alias_domain.alias_domain = '%d' and mailbox.username = CONCAT('%u', '@', alias_domain.target_domain) AND mailbox.active = 1 AND alias_domain.active='1'
EOF
cat << EOF > $sqlMapDir/mysql_virtual_alias_domain_maps.cf

user = postfix
password = 111
hosts = data.sysnet.local
dbname = postfix
query = SELECT goto FROM alias,alias_domain WHERE alias_domain.alias_domain = '%d' and alias.address = CONCAT('%u', '@', alias_domain.target_domain) AND alias.active = 1 AND alias_domain.active='1'
EOF

cat << EOF > $sqlMapDir/mysql_virtual_alias_maps.cf
user = postfix
password = 111
hosts = data.sysnet.local
dbname = postfix
query = SELECT goto FROM alias WHERE address='%s' AND active = '1'
EOF

cat << EOF > $sqlMapDir/mysql_virtual_domains_maps.cf
user = postfix
password = 111
hosts = data.sysnet.local
dbname = postfix
query = SELECT domain FROM domain WHERE domain='%s' AND active = '1'
EOF

cat << EOF > $sqlMapDir/mysql_virtual_mailbox_limit_maps.cf
user = postfix
password = 111
hosts = data.sysnet.local
dbname = postfix
query = SELECT quota FROM mailbox WHERE username='%s' AND active = '1'
EOF

cat << EOF > $sqlMapDir/mysql_virtual_mailbox_maps.cf
user = postfix
password = 111
hosts = data.sysnet.local
dbname = postfix
query = SELECT maildir FROM mailbox WHERE username='%s' AND active = '1'
EOF



