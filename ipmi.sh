#!/bin/bash

export PATH="@curl@/bin:@coreutils@/bin:@gawk@/bin:@gnused@/bin:@gnugrep@/bin:/run/setuid-programs:@ipmitool@/bin:@iputils@/bin:@inetutils@/bin:@xdotool@/bin:/run/wrappers/bin:$PATH"
export _JAVA_AWT_WM_NONREPARENTING=1

if grep 'docker\|lxc' /proc/1/cgroup
then
    inside_container=1
else
    inside_container=0
fi

IPMI_HOST=$1
IPMI_OUTPUT=/tmp/"$IPMI_HOST".jviewer.jnlp
IPMI_USER=ADMIN
IPMI_PASSWORD=${2:-$IPMI_PASSWORD}

if [ $inside_container -eq 0 ]
then
    ping -c 1 "$IPMI_HOST" || exit 1
fi
IPMI_VERSION="$(set -x; ipmitool -H "$IPMI_HOST"  -U "$IPMI_USER" -P "$IPMI_PASSWORD" mc info | awk '/Firmware Revision/ {print $NF}')"
IPMI_OUTPUT_CLEAN=${IPMI_OUTPUT_CLEAN:-1}
XDOTOOL=${XDOTOOL:-0}

help_main()
{
    echo "Usage: ipmi jenkins.ipmi.intr IPMI_PASSWORD"
}

[[ "$VNCDESKTOP" ]] \
    || export _JAVA_OPTIONS='-Dsun.java2d.opengl=true -Ddeployment.security.level=MEDIUM -Djava.util.prefs.systemRoot=/tmp/.java -Djava.util.prefs.userRoot=/tmp/.java/.userPrefs -Ddeployment.system.config=/tmp/.java/deployment.properties -Ddeployment.system.config.mandatory=true'

[ $inside_container -eq 1 ] && unset _JAVA_OPTIONS

cookie()
{
    curl --insecure --silent \
         --data "WEBVAR_USERNAME=$IPMI_USER&WEBVAR_PASSWORD=$IPMI_PASSWORD" \
         https://"$IPMI_HOST"/rpc/WEBSES/create.asp \
        | grep SESSION_COOKIE \
        | cut -d\' -f 4
}

download ()
{
    grep -e session_expired -e '404 - Not Found' "$IPMI_OUTPUT" && rm -f "$IPMI_OUTPUT"
    if ! grep "$IPMI_HOST" "$IPMI_OUTPUT"
    then
        COOKIE="$(cookie)"
        [[ -z "$COOKIE" ]] \
            || curl --insecure --silent \
                    --cookie Cookie=SessionCookie="$COOKIE" \
                    https://"$IPMI_HOST"/Java/jviewer.jnlp \
                    --output "$IPMI_OUTPUT"
    fi
    grep -e session_expired -e '404 - Not Found' "$IPMI_OUTPUT" && rm -f "$IPMI_OUTPUT"
    if ! grep "$IPMI_HOST" "$IPMI_OUTPUT"
    then
        COOKIE="$(cookie)"
        [[ -z "$COOKIE" ]] \
            || curl --insecure --silent\
                    --cookie Cookie=SessionCookie="$COOKIE" \
                    --output "$IPMI_OUTPUT" \
                    "https://$IPMI_HOST/Java/jviewer.jnlp?EXTRNIP=$IPMI_HOST&JNLPSTR=JViewer"
    fi
    grep -e session_expired -e '404 - Not Found' "$IPMI_OUTPUT" && rm -f "$IPMI_OUTPUT"
    if ! grep "$IPMI_HOST" "$IPMI_OUTPUT"
    then
        COOKIE="$(curl -d "name=$IPMI_USER&pwd=$IPMI_PASSWORD" "https://$IPMI_HOST/cgi/login.cgi" --silent --insecure -i | awk '/Set-Cookie.*path/ && NR != 2 { print $2 }' | sed -e 's:;::g')"
        [[ -z "$COOKIE" ]] \
            || curl --silent --insecure --cookie Cookie="$COOKIE" -H "Referer: http://$IPMI_HOST/cgi/url_redirect.cgi?url_name=sys_info" --output "$IPMI_OUTPUT" "https://$IPMI_HOST/cgi/url_redirect.cgi?url_name=ikvm&url_type=jwsk"
    fi
    grep -e session_expired -e '404 - Not Found' "$IPMI_OUTPUT" && rm -f "$IPMI_OUTPUT"
    if ! grep "$IPMI_HOST" "$IPMI_OUTPUT"
    then
        COOKIE=$(curl -d "name=$IPMI_USER&pwd=$IPMI_PASSWORD" "https://$IPMI_HOST/cgi/login.cgi" --silent --insecure -i | awk '/Set-Cookie.*path/ && NR != 2 { print $2 }' | sed -e 's:;::g' -e 's:SID=::g')
        [[ -z "$COOKIE" ]] \
            || curl --silent --insecure --cookie Cookie=SID="$COOKIE" "https://$IPMI_HOST/cgi/Build_jnlp.cgi"
               curl --silent --insecure --cookie Cookie=SID="$COOKIE" "https://$IPMI_HOST/jnlp/sess_$COOKIE.jnlp" --output "$IPMI_OUTPUT"
   fi
        echo -e "COOKIE is $COOKIE\nIPMI_HOST is $IPMI_HOST\nIPMI_USER is $IPMI_USER\nIPMI_PASSWORD is $IPMI_PASSWORD\n"
        grep -e session_expired -e '404 - Not Found' "$IPMI_OUTPUT" && echo "ipmi_session is expired or 404" && rm -f "$IPMI_OUTPUT" && exit 1
}

one()
{
    download
    LANG=@glibcLocales@/lib/locale/locale-archive
    if grep "$IPMI_HOST" "$IPMI_OUTPUT"
    then
        if [ "$XDOTOOL" -eq 1 ]
        then
            LC_ALL=C @mjAdoptopenjdkIcedteaWeb7@/bin/javaws -Xnosplash -wait -verbose "$IPMI_OUTPUT" &
            sleep 3
            xdotool key Tab
            xdotool key Tab
            xdotool key space
            sleep 3
        else
            LC_ALL=C @mjAdoptopenjdkIcedteaWeb7@/bin/javaws -Xnosplash -wait -verbose "$IPMI_OUTPUT"
        fi
    fi
}

two()
{
    download
    LANG=@glibcLocales@/lib/locale/locale-archive
    sed -i "$IPMI_OUTPUT" -e 's@http://@https://@g' -e 's@:80/@:443/@g'
    [ $inside_container -eq 1 ] \
        && grep "$IPMI_HOST" "$IPMI_OUTPUT" \
        && LC_ALL=C @adoptopenjdkIcedteaWeb@/bin/javaws "$IPMI_OUTPUT"
    grep "$IPMI_HOST" "$IPMI_OUTPUT" \
        && LC_ALL=C @mjAdoptopenjdkIcedteaWeb8Javaws@/bin/mj-adoptopenjdk-icedtea-web8-hfs "$IPMI_OUTPUT"
}

three()
{

    download
    [ $inside_container -eq 1 ] \
        && grep "$IPMI_HOST" "$IPMI_OUTPUT" \
        &&  LC_ALL=C @adoptopenjdkIcedteaWeb@/bin/javaws "$IPMI_OUTPUT"
    grep "$IPMI_HOST" "$IPMI_OUTPUT" \
        && LC_ALL=C @mjAdoptopenjdkIcedteaWeb8Javaws@/bin/mj-adoptopenjdk-icedtea-web8-hfs "$IPMI_OUTPUT"
}

case "$1" in
    *.intr|*.ipmi)
        case "$IPMI_VERSION" in
            3.71|3.70|3.74|2.50|3.15|1.58|3.13)
                echo  "------------------------------------------------------------------------------------"
                echo  "--------------  detected firmware $IPMI_VERSION launch case for 3.71 ------------------------"
                echo  "------------------------------------------------------------------------------------"
                two
                ;;
            2.77)
                echo  "------------------------------------------------------------------------------------"
                echo  "-------------- detected firmware $IPMI_VERSION launch case for 2.77 -------------------------"
                echo  "------------------------------------------------------------------------------------"
                three
                ;;
            1.33|2.04|1.17|1.31|2.06|1.35|1.07|1.32|2.02|1.05|2.08|2.01|3.27|2.60|1.15|3.16)
                echo  "------------------------------------------------------------------------------------"
                echo  "-------------- detected firmware $IPMI_VERSION launch case for 1.33 -------------------------"
                echo  "------------------------------------------------------------------------------------"
                one
                ;;
            *)
                echo  "------------------------------------------------------------------------------------"
                echo  "-------------- unknown firmware method for $IPMI_VERSION version ----------------------------"
                echo  "------------------------------------------------------------------------------------"
                echo  "-------------- try method one for $IPMI_VERSION  ---------------------------------------------------------------"
                one
                echo  "------------------------------------------------------------------------------------"
                sleep 10
                echo "--------------- try method two for $IPMI_VERSION ---------------------------------------------------------------"
                two
                echo  "------------------------------------------------------------------------------------"
                sleep 10
                echo "--------------- try method three for $IPMI_VERSION -------------------------------------------------------------"
                three
                echo  "------------------------------------------------------------------------------------"
                ;;
        esac
        [ "$IPMI_OUTPUT_CLEAN" -eq 1 ] && (
            echo "Deleting: $IPMI_OUTPUT"
            rm --force "$IPMI_OUTPUT"
        )
        ;;
    --help|-h|*)
        help_main
        exit 0
        ;;
esac
