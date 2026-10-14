param(
    [Parameter(Mandatory = $true)][string]$SigningDirectory,
    [string]$Keytool = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
)

$ErrorActionPreference = 'Stop'
$quranProjectPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$quranPrivatePath = [IO.Path]::GetFullPath($SigningDirectory)
$quranConfigPath = Join-Path $quranProjectPath 'android\key.properties'
if (-not [IO.Path]::IsPathFullyQualified($SigningDirectory) -or
    $quranPrivatePath.TrimEnd('\') -eq [IO.Path]::GetPathRoot($quranPrivatePath).TrimEnd('\') -or
    $quranPrivatePath.StartsWith($quranProjectPath + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Choose a specific private signing folder outside the repository.'
}
if ((Test-Path -LiteralPath $quranPrivatePath) -or (Test-Path -LiteralPath $quranConfigPath)) {
    throw 'Refusing to overwrite an existing signing folder or signing configuration.'
}
if (-not (Test-Path -LiteralPath $Keytool -PathType Leaf)) { throw 'Java keytool is unavailable.' }

New-Item -ItemType Directory -Path $quranPrivatePath | Out-Null
# New generated credentials are readable only by this Windows user and SYSTEM.
$quranOwnerSid = [Security.Principal.WindowsIdentity]::GetCurrent().User
$quranSystemSid = [Security.Principal.SecurityIdentifier]::new('S-1-5-18')
$quranFolderAcl = [Security.AccessControl.DirectorySecurity]::new()
$quranFolderAcl.SetAccessRuleProtection($true, $false)
$quranFolderAcl.SetOwner($quranOwnerSid)
foreach ($sid in @($quranOwnerSid, $quranSystemSid)) {
    $quranFolderAcl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
        $sid, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'))
}
Set-Acl -LiteralPath $quranPrivatePath -AclObject $quranFolderAcl
$quranRandomBytes = [byte[]]::new(32)
[Security.Cryptography.RandomNumberGenerator]::Fill($quranRandomBytes)
$quranPassword = [Convert]::ToHexString($quranRandomBytes)
$quranPasswordPath = Join-Path $quranPrivatePath 'password-input.tmp'
$quranKeyPath = Join-Path $quranPrivatePath 'quranhaven-upload.p12'
$quranCertPath = Join-Path $quranPrivatePath 'quranhaven-upload-certificate.pem'
try {
    # Passwords never appear in command arguments or tool output.
    [IO.File]::WriteAllText($quranPasswordPath, $quranPassword, [Text.UTF8Encoding]::new($false))
    & $Keytool -genkeypair -noprompt -keystore $quranKeyPath -storetype PKCS12 `
        -alias quranhaven-upload -keyalg RSA -keysize 3072 -sigalg SHA256withRSA `
        -validity 10000 -dname 'CN=Quran Haven Upload Key' `
        -storepass:file $quranPasswordPath -keypass:file $quranPasswordPath
    if ($LASTEXITCODE -ne 0) { throw 'Upload-key creation failed; preserve the private folder for inspection.' }
    & $Keytool -exportcert -rfc -keystore $quranKeyPath -alias quranhaven-upload `
        -storepass:file $quranPasswordPath -file $quranCertPath
    if ($LASTEXITCODE -ne 0) { throw 'Public-certificate export failed.' }
    $quranProperties = "storeFile=$($quranKeyPath.Replace('\','/'))`nstoreType=PKCS12`nstorePassword=$quranPassword`nkeyAlias=quranhaven-upload`nkeyPassword=$quranPassword`n"
    # Generated secret artifacts, not source files; never commit or upload them.
    [IO.File]::WriteAllText((Join-Path $quranPrivatePath 'KEEP-PRIVATE-signing.properties'), $quranProperties, [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText($quranConfigPath, $quranProperties, [Text.UTF8Encoding]::new($false))
    $quranFileAcl = [Security.AccessControl.FileSecurity]::new()
    $quranFileAcl.SetAccessRuleProtection($true, $false)
    $quranFileAcl.SetOwner($quranOwnerSid)
    foreach ($sid in @($quranOwnerSid, $quranSystemSid)) {
        $quranFileAcl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new($sid, 'FullControl', 'Allow'))
    }
    Set-Acl -LiteralPath $quranConfigPath -AclObject $quranFileAcl
    & $Keytool -printcert -file $quranCertPath
    if ($LASTEXITCODE -ne 0) { throw 'Certificate verification failed.' }
    Write-Output "Private signing folder created: $quranPrivatePath"
    Write-Output 'Keep the entire private folder in your own secure offline backup. Do not upload the keystore or private properties.'
} finally {
    $quranPassword = $null
    [Array]::Clear($quranRandomBytes, 0, $quranRandomBytes.Length)
    # Exact task-generated temporary file, never a recursive delete.
    if ((Test-Path -LiteralPath $quranPasswordPath) -and
        [IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($quranPasswordPath)) -eq $quranPrivatePath) {
        Remove-Item -LiteralPath $quranPasswordPath -Force
    }
}
