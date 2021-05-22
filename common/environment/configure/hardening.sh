# Enable as-needed by default.
LDFLAGS="-Wl,--as-needed ${LDFLAGS}"
CLANG_VER=$(clang --version | head -n 1 | cut -d' ' -f3 | sed 's/\.//g')
if [ -z "$nopie" ]; then
	# Our compilers use --enable-default-pie and --enable-default-ssp,
	# but the bootstrap host compiler may not, force them.
	if [ -z "$CHROOT_READY" ]; then
		CFLAGS="-fstack-protector-strong -D_FORTIFY_SOURCE=2 ${CFLAGS}"
		CXXFLAGS="-fstack-protector-strong -D_FORTIFY_SOURCE=2 ${CXXFLAGS}"
		_GCCSPECSDIR=${XBPS_COMMONDIR}/environment/configure/gccspecs
		case "$XBPS_TARGET_MACHINE" in
			mips*) _GCCSPECSFILE="${_GCCSPECSDIR}/hardened-mips-cc1" ;;
			*) _GCCSPECSFILE="${_GCCSPECSDIR}/hardened-cc1" ;;
		esac
		CFLAGS="-specs=${_GCCSPECSFILE} ${CFLAGS}"
		CXXFLAGS="-specs=${_GCCSPECSFILE} ${CXXFLAGS}"
		LDFLAGS="-specs=${_GCCSPECSDIR}/hardened-ld -Wl,-z,relro -Wl,-z,now ${LDFLAGS}"
	# Enable FORITFY_SOURCE=2
	elif [ $CLANG_VER -ge 1001 ] || [ "${XBPS_COMPILER}" != "clang" ]; then
		CFLAGS="-fstack-clash-protection -D_FORTIFY_SOURCE=2 -fPIC ${CFLAGS}"
		CXXFLAGS="-fstack-clash-protection -D_FORTIFY_SOURCE=2 -fPIC ${CXXFLAGS}"
		if [ "$XBPS_COMPILER" = "clang" ]; then
			# -pie needed for PIE with clang
			LDFLAGS="-Wl,-z,relro -Wl,-z,now -pie ${LDFLAGS}"
		else
			LDFLAGS="-Wl,-z,relro -Wl,-z,now ${LDFLAGS}"
		fi
	# Clang < 10.0.1
	else
		# Enable FORITFY_SOURCE=2
		CFLAGS="-fstack-clash-protection -D_FORTIFY_SOURCE=2 ${CFLAGS}"
		CXXFLAGS="-fstack-clash-protection -D_FORTIFY_SOURCE=2 ${CXXFLAGS}"
		FFLAGS="-fstack-clash-protection ${FFLAGS}"
		LDFLAGS="-Wl,-z,relro -Wl,-z,now ${LDFLAGS}"
	fi
else
	CFLAGS="-fno-PIE ${CFLAGS}"
	CXXFLAGS="-fno-PIE ${CFLAGS}"
	FFLAGS="-fno-PIE ${FFLAGS}"
	LDFLAGS="-no-pie ${LDFLAGS}"
fi
