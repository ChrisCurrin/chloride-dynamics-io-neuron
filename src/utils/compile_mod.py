# coding=utf-8
from __future__ import print_function

import glob
import sys
import platform
import argparse
import shutil
import os
from subprocess import Popen, PIPE

import functools
from typing import Optional, Tuple

from src.utils.file_io import cd, delete_files


def nrnivmodl(path="", clean_after=True) -> Tuple[str, Optional[str]]:
    """
    Compile mod files in path

    Note that the compiled file (nrnmech.dll or x86_64/libnrnmech.so) is created in the
    current working directory.

    :param path: path to mod files or use current path if empty
    :param clean_after: clean the mod files after compilation

    :return: output of nrnivmodl and error message if any
    """
    from pathlib import Path
    err = None

    result = os.system(f"nrnivmodl {path}")

    # check if temp file exists, indicating an error
    if list(Path(path).glob("*.tmp")):
        compiler_output = "nrnivmodl: compilation failed - tmp file exists"
    elif result == 0:
        compiler_output = "nrnivmodl: compilation successful"
    else:
        compiler_output = "nrnivmodl: compilation failed"
        err = "nrnivmodl: compilation failed - unknown error"

    if clean_after:
        compiled_files = functools.reduce(
            lambda l1, l2: l1 + l2,
            [glob.glob("*.{}".format(file_type)) for file_type in ["o", "c", "tmp"]],
        )
        delete_files(compiled_files)

    return compiler_output, err



if __name__ == "__main__":
    # command line program
    parser = argparse.ArgumentParser()
    parser.add_argument("--path", type=str, default="./lib",
                        help="path to directory or files")
    parser.add_argument("--dest", type=str, default=None,
                        help="output destination")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--hoc", action="store_true",
                       help="path is to '.hoc' files only (tries to compile mod files from current directory)")
    group.add_argument("--mod", action="store_true",
                       help="path is to '.mod' files only")
    args = parser.parse_args()
    compile_mod(*args._get_args(), **args._get_kwargs())
