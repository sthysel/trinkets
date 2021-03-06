# run  set-executionpolicy unrestricted in a ps session as admin to enable script execution
# Creates a new database using our specifications
# thysm

set-psdebug -strict
$ErrorActionPreference = "stop"

$serverName = "frmpddbmssql01\dev211263"
$dbUser = "sa"
$password = "********"
$dbName = "AppDB"
$regularDBUserName="mydbuser"

# a test query to see if I can retrieve data from the db
$getSLO = "select * from dbo.SpecificLearningObjective"

function hitServer {
	param(
		[String] $query,
		[String] $catalog
	)
	$cnString = "Password=$password;Persist Security Info=True;User ID=$dbUser;Initial Catalog=$catalog;Data Source=$serverName"
	$cn = New-Object System.Data.SqlClient.SqlConnection($cnString)
	$da = New-Object System.Data.SqlClient.SqlDataAdapter($query, $cn)
	$ds = New-Object System.Data.DataSet
	$da.Fill($ds) | Out-Null
	$cn.Close()
	
	Write-Output $ds.Tables[0]
}

function flapDB {
	param(
		[String] $name
	)
	
	$dropcreate = "
	    -- flap db
		if exists (select name from master.sys.databases where name = N'$name')
		begin
			alter database $name set single_user with rollback immediate
			drop database $name
		end
		create database $name
	"
	
	$adduser = "
		-- add user, we assume $regularDBUserName is present in master
		use $name
		create user $regularDBUserName for login $regularDBUserName
	"
	
	hitServer $dropcreate master
	hitServer $adduser $name
	
	
}

flapDB cmsit



