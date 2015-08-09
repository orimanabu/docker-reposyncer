#!/usr/bin/python

import re
import sys
from argparse import ArgumentParser

repos={}
repo_title = ""
params = [
    'name',
    'baseurl',
    'enabled',
    'gpgcheck',
    'gpgkey',
    'sslverify',
    'sslcacert',
    'sslclientkey',
    'sslclientcert',
    'metadata_expire',
    'ui_repoid_vars',
]
#exclude_keywords = [
#'-debug-',
#'-source-',
#'-eus-',
#'-htb-',
#'-aus-',
#'-beta-',
#'-fastrack-',
#]

def do_something(filename):
    with open(filename, 'r') as f:
        for _line in f:
            line = _line.rstrip()
            if re.search(r'^$', line):
                continue
            elif re.search(r'^#', line):
                continue
            else:
                match = re.search(r'^\[(.*)\]', line)
                if match:
                    repo_title = match.group(1)
#                    print "XXX %s" % repo_title
                    if not repos.get(repo_title):
                        repos[repo_title] = {}
                else:
                    matched = False
                    for param in params:
                        match = re.search('%s\s+=\s+(.*)' % param, line)
                        if match:
                            repos[repo_title][param] = match.group(1)
                            matched = True
                    if not matched:
                        print "no keys: %s" % (line),

def print_repo(repo, name, url_prefix, enabled, gpgkey):
    print "[%s]" % repo
    print "name =", name
    print "baseurl =", url_prefix + '/' + repo
    print "enabled =", enabled
    if gpgkey:
        print "gpgcheck = 1"
        print "gpgkey =", gpgkey
    else:
        print "gpgcheck = 0"
    print ""

def print_results(url_prefix):
    print_repo('bootstrap', 'bootstrap repository', url_prefix, 1, None)
    for line in sys.stdin:
        repo = line.rstrip()
        if repos.get(repo):
            print_repo(repo, repos[repo]['name'], url_prefix, 0, repos[repo]['gpgkey'])

def parse_args():
    desc = u'''{0} [Args] [Options]
Detailed options -h or --help'''.format(__file__)
    parser = ArgumentParser(description=desc)
    parser.add_argument('-s', '--source-repo', type=str, dest='source_repo', help='source repo file')
    parser.add_argument('-u', '--url-prefix', type=str, dest='url_prefix', help='url prefix')
    args = parser.parse_args()
#    print "(debug) %s: %s" % ('source_repo', args.source_repo)
#    print "(debug) %s: %s" % ('url_prefix', args.url_prefix)
    return args

def main():
    args = parse_args()
    do_something(args.source_repo)
    print_results(args.url_prefix)

if __name__ == '__main__':
    main()
