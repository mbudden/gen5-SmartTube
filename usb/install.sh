#!/system/bin/sh
# One-tap USB install: the stick's NEMESIS.data is type=execute, so the USB
# handler asks once and then runs this as root, with cwd = the stick's root.
# Installs the video codec fix (media.codecs) first if it's missing or too old,
# then SmartTube. Both go through `nemesis install --update`, so an existing
# SmartTube keeps its settings and sign-in.
# Toolbox shell only (no cut/sed/awk/head/tail). Exit 0 shows NEMESIS's success
# dialog, anything else its failure dialog. Log: smarttube-install.log on the stick.
export PATH=/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin
export LD_LIBRARY_PATH=/vendor/lib:/system/lib

CODECS_MIN=@CODECS_MIN_VERSION@
NEMESIS=${NEMESIS:-/system/xbin/nemesis}
case "$0" in */*) HERE=${0%/*} ;; *) HERE=$PWD ;; esac
case "$HERE" in /*) ;; *) HERE=$PWD/$HERE ;; esac
PKGS=$HERE/packages
LOG=$HERE/smarttube-install.log

log() { echo "$(date '+%m-%d %H:%M:%S') $1" >> "$LOG" 2>/dev/null; echo "$1"; }

toast() {
    am broadcast -a com.hkmc.intent.action.TOAST \
        -e com.hkmc.intent.extra.TOAST_MESSAGE "$1" \
        --ez com.hkmc.intent.extra.TOAST_POPUPSHOWING true >/dev/null 2>&1 || true
}

# A service may start without init's framework environment, which am/pm need.
if [ -z "$BOOTCLASSPATH" ] && [ -r /init.environ.rc ]; then
    while read _cmd _name _value; do
        [ "$_cmd" = export ] && export "$_name=$_value"
    done < /init.environ.rc
fi

digits() {
    _d= _s=$1
    while [ -n "$_s" ]; do
        _ch=${_s%"${_s#?}"}; _s=${_s#?}
        case "$_ch" in [0-9]) _d=$_d$_ch ;; esac
    done
    echo "${_d:-0}"
}

# version_ge <a> <b>: a >= b, comparing up to three dot-separated numbers.
version_ge() {
    _a=$1 _b=$2 _i=0
    while [ $_i -lt 3 ]; do
        _pa=${_a%%.*}; _pb=${_b%%.*}
        case "$_a" in *.*) _a=${_a#*.} ;; *) _a= ;; esac
        case "$_b" in *.*) _b=${_b#*.} ;; *) _b= ;; esac
        _pa=$(digits "$_pa"); _pb=$(digits "$_pb")
        [ "$_pa" -gt "$_pb" ] && return 0
        [ "$_pa" -lt "$_pb" ] && return 1
        _i=$((_i + 1))
    done
    return 0
}

# Installed version of a package, or nothing if it isn't installed.
installed_version() {
    _inst= _ver=
    for _line in $("$NEMESIS" pkg-info "$1" 2>/dev/null); do
        case "$_line" in
            installed=*) _inst=${_line#*=} ;;
            installed-version=*) _ver=${_line#*=} ;;
        esac
    done
    [ "$_inst" = 1 ] && echo "${_ver:-0}"
}

install_pkg() {
    log "installing $1"
    "$NEMESIS" install --update "$PKGS/$1" >> "$LOG" 2>&1
    _rc=$?
    log "$1: exit $_rc"
    return $_rc
}

log "--- SmartTube one-tap install"
for z in media.codecs.zip smarttube.zip; do
    [ -f "$PKGS/$z" ] || { log "missing packages/$z on the USB drive"; toast "SmartTube install: packages/$z is missing from the USB drive"; exit 1; }
done

have=$(installed_version media.codecs)
if [ -n "$have" ] && version_ge "$have" "$CODECS_MIN"; then
    log "media.codecs $have already installed, skipping"
else
    toast "Installing the video codec fix..."
    install_pkg media.codecs.zip || { toast "Video codec fix install failed. See smarttube-install.log on the USB drive."; exit 2; }
fi

toast "Installing SmartTube..."
install_pkg smarttube.zip || { toast "SmartTube install failed. See smarttube-install.log on the USB drive."; exit 3; }

log "done"
toast "SmartTube is installed. You can remove the USB drive."
exit 0
