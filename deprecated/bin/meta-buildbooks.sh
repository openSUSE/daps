#!/bin/bash

### SLED
pdir=~ke/src/vistatec/ftp.vistatec.ie/Outgoing/SLE11/delivery/15JAN2009/packages
# installquick
for l in ar de fr it ko pt_BR zh_CN cs es hu ja pl ru zh_TW; do
  ../../novdoc/bin/buildbook.sh \
    -d DEF-SLED-installquick -n sled-installquick \
    -l $l \
    -e $pdir/sled/$l/package-SLED-installquick
done

pdir=~ke/src/vistatec/ftp.vistatec.ie/Outgoing/SLE11/delivery/6Mar2009_Sled_Admin_Gde/SLED-admin
for l in  de zh_CN ja zh_TW; do
  ../../novdoc/bin/buildbook.sh \
    -d DEF-SLED-admin -n sled-admin \
    -l $l \
    -e $pdir/$l/package-SLED-admin
done

pdir=~ke/src/vistatec/ftp.vistatec.ie/Outgoing/SLE11/delivery/15JAN2009/packages
for l in  de; do
  ../../novdoc/bin/buildbook.sh \
    -d DEF-SLED-deployment -n sled-deployment -l $l \
    -e $pdir/sled/$l/package-SLED-deployment
done

for l in  de; do
  ../../novdoc/bin/buildbook.sh     -d DEF-SLED-apps -n sled-apps     -l $l \
    -e $pdir/sled/$l/package-SLED-apps
done

for l in  de; do
  ../../novdoc/bin/buildbook.sh     -d DEF-SLED-gnomeuser -n sled-gnomeuser     -l $l \
    -e $pdir/sled/$l/package-SLED-gnomeuser
done

### SLES

for l in ar de fr it ko pt_BR zh_CN cs es hu ja pl ru zh_TW; do
  ../../novdoc/bin/buildbook.sh     -d DEF-SLES-installquick -n sles-installquick -l $l \
    -e $pdir/sles/$l/package-SLES-installquick
done

for l in  de zh_CN ja zh_TW; do
  ../../novdoc/bin/buildbook.sh \
    -d DEF-SLES-admin -n sles-admin \
    -l $l \
    -e $pdir/sles/$l/package-SLES-admin
done

for l in de ja zh_CN zh_TW; do
  ../../novdoc/bin/buildbook.sh \
    -d DEF-SLES-deployment -n sles-deployment -l $l \
    -e $pdir/sles/$l/package-SLES-deployment
done

exit 0
# EOF
