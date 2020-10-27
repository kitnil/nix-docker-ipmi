# ipmi.sh methods

one web24.ipmi.intr
two web15.ipmi.intr
three web16.ipmi.intr

# Hosts

``` shell
dig @172.16.103.2 -tAXFR intr | awk '/ipmi/ {print $1}' | sort -u'
```

```
+ dh4.ipmi.intr.
+ dh5.ipmi.intr.
+ galera1.ipmi.intr.
+ galera2.ipmi.intr.
+ galera3.ipmi.intr.
+ jenkins.ipmi.intr.
+ kvm10.ipmi.intr.
+ kvm16.ipmi.intr.
+ kvm17.ipmi.intr.
+ kvm19.ipmi.intr.
+ kvm1.ipmi.intr.
+ kvm21.ipmi.intr.
+ kvm22.ipmi.intr.
+ kvm23.ipmi.intr.
+ kvm24.ipmi.intr.
+ kvm27.ipmi.intr.
+ kvm30.ipmi.intr.
+ kvm31.ipmi.intr.
+ kvm32.ipmi.intr.
+ kvm34.ipmi.intr.
+ kvm35.ipmi.intr.
+ kvm36.ipmi.intr. is web24
+ kvm38.ipmi.intr. is web32
+ kvm9.ipmi.intr.
+ mj427.ipmi.intr.
+ mj711.ipmi.intr.
+ mj735.ipmi.intr.
+ mj742.ipmi.intr.
+ mj744.ipmi.intr.
+ mj751.ipmi.intr.
+ mj753.ipmi.intr.
+ mj754.ipmi.intr.
+ mj757.ipmi.intr.
+ mj762.ipmi.intr.
+ mj777-node1.ipmi.intr.
+ mj777-node2.ipmi.intr.
+ mj777-node3.ipmi.intr.
+ mj777-node4.ipmi.intr.
+ mj777-node5.ipmi.intr.
+ mj777-node6.ipmi.intr.
+ mj777-node7.ipmi.intr.
+ mj777-node8.ipmi.intr.
+ mj804.ipmi.intr.
- mj806.ipmi.intr. # No session slot available
+ mj807.ipmi.intr.
+ mj811.ipmi.intr.
+ nginx2.ipmi.intr.
+ ns1-mr.ipmi.intr.
+ ns2-mr.ipmi.intr. # Keyborad not working
+ pop1.ipmi.intr.
- pop2.ipmi.intr. # No ping
+ staff.ipmi.intr.
+ web15.ipmi.intr.
+ web16.ipmi.intr.
+ web17.ipmi.intr. # No session slot available
- web18.ipmi.intr. # Need full power cycle
+ web20.ipmi.intr.
+ web21.ipmi.intr.
+ web22.ipmi.intr.
- web23.ipmi.intr. # No session slot available
+ web24.ipmi.intr.
+ web25.ipmi.intr.
+ web26.ipmi.intr.
+ web27.ipmi.intr.
+ web28.ipmi.intr.
+ web29.ipmi.intr.
+ web30.ipmi.intr.
+ web31.ipmi.intr.
+ web33.ipmi.intr.
+ web35.ipmi.intr.
+ web37.ipmi.intr.
+ webmail1.ipmi.intr. # Keyborad not working
+ webmail2.ipmi.intr. # Keyborad not working
+ zabbix.ipmi.intr.
```
