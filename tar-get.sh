#!/bin/bash
TG_LIST="pkg_list logs home www etc"
function help(){
	echo "$1: prepare tar.gz files from custom targets."
	echo "Parameters:"
	echo "-Space separated target list being the next targets available: "
	echo " $TG_LIST"
	echo "--full:  to use all the targets. Uncompatible with target list."
	echo "--output: filenam.tar.gz."
}

##validate arguments
LSW=0
TARGETS=""
FULL=0
for ARG in $*
do
	if [ $ARG == $0 ];then
		continue
	fi

	if [ $ARG == "--help" ];then
		help $0
		exit 0
	fi

	if [ $ARG == "--full" ];then
		FULL=1
		continue
	fi

	if [ $ARG == "--output" ];then
		LSW=1
	else
		if [ $LSW -eq 1 ];
		then
			FOUT=$ARG
			LSW=0
		else
			TARGETS="$TARGETS $ARG"
		fi
	fi
done

if [ $FULL -eq 1 ];then
	if [ -z $TARGETS ];then
		TARGETS=$TG_LIST
	else
		echo "Not allowed targets with --full option."
		echo "Type $0 --help for usage."
		exit -1
	fi
else
	if [ -z "${TARGETS}// " ];then
		echo "There are not targets or --full mode."
		echo "Type $0 --help for usage."
		exit -1
	fi

 	if [ -z $FOUT ]; then
		echo "There are not output file name."
		echo "Type $0 --help for usage."
		exit -1
	fi
fi

TPATH="$FOUT.tmp"
if [ -d $TPATH ];
then
	rm -R $TPATH
fi
mkdir $TPATH

#be sure same targets described in TG_LIST
for T in $TARGETS
do
	case $T in
	"pkg_list")
		#dump debian pkglist
		dpkg -l > $TPATH/dpkg-l.txt
		;;

	"logs")
		tar zcpf $TPATH/logs.tar.gz /var/log/
		;;

	"www")
		tar zcpf $TPATH/www.tar.gz /var/www/ /usr/lib/cgi-bin
		;;

	"home")
		tar zcpf $TPATH/home.tar.gz /home /root 
		;;

	"etc")
		tar cpfz $TPATH/etc.tar.gz /etc/
		;;
	*)
		rm -R $TPATH
		echo "Target $T not available."
		echo "Type $0 --help for usage."
		exit -1
	esac

	if [ $? -ne 0 ];then
		echo "Exception executing target $T"
		rm -R $TPATH
		exit -1
	fi
done

tar cpf $FOUT $TPATH
rm -R $TPATH
echo "$FOUT Done."
