#!/bin/bash

export PATH="@curl@/bin:@coreutils@/bin:@gawk@/bin:@gnused@/bin:@gnugrep@/bin:@ipmitool@/bin:/run/wrappers/bin:$PATH"
export _JAVA_AWT_WM_NONREPARENTING=1

IPMI_HOST=$2
IPMI_OUTPUT=/tmp/"$IPMI_HOST".jviewer.jnlp
IPMI_USER=ADMIN
IPMI_PASSWORD=$1
IPMI_VERSION="$(ipmitool -H "$IPMI_HOST"  -U "$IPMI_USER" -P "$IPMI_PASSWORD" mc info | awk '/Firmware Revision/ {print $NF}')"

[[ "$VNCDESKTOP" ]] \
    || export _JAVA_OPTIONS='-Dsun.java2d.opengl=true -Ddeployment.security.level=MEDIUM -Djava.util.prefs.systemRoot=/tmp/.java -Djava.util.prefs.userRoot=/tmp/.java/.userPrefs -Ddeployment.system.config=/tmp/.java/deployment.properties -Ddeployment.system.config.mandatory=true'

if grep 'docker\|lxc' /proc/1/cgroup
then
    inside_container=1
else
    inside_container=0
fi

[ $inside_container -eq 1 ] && unset _JAVA_OPTIONS

cookie()
{
    curl --insecure --silent \
         --data "WEBVAR_USERNAME=$IPMI_USER&WEBVAR_PASSWORD=$IPMI_PASSWORD" \
         http://"$IPMI_HOST"/rpc/WEBSES/create.asp \
        | grep SESSION_COOKIE \
        | cut -d\' -f 4
}

download () {
    if ! grep "$IPMI_HOST" "$IPMI_OUTPUT"
    then
        COOKIE="$(cookie)"
        echo -e "COOKIE is $COOKIE\nIPMI_HOST is $IPMI_HOST\nIPMI_USER is $IPMI_USER\nIPMI_PASSWORD is $IPMI_PASSWORD\n"
        [[ -z "$COOKIE" ]] \
            || curl --insecure --silent \
                    --cookie Cookie=SessionCookie="$COOKIE" \
                    http://"$IPMI_HOST"/Java/jviewer.jnlp \
                    --output "$IPMI_OUTPUT"
    fi
    if ! grep "$IPMI_HOST" "$IPMI_OUTPUT"
    then
        COOKIE="$(cookie)"
        [[ -z "$COOKIE" ]] \
            || curl --insecure --silent\
                    --cookie Cookie=SessionCookie="$COOKIE" \
                    --output "$IPMI_OUTPUT" \
                    "https://$IPMI_HOST/Java/jviewer.jnlp?EXTRNIP=$IPMI_HOST&JNLPSTR=JViewer"
        echo -e "COOKIE is $COOKIE\nIPMI_HOST is $IPMI_HOST\nIPMI_USER is $IPMI_USER\nIPMI_PASSWORD is $IPMI_PASSWORD\n"
    fi
    if ! grep "$IPMI_HOST" "$IPMI_OUTPUT"
    then
        echo -e "COOKIE is $COOKIE\nIPMI_HOST is $IPMI_HOST\nIPMI_USER is $IPMI_USER\nIPMI_PASSWORD is $IPMI_PASSWORD\n"
        COOKIE="$(curl -d "name=$IPMI_USER&pwd=$IPMI_PASSWORD" "https://$IPMI_HOST/cgi/login.cgi" --silent --insecure -i | awk '/Set-Cookie.*path/ && NR != 2 { print $2 }' | sed -e 's:;::g')"
        [[ -z "$COOKIE" ]] \
            || curl --silent --insecure --cookie Cookie="$COOKIE" --output "$IPMI_OUTPUT" "https://$IPMI_HOST/cgi/url_redirect.cgi?url_name=ikvm&url_type=jwsk"
    fi
}

one()
{
    download
    LANG=@glibcLocales@/lib/locale/locale-archive
    grep "$IPMI_HOST" "$IPMI_OUTPUT" && \
        LC_ALL=C @mjAdoptopenjdkIcedteaWeb7@/bin/javaws -Xnosplash -wait -verbose "$IPMI_OUTPUT"
    sleep 5
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

case "$IPMI_VERSION" in

    3.71|3.70|3.74|2.50|3.15)
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

    1.33|2.04|1.17|1.31|2.06|1.35|1.07)
        echo  "------------------------------------------------------------------------------------"
        echo  "-------------- detected firmware $IPMI_VERSION launch case for 1.33 -------------------------"
        echo  "------------------------------------------------------------------------------------"
        one
        ;;


    *)
        echo  "------------------------------------------------------------------------------------"
        echo  "-------------- unknown firmware method for $IPMI_VERSION version ----------------------------"
        echo  "------------------------------------------------------------------------------------"
        echo  "-------------- use method one ---------------------------------------------------------------"
        one
        echo  "------------------------------------------------------------------------------------"
        sleep 10
        echo "--------------- use method two ---------------------------------------------------------------"
        two
        echo  "------------------------------------------------------------------------------------"
        sleep 10
        echo "--------------- use method three -------------------------------------------------------------"
        three
        echo  "------------------------------------------------------------------------------------"
        ;;
esac
