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

import std.file: symlink, exists, dirEntries, DirEntry, SpanMode, readLink, remove;
import std.getopt: getopt, defaultGetoptPrinter;
import std.path: absolutePath, baseName, buildPath;
import std.stdio: writeln, writefln;


// Documentation strings
enum string version_info = "Pathify (0.1.0)";
enum string help_info = 
"
Description:
    Add an executable to the users PATH by symbolically linking it

Usage:
    pathify [--name NAME] [--path PATH] EXECUTABLE
    pathify [--remove] [--path PATH] EXECUTABLE
    pathify [--version | -v]
    pathify [--help | -h]

Arguments:
    EXECUTABLE      an executable to symbolically link on the users PATH

Options:
    -n --name         an alternative name (alias) for the linked executable
    -p --path         the path at which to create the symlink
    -r --remove       remove all symlinks to the executable, at the configured PATH
    -v --version      show the program version info
    -h --help         show this help information
    
Copyright © 2017 Matthew Remmel
DISTRIBUTED UNDER MIT LICENSE";

// Program options
string user_path = "/usr/local/bin";
string name_alias = "";
bool create_link = false;
bool remove_link = false;
bool help_wanted = false;
bool version_wanted = false;


int main(string[] args) {

    // Parse program options
	auto program_options = getopt(
		args,
        "path|p", &user_path,
		"name|n", &name_alias,
        // create_link = !remove_link
        "remove|r", &remove_link,
        "help|h", &help_wanted,
		"version|v", &version_wanted
	);

    // Set create_link
    create_link = !remove_link;

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
        return 1;
    }

    // Check that EXECUTABLE exists at path
    string executable_path = args[1].absolutePath();
    if (!exists(executable_path)) {
        writefln("ERROR: No executable exists at path: %s", executable_path);
        return 1;
    }

    // Create symlink
    if (create_link) {
        string link_name = executable_path.baseName;
        if (name_alias) link_name = name_alias;
        string link_path = buildPath(user_path, link_name);

        writefln("Creating symlink at: %s", link_path);
        symlink(executable_path, link_path);
        return 0;
    }

    // Remove symlinks
    if (remove_link) {
        foreach (DirEntry e; dirEntries(user_path, SpanMode.shallow, false)) {
            if (e.isSymlink) {
                string target_path = readLink(e.name);
                if (target_path == executable_path) {
                    writefln("Removing symlink at: %s", e.name);
                    remove(e.name);
                }
            }
        }

        return 0;
    }

    return 0;
}
