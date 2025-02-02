# Created by Tim de Boer
# Feel free to contact me with improvements or suggestions via GitHub:
# https://github.com/tim427
 
# jan/27/2023 03:46:19 by RouterOS 7.7
#
# model = CHR
 
# Testing has only been done on a CHR-VM with RouterOS 7.7 Proceed with caution.

/routing bgp template  # If not already setted up
set default address-families=ip,ipv6 as=4200000001 disabled=no  # Replace the local AS with something appropriate
/routing bgp connection
add address-families=ip,ipv6 comment=rr1.projectton.com disabled=no \
    input.filter=blackhole-projectton-in local.role=ebgp multihop=yes name=\
    peer-projectton output.filter-chain=nothing-out .redistribute="" \
    remote.address=162.208.89.180/32 .as=4212345678 routing-table=main \
    templates=default
/routing filter community-list
add comment=projectton.com disabled=no list=blackhole-projectton communities=\
	blackhole,\
	3166:1234  # Optionally block countries based on ISO-3166 Country Codes
/routing filter rule
add chain=nothing-out comment=projectton.com disabled=no rule="reject;"  # We need a filter that prevents any prefixes from being sent to Project TON
add chain=blackhole-projectton-in comment=projectton.com disabled=no rule="set \
    blackhole yes;\r\
    \nif (bgp-communities any-list blackhole-projectton) {append comment \"Bla\
    ckholed by Project TON\"; accept;} else {append comment \"Received by Proj\
    ect TON\"; reject;}"  # We need to flag as blackhole and accept earlier specfied communities or reject them

# Verify that you are receiving routes by running this command:
# 	/routing/route/print detail where belongs-to="bgp-IP-162.208.89.180" and active