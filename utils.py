#!/usr/bin/env python
# Copyright (c) 2016 Ford Motor Company,
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of Ford Motor Company nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

from fabric.api import run
from fabric.api import cd
from fabric.contrib.files import exists
from fnmatch import fnmatch
import re


def arch():
    """
    Discover architecture type of workstation
    :return: architecture type of workstation
    """
    return run("uname -p")


def open_dir(dir_path, rewrite=False):
    """
    Opens directory
    Usage example:
    with open_dir("~/work_dir"):
        $ do some staff

    :param dir_path: path of directory to open
    :param rewrite: if yest it will delete existing directory and create new one
    :return: directory object
    """
    if rewrite and exists(dir_path):
        run("rm -rf {}".format(dir_path))
    if not exists(dir_path):
        run("mkdir -p {}".format(dir_path))
    return cd(dir_path)


def clone(host, folder, work_dir, branch=None, submodules=False, rewrite=False):
    """
Clones git repository
    :param host: address of repository
    :param folder: git project folder to clone in
    :param work_dir: parent folder to clone in
    :param branch: checkout on specific branch after clone
    :param submodules: initialize submodules
    :param rewrite: it True delete existing and clone again
    :return: None
    """
    with open_dir(work_dir):
        if exists(folder):
            print ("{} already exists".format(folder))
            if rewrite:
                print ("rewrite {}".format(folder))
                run("rm -rf {}".format(folder))
            else:
                return
        run("git clone {} {}".format(host, folder))
        with cd(folder):
            if branch:
                run("git checkout {}".format(branch))
            if submodules:
                run("git submodule init")
            run("git submodule update")


def get_list_of_failed_test_cases(console_output):
    """
    Return list of failed test cases from ATF console output
    :param console_output: plain text of ATF console output
    :return: list of failed test cases
    """
    failed_list = []
    for line in console_output.split("\n"):
        pos = line.find("[FAIL]")
        if pos != -1:
            failed_list.append(line[0:pos])
    return failed_list


def get_known_issues(data):
    """
    Return map of lists of known failed test cases

    {
    "ScriptName.lua" : ["TestCase1", "TestCase2"]
    }

    :param data: raw string from KnownIssues.md
    :return: map of lists of known issues
    """
    lines = data.split("\n")
    known_issues = {}
    script_reg = re.compile("^\* (.+\.lua):")
    case_reg = re.compile("^  \* (\w+\*?)")
    curr_script = None
    for line in lines:
        script = script_reg.search(line)
        if script:
            curr_script = script.group(1)
            if curr_script not in known_issues:
                known_issues[curr_script] = []
        case = case_reg.search(line)
        if case:
            if (curr_script not in known_issues):
                known_issues[curr_script] = []
            known_issues[curr_script].append(case.group(1))
    return known_issues


def filter_known_issues(failed_list, known_issues):
    """
    Filter known failed test cases from list of failed test cases
    :param failed_list:  list of failed test cases
    :param known_issues: test cases that should be removed from failed_list
    :return: list of new failed test cases
    """
    filtered = []

    def is_known(case):
        for known in known_issues:
            if fnmatch(case, known):
                return True
        return False

    for failed in failed_list:
        if not is_known(failed):
            filtered.append(failed)
    return filtered
