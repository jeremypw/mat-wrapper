/*
 * Copyright (C) 2019      Jeremy Wootten
 *
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Authors:
 *  Jeremy Wootten <jeremywootten@gmail.com>
 *
*/

public class MatWrapper.App : Gtk.Application {
    /* Placeholder for possible future options */
    public const OptionEntry[] MAT_OPTION_ENTRIES = {
        { "no_rename", 0, 0, OptionArg.NONE, out no_rename,
        "Stripped file keeps original name", null },
        { null }
    };

    public static bool no_rename = false;

    public static HashTable<File, string> files_to_rename;

    construct {
        application_id = "com.github.jeremypw.mat_wrapper";
        set_option_context_summary (N_("Create copy file stripped of metadata"));
        set_option_context_description (N_("""
Before using this tool, the 'mat' package must be installed. This tool is intended for use as a simple
contractor for the elementaryos Files application and provides the necessary contractor file. More functionality
can be obtained by running the mat tool at the command line or by launching the mat-gui app.
"""));

        set_option_context_parameter_string (N_("[FILES]"));
        flags = ApplicationFlags.HANDLES_OPEN;
        Intl.setlocale (LocaleCategory.ALL, "");

        add_main_option_entries (MAT_OPTION_ENTRIES);

        files_to_rename = new HashTable<File,string> (File.hash, File.equal);
    }

    public override void activate () {
        critical (_("No files provided"));
        return;
    }

    public override void open (File[] files, string hint) {
        var mat_commandline = "mat --backup ";
        hold ();

        foreach (File in_file in files) {
            string in_path = in_file.get_path ();
            if (valid_path_to_strip (in_path)) {
                bool success = false;
                var command = mat_commandline + "'" + in_path + "'"; //Quote in case input contains spaces

                try {
                    string std_out, std_err;
                    int exit_status;
                    if (Process.spawn_command_line_sync (command, out std_out, out std_err, out exit_status)) {
                        if (exit_status == 0) {
                            success = true;
                        }
                    }
                } catch (SpawnError e) {
                    warning ("Error spawning %s - %s", command, e.message);
                }

                if (success && !no_rename) {
                    try {
                        var stripped_file = File.new_for_commandline_arg (in_path);
                        var original_name = in_file.get_basename ();
                        stripped_file.set_display_name (original_name + ".stripped");
                        var backup_file = File.new_for_commandline_arg (in_file.get_path () + ".bak");
                        files_to_rename.insert (backup_file, original_name);
                    } catch (Error e) {
                        success = false;
                        warning ("Error renaming file %s - %s", in_path, e.message);
                    }
                }
            } else {
                /*TODO Give UI feedback regarding ignored files */
                warning ("%s not valid for stripping", in_path);
            }
        }

        if (files_to_rename.size () > 0) {
            files_to_rename.@foreach ((backup_file, original_name) => {
                try {

                    backup_file.set_display_name (original_name);
                } catch (Error e) {
                    warning ("Error renaming file %s - %s", backup_file.get_basename (), e.message);
                }
            });

            release ();

        } else {
            release ();
        }
    }

    private bool valid_path_to_strip (string path) {
        /* Do not process files if it would create files that already exist or are the result of previous
         * stripping */
        if (path.has_suffix (".suffix") ||
            path.has_suffix (".bak")) {

            return false;
        }

        var stripped_file = File.new_for_commandline_arg (path + ".stripped");
        if (stripped_file.query_exists ()) {
            return false;
        }

        var backup_file = File.new_for_commandline_arg (path + ".bak");
        if (backup_file.query_exists ()) {
            return false;
        }

        return true;
    }
}

public static int main (string[] args) {
    var application = new MatWrapper.App ();
    return application.run (args);
}
