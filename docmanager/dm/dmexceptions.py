# -*- coding: utf-8 -*-
#
# This file is part of the docmanager distribution.
#
# docmanager is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 2 of the License, or (at your option) any
# later version.
#
# docmanager is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.


class DocManager(Exception):
   """Base Exception for DocManager errors"""
   pass


class DocManagerException(DocManager):
   """Base Exception for DocManager errors"""
   pass


class DocManagerWarning(DocManagerException):
   """Exception for DocManager warnings"""
   pass


class DocManagerPropertyException(DocManagerException):
   """Exception for DocManager warnings"""
   pass

class DocManagerCommitException(DocManagerException):
   """Exception for DocManager warnings"""
   pass

class DocManagerFileError(DocManagerException):
   """Exception raised, when something is wrong with a file"""
   pass

class DocManagerEnvironment(DocManagerException):
   """Exception raised, if something is not correct with the environment."""
   pass


class SVNException(Exception):
   """Exception for all Subversion errors"""
   pass



# Messages
NOT_IN_SVN_ERROR="ERROR: File '%s' is not available in SVN"
FILE_NOT_FOUND_ERROR="ERROR: File not found: '%s'"
EMPTY_FILELIST="Empty filelist. Nothing to do."
DIR_SVN_NOT_FOUND="ERROR: Could not find xml/.svn/ "\
                  "Are you sure you are in the correct directory?"
DIR_XML_NOT_FOUND="ERROR: I could not find the 'xml' directory in the current path. "\
                  "Are you sure you are in the correct directory?"
VALIDATION_ERROR="ERROR: Got the following validation error:\n %s\n"
NO_FILELIST_ERROR="\nThis should *not* happen!  Could not get filelist from make projectfiles although I validated the files.\nReason:"
NO_PROPERTY_ERROR="ERROR: Property %s not found in file '%s'"
NO_DIR_ERROR="ERROR: Directory »%s« not exists.\n" \
               "Maybe you did not check out the branches directory?\n"\
               "Solution:\n"\
               "  1. cd ../../..\n"\
               "  2. svn up -N branches\n"\
               "  3. svn co branches/<PROJECTNAME>\n"
EXPECTED_DICTIONARY_ERROR="ERROR setProperties: Expected a dictionary."
WRONG_DIRECTORY_ERROR="You are in the wrong directory.\n"\
                "Change your directory to something with trunk or branches."
EMPTY_FILELIST="File list ist empty, but I expected at least one entry."
MODIFIED_FILE="The content of the file '%s' is already modified.\n"\
               "Please commit your changes first."
MODIFIED_PROPS="Properties of the file '%s' are already modified.\n"\
               "Please commit your changes first."
NO_GRAPHICS_FOUND="-- No graphics found for this XML file."
ERROR_FAILED_XML_FORMATTING = "ERROR: XML formatting has failed.\n"\
                        "       Reason: %s"
ERROR_BRANCH_DIRECTORY_NOT_EXISTS="ERROR: Directory »%s« not exists.\n" \
               "Maybe you did not check out the branches directory?\n"\
               "Solution:\n"\
               "  1. cd ../../..\n"\
               "  2. svn up -N branches\n"\
               "  3. svn co branches/<PROJECTNAME>\n"
TOO_MANY_ENV_FILES="No ENV file found/used.\n"\
              "Solution: Use either --envfile or set the environment variable DAPS_ENV_NAME."           
OLDSTYLE_ENV_FILE="The ENV file is 'old style'.\n" \
              "Solution: Migrate to new style. See /usr/share/doc/packages/daps/README.upgrade_from_susedoc_4.x"
               
if __name__ == "__main__":
   pass
