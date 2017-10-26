#!/usr/bin/env rdmd

//
// Pathify.d
//
// Created by Matthew Remmel on 10/25/17.
// Copyright © 2017 Matthew Remmel

// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the “Software”), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
// to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.

// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import std.stdio: writeln, writefln;
import std.getopt: getopt, defaultGetoptPrinter;
import std.file: exists;
import std.path: absolutePath, baseName, buildPath, symlink;


// Configuration
enum string LOCAL_PATH = "/usr/local/bin";

// Program options
bool help_wanted = false;
bool version_wanted = false;
string name_alias = "";

// Documentation strings
enum string version_info = "Pathify (0.1.0)";
enum string help_info = 
"
Description:
    Add an executable to the users PATH by symbolically linking it

Usage:
    pathify [--name NAME | -n NAME] EXECUTABLE
    pathify [--version | -v]
    pathify [--help | -h]

Arguments:
    EXECUTABLE      an executable to symbolically link on the users PATH

Options:
    -n --name       an alternative name (alias) for the linked executable
    -v --version    show the program version info
    -h --help       show this help information
    
Copyright © 2017 Matthew Remmel
DISTRIBUTED UNDER MIT LICENSE";


int main(string[] args) {

    // Parse program options
	auto program_options = getopt(
		args,
		"name|n", &name_alias,
		"version|v", &version_wanted,
        "help|h", &help_wanted
	);

    // Display help if requested
	if (help_wanted) {
        writeln(version_info);
        writeln(help_info);
        return 0;
	}

    // Display version if requested
    if (version_wanted) {
        writeln(version_info);
        return 0;
    }

    // Check that EXECUTABLE path argument exists
    if (args.length < 2) {
        writeln("ERROR: Executable must be provided. See help for usage.");
        return 1;
    }
    else if (args.length > 2) {
        writeln("ERROR: Too many arguments. See help for usage.");
    }

    // Check that EXECUTABLE exists at path
    string executable_path = args[1];
    if (!exists(executable_path)) {
        writefln("ERROR: No executable exists at path: %s", executable_path);
        return 1;
    }

    // Create symlink in LOCAL_PATH
    string full_path = executable_path.absolutePath();
    string link_name = executable_path.baseName;
    if (name_alias) link_name = name_alias;
    string link_path = buildPath(LOCAL_PATH, link_name);

    writefln("Creating symlink at %s", link_path);
    symlink(full_path, link_path);

    return 0;
}
