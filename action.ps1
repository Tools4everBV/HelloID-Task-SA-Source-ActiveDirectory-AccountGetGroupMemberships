try {
    $userPrincipalName = $dataSource.selectedUser.UserPrincipalName
    Write-Information "Searching AD user [$userPrincipalName]"

    Import-Module ActiveDirectory -ErrorAction Stop
    
    $adUser = Get-ADuser -Filter { UserPrincipalName -eq $userPrincipalName } 

    if([String]::IsNullOrEmpty($adUser) -eq $true) {
        $msg = "Could not find AD user [$userPrincipalName]"
        Write-Error $msg
    } else {
        Write-Information "Found AD user [$userPrincipalName]"

        $groups = Get-ADPrincipalGroupMembership -identity $adUser | Select-Object name, sid | Sort-Object name
        $groups = $groups | Where-Object {$_.Name -ne "Domain Users"}
        $resultCount = @($groups).Count
        
        Write-Information "Group membership count: $resultCount"
        
        if($resultCount -gt 0) {
            foreach($group in $groups)
            {
                $returnObject = @{
                    name    = "$($group.name)";
                    sid     = [string]"$($group.sid)";
                }
                
                Write-Output $returnObject
            }
        }
    }
} catch {
    $msg = "Error getting group memberships [$userPrincipalName]. Error: $($_.Exception.Message)"
    Write-Error $msg
}