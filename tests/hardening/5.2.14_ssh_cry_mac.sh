# shellcheck shell=bash
# run-shellcheck
test_audit() {
    describe Running on blank host
    register_test retvalshouldbe 1
    register_test contain "openssh-server is installed"
    # shellcheck disable=2154
    run blank /opt/debian-cis/bin/hardening/"${script}".sh --audit-all

    describe Correcting situation
    # `apply` performs a service reload after each change in the config file
    # the service needs to be started for the reload to succeed
    service ssh start
    # if the audit script provides "apply" option, enable and run it
    sed -i 's/audit/enabled/' /opt/debian-cis/etc/conf.d/"${script}".cfg
    /opt/debian-cis/bin/hardening/"${script}".sh || true

    describe Checking resolved state
    register_test retvalshouldbe 0
    register_test contain "[ OK ] ^MACs[[:space:]]*umac-128-etm@openssh.com,umac-64-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128@openssh.com,umac-64@openssh.com,hmac-sha2-512,hmac-sha2-256 is present in /etc/ssh/sshd_config"
    run resolved /opt/debian-cis/bin/hardening/"${script}".sh --audit-all
}
