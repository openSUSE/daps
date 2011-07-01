#!/bin/bash

TEMP=$(getopt -o e:d:l:n:p:u:x \
  --long debug,def:,extdir:,lang:,name:,obsuser:,product:,pdf:,user: \
  -n "$0" -- "$@")
# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

check_file () {
  [ -f $1 ] || { echo "*** $1 does not exist" ; exit 1 ; }
}

check_dir () {
  [ -d $1 ] || { echo "*** $1 does not exist" ; exit 1 ; }
}

check_bin () {
  which $1 >/dev/null || { echo "*** $1 is not executable" ; exit 1 ; }
}

# default
obsuser=keichwa
while true ; do
  case "$1" in
    -e|--extdir) packdir=$2 ; extdir=true ; check_dir $packdir; shift 2 ;;
    -d|--def)    product_file=$2 ; check_file $product_file; shift 2 ;;
    -l|--lang)   LL=$2 ; shift 2 ;;
    -p|--pdf)    pdf=$2 ; check_file $pdf; shift 2 ;;
    -n|--name|--product) product=$2 ; shift 2 ;;
    -u|--user|--obsuser) obsuser=$2 ; shift 2;;
    -x|--debug)  set -x; shift 1 ;;
    --) shift ; break ;;
  esac
done
echo $extdir

# xmlstarlet
check_bin xml

[ -z "$product" ] && {
  echo "specify '-n product' (without _LL)"
  exit 1
}

#echo $product_file $pdf $product
#exit

if [ -z "$LL" ]; then
  # LL=$(make VARIABLE=LL showvariable)
  LL=$(basename $(pwd))
fi
# product=opensuse-manual
#product=$2
package=${product}_$LL
flavor=${product%%-*}
case $flavor in
  sled) slash_flavor=/sled ;;
  sles) slash_flavor=/sles ;;
  # opensuse) slash_flavor=/opensuse ;;
  *) slash_flavor= ;;
esac
# use version from $DISTVER??
version=11.2.42
notice="Automatically generated out of the docs SVN"
spec_in=${DTDROOT}/etc/book.spec.in
spec=autobuild/${product}_${LL}.spec
# comment if packages are to be built
#echo=echo

make_package () {
  $echo make validate || exit 1
  $echo make package || exit 1
}

write_pdf_spec () {
  [ $1 = 0 ] && n="" || n=$1
  l=$2
  pdf_no=$2
  readme_no=$2
  if [ "$status" = dummy ]; then
    echo "This is a placeholder document." >autobuild/README-$n.txt
    sed -i "/^#SOURCES/i\\
Source$n$((l++)): README-$n.txt" $spec

  else
  sed -i "/^#SOURCES/i\\
Source$n$((l++)): ${BOOK}_$LL.pdf\\
#Source$n$((l++)): ${BOOK}_$LL-graphics.tar.bz2\\
#Source$n$((l++)): ${BOOK}_$LL.tar.bz2\\
Source$n$l: ${BOOK}_$LL-pdf-yelp.tar.bz2" $spec
  sed -i "/^#PDFPREP/i\\
tar xvf %{S:$n$((l++))}" $spec

#  if [ -f autobuild/${BOOK}_$LL-graphics.tar.bz2 ]; then \
#    sed -i 's/^#\(Source.*graphics.tar.bz2\)/\1/' $spec
#  fi
  if [ -f autobuild/$3-LICENSE.txt ]; then
    # grep -s -q '^Source.*LICENSE.txt' $spec \
    #  ||
    lic_no=$((l++))
    sed -i "/^#SOURCES/i\\
Source$n$lic_no: $3-LICENSE.txt" $spec
  elif [ -f autobuild/LICENSE.txt ]; then
    lic_no=$((l++))
    sed -i "/^#SOURCES/i\\
Source$n$lic_no: LICENSE.txt" $spec
  fi
#   sed -i "/^#PDFPREP/i\\
# cp %{S:${n}$pdf_no} ." $spec
  fi
  #On 11.1 renaming apparmor-admin -> opensuse-apparmor-admin
  case ${BOOK} in
    opensuse-apparmor-admin) pdf_prov="Provides: apparmor-admin_$LL-pdf"
      pdf_obs="Obsoletes: apparmor-admin_$LL-pdf <= 11.0"
      ;;
    *) pdf_prov=""; pdf_obs="" ;;
  esac

  book=$(echo $BOOK | tr [[:upper:]] [[:lower:]])
  sed -i "/^#PDFSUB/i\\
\%package -n ${book}_$LL-pdf\\
Group:        Documentation/SuSE\\
License:      -\\
Summary:      -\\
#Provides:    locale(desktop-data-openSUSE:$LL)\\
###PDFOBS" $spec
  if [ "$pdf_obs" != "" ]; then
    sed -i "/^#PDFSUB/i\\
$pdf_prov\\
$pdf_obs" $spec
    fi
  sed -i "/^#PDFSUB/i\\
\\
\%description -n ${book}_$LL-pdf\\
-\\
" $spec

  if [ "$status" = dummy ]; then
    sed -i "/^#PDFINST/i\\
cp \%{S:$n$readme_no} . \\
" $spec
    sed -i "/^#PDFFILES/i\\
\%files -n ${book}_$LL-pdf\\
\%defattr(-, root, root)\\
\%doc README-$n.txt\\
\\
" $spec
    
  else
    sed -i "/^#PDFINST/i\\
cp \%{S:$n$pdf_no} . \\
mkdir $3 \\
cp \%{S:$n$lic_no} $3/LICENSE.txt \\
\\
" $spec

    sed -i "/^#PDFFILES/i\\
\%files -n ${book}_$LL-pdf\\
\%defattr(-, root, root)\\
\%doc ${BOOK}_$LL.pdf \\
\%doc $3/LICENSE.txt \\
/usr/share/help/${book}_$LL-pdf.document\\
\\
" $spec
  fi

  if [ $format = pdfhtml ]; then
    sed -i '/^%package pdf/,/^-$/d;/^%files pdf/,/^#PDFXXX$/d' \
      $spec
  fi
}

do_copyright () {
  # do_copyright $copyright L_FILENAME $3
  copyright=$1
  fname=$2
  cflavor=$3
  if [ $cflavor != "na" ]; then
    sed "/ *Copyright/{N;s/\\n//;}
s/<?dbtimestamp format=\"Y\"?>/$(date +%Y)/" xml/$copyright \
  > xml/$copyright.tmp
    xsltproc --nonet --xinclude --output $fname \
      ${DTDROOT}/xslt/misc/get-textonly.xsl \
      xml/$copyright.tmp
    rm -f xml/$copyright.tmp
    cp -p $fname autobuild/$fname
  else
    cat >autobuild/$fname <<EOF
Copyright © 2009 Novell, Inc. All rights reserved. No part of this
publication may be reproduced, photocopied, stored on a retrieval
system, or transmitted without the express written consent of the
publisher. Novell, the Novell logo, the N logo, openSUSE, SUSE, and the
"geeko" logo are trademarks of Novell, Inc. in the United States and
other countries.  All third-party trademarks are the property of their
respective owners. A trademark symbol (®, TM, etc.) denotes a Novell
trademark; an asterisk (*) denotes a third-party trademark.
EOF
  fi
}

make_pdfhtml () {
  n=$2
  [ $n = 0 ] && n=""
  l=0
  . ENV-$1
  rm -f profiled/dist/*.xml
  if [ "$status" = dummy ]; then
    if [ "$2" = 0 ]; then
      s=$l
    else
      s=$2$l
    fi
    sed -i "/^#PREP/i\\
mkdir html\\
cp %{S:$s} html/index.html" $spec

    echo "<p>This is a placeholder document.</p>" >autobuild/index.html
    sed -i "s|^\%dir \%{_datadir}/help||
s|^\%{_datadir}/help/\*||
/^#SOURCES/i\\
Source$s: index.html" $spec
    echo $((l++))
  else

  # do not "make package" if files are externally (Dublin) provided
  if [ -z "$extdir" ]; then
    make_package
    do_copyright $copyright LICENSE.txt $3
    ### if internally generated, set default packdir
    packdir=package-$1
  fi

  cp -p $packdir/${1}_$LL-{html,graphics,desktop}.tar.bz2 \
    autobuild
  # Externally built package might come with a LICENSE file
  if [ -f $packdir/$1-LICENSE.txt ]; then
    cp -p $packdir/$1-LICENSE.txt autobuild
  else
    : cp ~ke/suse/sle-LICENSE.txt autobuild/$1-LICENSE.txt
  fi
  [ -f autobuild/LICENSE.txt ] || cp autobuild/$1-LICENSE.txt autobuild/LICENSE.txt
  sed -i "s:@BOOK@:$BOOK:" $spec
  #HTML
  sed -i "/^#SOURCES/i\\
Source$n$((l++)): ${BOOK}_$LL-html.tar.bz2\\
Source$2$((l++)): ${BOOK}_$LL-desktop.tar.bz2\\
#Source$2$((l++)): ${BOOK}_$LL-graphics.tar.bz2\\
Source$2$((l++)): ${BOOK}_$LL.tar.bz2" $spec
  if [ -f autobuild/${BOOK}_$LL-graphics.tar.bz2 ]; then \
    sed -i 's/^#\(Source.*graphics.tar.bz2\)/\1/' $spec
  fi
  # ${n}0 == html files
  # ${n}1 == desktop files
  if [ -z $n ]; then
  sed -i "/^#PREP/i\\
%setup -c -q -a ${n}1" $spec
  else
    # Do not remove already installed sources
    sed -i "/^#PREP/i\\
%setup -D -T -q -a ${n}0 -a ${n}1" $spec
  fi #HTML
  #PDF starts
  cp -p $packdir/${1}_${LL}.tar.bz2 \
    $packdir/${1}_$LL.pdf \
    $packdir/${1}_$LL-pdf-yelp.tar.bz2 autobuild || {
    echo make package failed; exit 1
  }
  # in case we must build more than one book (desktop-qs)
  [ -z "$extdir" ] && unset packdir
  # Re-use existing PDF
  [ -n "$pdf" ] && cp -vp $pdf autobuild/${1}_$LL.pdf
  fi #dummy
write_pdf_spec $2 $l $1
}

### Create a PDF subpackage in addition to an HTML package
make_pdfsub () {
  # echo $1
  . ENV-$1
  rm -f profiled/dist/*.xml
  if [ "$status" = dummy ]; then
    :
  else
    if [ -z "$extdir" ]; then
      $echo make validate || exit 1
      $echo make package-pdf || exit 1
  # $echo make pdf-color
  # sources and graphics come with the HTML package
      cp -p package-pdf-$1/${1}_$LL.pdf \
        package-pdf-$1/${1}_$LL-pdf-yelp.tar.bz2 autobuild || {
        echo make package failed; exit 1
      }
  # Re-use existing PDF
      [ -n "$pdf" ] && cp -vp $pdf autobuild/${1}_$LL.pdf
    else
      cp -p $packdir/${1}_$LL.pdf \
        $packdir/${1}_$LL-pdf-yelp.tar.bz2 autobuild
    fi
    do_copyright $copyright $1-LICENSE.txt $3
  fi
  write_pdf_spec $2 0 $1
}

make_pdfonly () {
  # echo $1
  . ENV-$1
  rm -f profiled/dist/*.xml
  make_package
  # $echo make pdf-color
  # $echo make dist-book dist-graphics
  # # copy the PDF and the source files.
  cp -p package-$1/${1}_$LL-graphics.tar.bz2 \
    autobuild
  cp -p package-$1/${1}_${LL}.tar.bz2 \
    package-$1/${1}_$LL.pdf autobuild || {
    echo make package failed; exit 1
  }
# {
#   cp -p ${1}-online.pdf autobuild/${1}_$LL.pdf && \
#   cp -p ${1}_${LL}{,-graphics}.tar.bz2 autobuild
# } || {
#   echo make package failed; exit 1
# }
  # Re-use existing PDF
  [ -n "$pdf" ] && cp -vp $pdf autobuild/${1}_$LL.pdf

  if [ $3 != "na" ]; then
    xsltproc --nonet --xinclude --output LICENSE.txt \
      ${DTDROOT}/xslt/misc/get-textonly.xsl \
      xml/$copyright
    cp -p LICENSE.txt autobuild
  else
    cat >autobuild/LICENSE.txt <<EOF
Copyright © 2008 Novell, Inc. All rights reserved. No part of this
publication may be reproduced, photocopied, stored on a retrieval
system, or transmitted without the express written consent of the
publisher. Novell, the Novell logo, the N logo, openSUSE, SUSE, and the
"geeko" logo are trademarks of Novell, Inc. in the United States and
other countries.  All third-party trademarks are the property of their
respective owners. A trademark symbol (®, TM, etc.) denotes a Novell
trademark; an asterisk (*) denotes a third-party trademark.
EOF
  fi
  write_pdf_spec $2 0
}

make_pdf () {
  # echo $1
  . ENV-$1
  rm -f profiled/dist/*.xml
  if [ -z "$extdir" ]; then
    make_package
    packdir=package-$1
  fi
  # copy the PDF and the source files.
  [ $3 != "na" ] && \
    { xsltproc --nonet --xinclude --output LICENSE.txt \
      ${DTDROOT}/xslt/misc/get-textonly.xsl \
      xml/$copyright
      cp -p LICENSE.txt autobuild
    }
  cp -p $packdir/${1}_${LL}{,-graphics}.tar.bz2 \
    $packdir/${1}_$LL.pdf autobuild || {
    echo make package failed; exit 1
  # cp -p package-$1/${1}_${LL}{,-graphics}.tar.bz2 \
  #   package-$1/${1}_$LL.pdf autobuild || {
  #   echo make package failed; exit 1
  }
  # Re-use existing PDF
  [ -n "$pdf" ] && cp -vp $pdf autobuild/${1}_$LL.pdf

  write_pdf_spec $2 0
}

make_html () {
  . ENV-$1
  rm -f profiled/dist/*.xml
  # number for source files
  l=0
  if [ "$status" = dummy ]; then
    if [ "$2" = 0 ]; then
      s=$l
    else
      s=$2$l
    fi
    sed -i "/^#PREP/i\\
mkdir html\\
cp %{S:$s} html/index.html" $spec

    echo "<p>This is a placeholder document.</p>" >autobuild/index.html
    sed -i "s|^\%dir \%{_datadir}/help||
s|^\%{_datadir}/help/\*||
/^#SOURCES/i\\
Source$s: index.html" $spec
    echo $((l++))
  else
    # build the real package
    if [ -z "$extdir" ]; then
      $echo make validate || exit 1
      $echo make package-html || exit 1
      do_copyright $copyright LICENSE.txt $3
      cp -p package-html-$1/${1}_$LL-{graphics,html,desktop}.tar.bz2 \
        package-html-$1/${1}_$LL.tar.bz2 autobuild
    else
      cp -p $packdir/${1}_$LL-{html,graphics,desktop}.tar.bz2 \
        $packdir/${1}_$LL.tar.bz2 autobuild
    fi
  sed -i "s:@BOOK@:$BOOK:" $spec
  sed -i "/^#SOURCES/i\\
Source$2$((l++)): ${BOOK}_$LL-html.tar.bz2\\
Source$2$((l++)): ${BOOK}_$LL-desktop.tar.bz2\\
#Source$2$((l++)): ${BOOK}_$LL-graphics.tar.bz2\\
Source$2$((l++)): ${BOOK}_$LL.tar.bz2" $spec
    if [ -f autobuild/${BOOK}_$LL-graphics.tar.bz2 ]; then \
      sed -i 's/^#\(Source.*graphics.tar.bz2\)/\1/' $spec
    fi
  # ${no}0 == html files
  # ${no}1 == desktop files
    ### FIXME
    ### Improve this as follows (in make_pdfsub):
# The opensuse-manual_en-pdf and opensuse-manual_de-pdf packages are
# intentionally empty; we use these packages for obsoleting old PDF packages. The
# PDF flavors of the books are packaged separately as
# 
# opensuse-apparmor-quick_en-pdf
# opensuse-apps_en-pdf
# opensuse-gnomequick_en-pdf
# opensuse-gnomeuser_en-pdf
# opensuse-kdequick_en-pdf
# opensuse-kdeuser_en-pdf
# opensuse-reference_en-pdf
# opensuse-startup_en-pdf 
    sed -i "/^#PREP/i\\
%setup -c -q -a ${no}1\\
#echo \"This PDF package is empty.  Find the PDFs in sub-packages.\" >README-pdf" $spec
#    sed -i "/^#PDFXXX/i\\
#%doc README-pdf" $spec
  fi
}

set_obs_in_spec () {
  sed -i "\
/^#OBS/i\\
Obsoletes:      $obs\\
Provides:       $obs
" $spec
  if [ -n "$pdfobs" ]; then
    sed -i "\
/^#PDFOBS/i\\
Obsoletes:      $pdfobs\\
Provides:       $pdfobs
" $spec
  fi
}

edit_spec_obsoletes_provides () {
  if [ $product = opensuse-manuals ]; then
  # rename opensuse-manual to opensuse-manuals on 11.2
    obs="$obs opensuse-manual_$LL"
  # quickstarts are part of opensuse-manual since 10.3
    obs="$obs opensuse-quickstart_$LL"
  # kde and gnome quickstarts are part of opensuse-manual (since 11.1)
    obs="$obs opensuse-kdequick_$LL opensuse-gnomequick_$LL"
    obs="$obs opensuse-gnomeuser_$LL opensuse-kdeuser_$LL opensuse-kde3user_$LL"
  # apparmor-admin (HTML) is gone with 11.1
    obs="$obs apparmor-admin_$LL"

    for l in $obs; do
      # skip books shipped as stand-alone PDFs since 11.1
      case $l in
        opensuse-kdequick_$LL|opensuse-gnomequick_$LL|apparmor-admin_$LL|opensuse-gnomeuser_$LL|opensuse-kdeuser_$LL) true ;;
        *) pdfobs="$pdfobs ${l}-pdf" ;;
      esac
    done
    # 11.3: opensuse-manuals_$LL-pdf is gone; use the base package
    obs="$obs opensuse-manuals_$LL-pdf $pdfobs"
    pdfobs=""
    set_obs_in_spec
  elif [ $product = sled-manuals ]; then
    # obsolete since sle11
    obs="$obs sled-deployment_$LL sled-gnome-user_$LL sled-kde-user_$LL"
    obs="$obs sled-desktop-qs_$LL sled-install-qs_$LL"
    set_obs_in_spec
  else
  # gnomeuser and similar books
    sed -i '/.*my_prov_obs.*/d' $spec
  fi


case $flavor in
  # On SLED and SLES 11 we have desktop-data-SLED
  SLED|SLES|SLEHA)
    sed -i 's/^\(Provides:.*locale(\)\(desktop-data\)\(-openSUSE\)/\1\2-SLED/' $spec
    ;;
esac

#case $product in
#  # kde3user is separate on os 11.1
#  opensuse-kde3user)
#    sed -i 's/^\(Provides:.*locale(\)desktop-data\(-openSUSE\)/\1kde3base-session/' $spec
#    ;;
#  # package the opensuse-apparmor-admin separately, but do not add it to the desktop
#  # comment it on openSUSE; check again on SLES
#  opensuse-apparmor-admin)
#    sed -i 's/^\(Provides:.*locale(\)desktop-data-openSUSE:/#\1apparmor-docs:/' \
#      $spec
#    ;;
#esac
}

#####
##### programm starts here
#####
rm -fr autobuild LICENSE.txt
mkdir autobuild

flavor=$(echo $flavor | tr [[:lower:]] [[:upper:]])
flavor=${flavor/OPEN/open}
# spec file header
sed "\
s:@package@:$package:
s:@product@:$product:
s:@notice@:$notice:
s:@LL@:$LL:
s:@slash_flavor@:$slash_flavor:
s:@flavor@:$flavor:
" $spec_in > $spec
# # make the en docs replace the other langs not available on os 10.2
# [ $LL = en ] && \
#   sed -i "\
# /^Provides:[ 	]*locale.*/d
# " $spec


edit_spec_obsoletes_provides

prep_xbs () {
  sr_server=${1:-https\://api.opensuse.org}
  sr_repo=${2:-openSUSE\:Factory}
# finally prep package dir for the build system
  [ -d $package ] && old $package
# sle10-sp-i386 sle10-sp-s390x sle10-sp-ppc sles10-i386 sles10-s390x sles10-ppc"
# adjust for OBS
  case $package in
    sle*) dist="sle11 noarch i586"    ;;
    *) dist="noarch head-i586"    ;;
  esac
  {
    osc -A $sr_server branch $sr_repo $package
    # check whether a devel project exists
    devel=$(osc -A $sr_server meta pkg $sr_repo $package \
      | xml sel -t -v //devel/@project)
    repo=${devel:-$sr_repo}
    osc -A $sr_server co home:$obsuser:branches:$repo/$package
  } || {
    echo $package not accessible by osc
    install -d $package
  }
# the quickbooks need special treatment
# is this still valid?
  if [ -f $package/dot.directory ]; then
    sed -i "/^#SOURCES/i\\
Source100: dot.directory" $spec
  fi
  sed -i "\
s:@version@:${DISTVER:-$version}:
" $spec
  cp -vp autobuild/* home:$obsuser:branches:$repo/$package
  ### 
  cd home:$obsuser:branches:$repo/$package
  bash ./pre_checkin.sh
  osc ci -m"Update $package"

  echo "osc -A $sr_server sr home:$obsuser:branches:$repo $package $sr_repo"
}

###
### main
###
# read the product file
no=0
:>pack.log
while read format book copyright status server prj; do
  # Make sure to preserve a value once set
  [ -n "$server" ] && xbs_server=$server
  [ -n "$prj"    ] && xbs_prj=$prj
  echo $format $book | tee -a pack.log
  case $format in
    pdfhtml) make_pdfhtml $book $no $copyright $status
      ;;
    # Do not try to build html and the desktop files (fails for articles)
    pdfonly) make_pdfonly $book $no $copyright;;
    pdfsub) make_pdfsub $book $no $copyright;;
    pdf) make_pdf $book $no $copyright;;
    html) make_html $book $no $copyright;;
    *) echo "Unsupported output format: $format"; exit 1;;
  esac
  status=''
  echo $no | tee -a pack.log
  echo $((no++)) >/dev/null
done < <(grep -v ^# $product_file)

prep_xbs $xbs_server $xbs_prj

exit 0
