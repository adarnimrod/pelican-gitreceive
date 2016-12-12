from testinfra.utils.ansible_runner import AnsibleRunner

testinfra_hosts = AnsibleRunner('.molecule/ansible_inventory').get_hosts('all')


def test_git_push(Command, Sudo):
    with Sudo():
        Command('rm -rf /home/git/test /var/tmp/gitreceive')
        push = Command('git -C /root/blog push test')
    assert push.rc == 0
    for message in ['----> Unpacking ...', '----> Fetching submodules ...',
                    '----> Activating virtualenv ...',
                    '----> Building blog ...', 'Copying blog ...',
                    '----> Cleanup ...', '----> OK.']:
        assert message in push.stderr
    with Sudo():
        second_push = Command('git -C /root/blog push test')
    assert second_push.rc == 0
    assert 'Everything up-to-date' in second_push.stderr


def test_blog_website(Command):
    curl = Command('curl http://localhost/')
    assert curl.rc == 0
    assert '<title>My notes and rumblings</title>' in curl.stdout
    assert 'Mockingbird theme' in curl.stdout
