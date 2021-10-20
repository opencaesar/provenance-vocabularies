#!/usr/bin/env pwsh
<#
  .Synopsis
  Uses 'git describe' to get the current git-based version for computing the next major, minor or patch version.

  .Parameter major
  Create a tag for the next major version from the current git-describe version

  .Parameter minor
  Create a tag for the next minor version from the current git-describe version
  
  .Parameter patch
  Create a tag for the next patch version from the current git-describe version

  .Parameter prefix
  String prefix for the git tag version
#>

Param(`
  [switch] $major,
  [switch] $minor,
  [switch] $patch,
  [string] $prefix = '')

function CreateAndPushTag {
  param(
    [string]$repository,
    [string]$tag)
 
  Write-Host "# Create amd push tag: $tag to $repository"
  git tag -s -m"$tag" "$tag"
  if (!$?) {
    throw "Cannot create tag: $tag"
  }
  git push $repository HEAD tag $tag
  if (!$?) {
    throw "Cannot push tag: $tag to repository $repository"
  }
}

$status=$(git status --porcelain)
if (![string]::IsNullOrEmpty($status)) {
  throw "There are uncommitted changes:`n$status"
}

$glob="${prefix}[0-9].[0-9].[0-9]*"
$version=git describe --match "$glob"

if (!$?) {
  throw "Cannot describe git version matching $glob"
}

# Typically, this will be origin/master
$remote=git rev-parse  --abbrev-ref --symbolic-full-name '@{push}'
$repository=$remote -replace '^(.*)/.*$', '$1'


if (!$version.StartsWith($prefix)) {
  throw "Prefix, '$prefix' is not a prefix of 'git describe': $version"
}

[int]$major0=$version -replace "^$prefix([0-9]*)\.[0-9]*\.[0-9]*\-?.*$", '$1'
$major1=$major0 + 1

[int]$minor0=$version -replace "^$prefix[0-9]*\.([0-9]*)\.[0-9]*\-?.*$", '$1'
$minor1=$minor0 + 1

[int]$patch0=$version -replace "^$prefix[0-9]*\.[0-9]*\.([0-9]*)\-?.*$", '$1'
$patch1=$patch0 + 1

$next_major="$prefix$major1.0.0"
$next_minor="$prefix$major0.$minor1.0"
$next_patch="$prefix$major0.$minor0.$patch1"


if (!$major -and !$minor -and !$patch) {
  Get-Help $PSCommandPath -full 
  throw "Specify one of the following options:`n-major for $next_major`n-minor for $next_minor`n-patch for $next_patch"
} elseif ($major -and !$minor -and !$patch) {
  CreateAndPushTag $repository $next_major
} elseif (!$major -and $minor -and !$patch) {
  CreateAndPushTag $repository $next_minor
} elseif (!$major -and !$minor -and $patch) {
  CreateAndPushTag $repository $next_patch
}
