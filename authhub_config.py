#!/usr/bin/python

import sys
import base64
from yaml import dump


def yaml_dump(content, filename):
    '''dump yaml content to file
    '''
    with open(filename, 'w') as f:
        dump(content, f, default_flow_style=False)


def obfuscate_str(stream):
    '''obfuscate string with base64 and rot13 encoding
    '''
    b64_str = base64.b64encode(stream)
    rot13_str = b64_str.encode('rot13')
    return rot13_str


if __name__ == "__main__":
    config_file = sys.argv[1]
    memcache_host = sys.argv[2].split(',')
    postgres_host = sys.argv[3]
    postgres_pass = obfuscate_str(sys.argv[4])

    cfginfo = {}
    cfginfo['memcache'] = memcache_host
    cfginfo['postgres'] = {}
    cfginfo['postgres']['host'] = postgres_host
    cfginfo['postgres']['passwd'] = postgres_pass

    yaml_dump(cfginfo, config_file)
