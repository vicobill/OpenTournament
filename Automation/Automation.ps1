# TO-DO Place the output in a dedicated log file.

# $($args[0]) = C:\UE_4.25.1\Engine
Write-Output "ARG-0: $($args[0])"

# $($args[1]) = C:\UE_PROJECTS\ProjectRoot
Write-Output "ARG-1: $($args[1])"
# $($args[2]) = ProjectName
Write-Output "ARG-2: $($args[2])"

# $($args[3]) = Editor\Client\Server\[Blank]
Write-Output "ARG-3: $($args[3])"
# $($args[4]) = Development\Shipping\Debug
Write-Output "ARG-4: $($args[4])"
# $($args[5]) = Win64\Linux
Write-Output "ARG-5: $($args[5])"

# $($args[6]) = Validate|Build|Cook|Stage|Safeguard|Archive|Other_A|Other_B|etc.
Write-Output "ARG-6: $($args[6])"

$TOOLS_ROOT = "$($args[0])"
Write-Output "TOOLS_ROOT: $TOOLS_ROOT"
$TOOLS_UBT = "$($args[0])\Binaries\DotNET\UnrealBuildTool.exe"
Write-Output "TOOLS_UBT: $TOOLS_UBT"
$TOOLS_UAT = "$($args[0])\Build\BatchFiles\RunUAT.bat"
Write-Output "TOOLS_UAT: $TOOLS_UAT"

$PROJECT_ROOT = "$($args[1])"
Write-Output "PROJECT_ROOT: $PROJECT_ROOT"
$PROJECT_TITLE = "$($args[2])"
Write-Output "PROJECT_TITLE: $PROJECT_TITLE"
$PROJECT_DESCRIPTOR = "$PROJECT_ROOT\$PROJECT_TITLE.uproject"
Write-Output "PROJECT_DESCRIPTOR: $PROJECT_DESCRIPTOR"

$PACKAGE_TARGET = "$($args[3])"
Write-Output "PACKAGE_TARGET: $PACKAGE_TARGET"
$PACKAGE_CONFIGURATION = "$($args[4])"
Write-Output "PACKAGE_CONFIGURATION: $PACKAGE_CONFIGURATION"
$PACKAGE_PLATFORM = "$($args[5])"
Write-Output "PACKAGE_PLATFORM: $PACKAGE_PLATFORM"
$PACKAGE_ARGUMENTS = "-Project=$PROJECT_DESCRIPTOR -Target=$PROJECT_TITLE$($args[3]) -Configuration=$($args[4]) -Platform=$($args[5])"
Write-Output "PACKAGE_ARGUMENTS: $PACKAGE_ARGUMENTS"

$COMMAND = "$($args[6])"
Write-Output "COMMAND: $COMMAND"

switch ($COMMAND)
{
    "Validate"
    {
        Write-Host | & $TOOLS_UBT $PROJECT_DESCRIPTOR, -ProjectFiles, -Game, -Progress
        Write-Host | & $TOOLS_UBT $PROJECT_DESCRIPTOR, "$($PROJECT_TITLE)Editor", Development, Win64, -WaitMutex, -FromMsBuild
        Write-Host | & $TOOLS_UBT $PROJECT_DESCRIPTOR, -Run=CompileAllBlueprints, -IgnoreFolder=/Engine,/RuntimeTests
        break
    }
    "Build"
    {
        Write-Host | & $TOOLS_UAT BuildTarget, $ARGUMENTS
        break
    }
    "Lighting"
    {
        Write-Host | & $TOOLS_UAT RebuildLightmaps, $ARGUMENTS
        break
    }
    "Cook"
    {
        Write-Host | & $TOOLS_UAT BuildCookRun, $ARGUMENTS, -Cook, -SkipEditorContent, -Compressed, -Unversioned
        break
    }
    "Stage"
    {
        Write-Host | & $TOOLS_UAT BuildCookRun, $ARGUMENTS, -Stage, -StagingDirectory="$ROOT_PROJECT\Packages", -SkipCook
        Rename-Item -Path "Autozzz" -NewName "Auto"
        break
    }
    "Safeguard"
    {
        $REDISTRIBUTABLES_SOURCE  = "$TOOLS_ROOT\Binaries\ThirdParty\AppLocalDependencies"
        switch ($PACKAGE_PLATFORM)
        {
            "Win64"
            {
                $REDISTRIBUTABLES_DESTIONATION = "$PROJECT_PATH\Output\Staged\$($args[3])\$($args[4])\$($args[5])\Windows$($args[3])\Engine\Binaries\$($args[5])\"
                Copy-Item -Force -Recurse -Verbose "$REDISTRIBUTABLES_SOURCE\$($args[5])\*" -Destination $REDISTRIBUTABLES_DESTIONATION
                break
            }
            "Linux"
            {
                # Nothing to do at the moment.
                break
            }
            "Mac"
            {
                # Nothing to do at the moment.
                break
            }
            default
            {
                # Should probably throw an exception here.
            }
        }
        default
        {
            # Should probably throw an exception here.
        }
    }
    "Archive"
    {
        Write-Host | Compress-Archive -Path "$PROJECT_PATH\Output\Staged\$($args[3])\$($args[4])\$($args[5])\*" -DestinationPath "$PROJECT_PATH\Output\Archived\$($args[3])\$($args[4])\$($args[5])\$($ROOT_TITLE)_$($args[3])_$($args[4])_$($args[5])_"$(Get-Date -Format "dd-mm-yyyy")".zip"
        break
    }
    default
    {
        # Should probably throw an exception here.
    }
}

# These commands will be part of a different script, dedicated to provide maintenance to the required tools.
#
# Write-Host | & "$TOOLS_PATH\Binaries\DotNET\UnrealBuildTool.exe" BootstrapPackagedGame, Shipping, Win64
