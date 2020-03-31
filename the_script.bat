

:: Takes one .zip file and one secret file as input in cmd.
@echo off
setlocal

:: Set initial paths.
set main_path=%cd%
set temp_data=%main_path%\temp_data
set _git_dir=%main_path%\temp_git
mkdir %temp_data%
mkdir %_git_dir%

:: Catch the input file and check type.
set the_file=%1

if not %~x1 == .zip (
    echo Not a .zip archive
    :: Just exit the script and return control.
    exit /B
)

:: Read sensitive information from an input file. One per line in this example.
(
    set /p github_username=
    set /p github_pw=
    set /p art_username=
    set /p art_pw=
)<%2

:: Set github repo info.
set repo=some-repo
set repo_url_base=github.com/some-user/some-repo.git
set repo_url=https://%github_username%:%github_pw%@%repo_url_base%

:: Set url of repository in artifactory.
set artifactory_url=http://url-of.an/artifactory/repo

::
::
::

:: Copy the .zip file into temporary folder, and unzip.
copy %the_file% %temp_data%
powershell -Command "Expand-Archive -LiteralPath %temp_data%\%the_file% -DestinationPath %temp_data%\unzipped"

:: ===================================
:: ============= GIT =================
:: ===================================

:: Download portable git into temporary git directory.
set git_url=https://github.com/git-for-windows/git/releases/download/v2.26.0.windows.1/PortableGit-2.26.0-64-bit.7z.exe
curl -L %git_url% --output %_git_dir%\pgit.7z.exe

:: The downloaded file is an SFX, so run it and wait for it to finish before proceeding.
start /W %_git_dir%\pgit.7z.exe -o %_git_dir%\PortableGit -y

:: Set the path to the git.exe that was just extracted, so it can be called directly from a variable.
set _git=%_git_dir%\PortableGit\bin\git.exe

:: Clone the repository.
%_git% clone %repo_url%

:: Copy the unzipped files to the cloned repository, disregard all collisions.
xcopy /s /y %temp_data%\unzipped %main_path%\temp_test

::%_git% remote show origin.
cd %main_path%\%repo%

:: Push the new state to a repository.
%_git% add .
%_git% commit -m "Contents from zip: %the_file%"
%_git% push

:: Get last sha-1 for tagging artifactory push.
%_git% rev-parse HEAD > %temp_data%\last_commit_sha.txt

cd %main_path%

:: ===================================
:: ========== ARTIFACTORY ============
:: ===================================

:: Set the name of the artifact, as it will appear in artifactory, to be the last commit hash.
set /p artifact_name=<%temp_data%\last_commit_sha.txt

:: Push the artifact to artifactory.
curl -X PUT -u %art_username%:%art_pw% -T %temp_data%\%the_file% "%artifactory_url%/%artifact_name%.zip"

:: Clean up.
rmdir %main_path%\temp_data /S /Q
rmdir %main_path%\temp_test /S /Q
rmdir %main_path%\temp_git /S /Q

endlocal