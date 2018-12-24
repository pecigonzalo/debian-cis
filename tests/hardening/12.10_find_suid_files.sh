test_audit() {
    describe Running void to generate the conf file that will later be edited
    # shellcheck disable=2154
    /opt/debian-cis/bin/hardening/"${script}".sh || true
    echo 'EXCEPTIONS="$EXCEPTIONS /usr/lib/dbus-1.0/dbus-daemon-launch-helper"' >> /opt/debian-cis/etc/conf.d/"${script}".cfg

    describe Running on blank host
    register_test retvalshouldbe 0
    register_test contain "No unknown suid files found"
    run blank /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    describe Tests purposely failing
    local targetfile="/home/secaudit/suid_file"
    touch $targetfile
    chmod 4700 $targetfile
    register_test retvalshouldbe 1
    register_test contain "Some suid files are present"
    register_test contain "$targetfile"
    run noncompliant /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    describe correcting situation
    chmod 700 $targetfile

    describe Checking resolved state
    register_test retvalshouldbe 0
    register_test contain "No unknown suid files found"
    run resolved /opt/debian-cis/bin/hardening/"${script}".sh --audit-all
}

