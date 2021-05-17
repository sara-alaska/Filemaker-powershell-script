#!/usr/bin/env pwsh
# Sara Alaskarova
# Lab 9 - PowerShell Filemaker
# CS 3030 - Scripting Languages


if ($args.length -ne3) {
	write-output ("Usage: ./filemaker.ps1 INPUTCOMMANDFILE OUTPUTFILE RECORDCOUNT")
	exit 1
}

try {
	$recordCount = [int]$args[2]
} catch {
	write-output("Error: Record count must be an int")
	exit 1
}

if ($recordCount -lt 1) {
	write-output ("Error: Record count must be a positive int")
	exit 1
} 

try {
	$inputCommands = Get-Content -path $args[0] -erroraction stop 
}
catch {
	write-output ("Error opening or reading command file: $($_)")
	exit 1
}


try {
	$outputFile = $args[1]
	New-Item -path $outputFile -erroraction stop | out-null
} 
catch {
	write-output ("Error opening output file: $($_)") 
	exit 1
}

function writeToFile($outputFile, $outputString) { 
	$outputString = $outputString -replace [regex]::escape("\t"), "`t"
	$outputString = $outputString -replace [regex]::escape("\n"), "`n"
	try {
		add-content -path $outputFile -value $outputString -nonewline     
	} catch {
		write-output "Write failed to file $($outputFile): $_"
		exit 1    
	}
}

foreach($command in $inputCommands) {
	if ($command -match '^HEADER\s+"(.*)"$') {     
		writeToFile $outputFile $matches.1
	}
	
	if ($command -match '^FILEWORD\s+(.*)\s+"(.*)"$') {
		$randomFiles = @{}
		$filewordLabel = $matches.1		
		$filewordFilename = $matches.2
		try {
			$randomFiles = Get-Content -path $filewordFilename -erroraction stop
				 
		} catch {
			write-output ("Error opening or reading file: $($_)") 
			exit 1
		}
	}

}

for($num = 0; $num -lt $recordCount; $num++) {
	
	$randomData = @{}
	foreach($command in $inputCommands) {
		if ($command -match '^STRING\s+"(.*)"$' -or $command -match "^STRING\s+'(.*)'$") { 
			$stringValue = $matches.1
			writeToFile $outputFile $stringValue
		}
		if ($command -match '^FILEWORD\s+(.*)\s+"(.*)"$') { 
			$randomWord = Get-Random -inputobject $randomFiles
			$randomData[$filewordLabel] = $randomWord
			writeToFile $outputFile $randomWord
		}
		if ($command -match '^NUMBER\s+(\w+)\s+(\d+)\s+(\d+)$') { 
			$numberLabel = $matches.1
			$numberMin = $($matches.2).toInt32($null) 
			$numberMax = $($matches.3).toInt32($null)
			$randomNumber = Get-Random -min $numberMin -max $numberMax
			$randomData[$numberLabel] = $randomNumber
			writeToFile $outputFile $randomNumber				
		}


		if ($command -match '^REFER\s+(\w+)$') {
			$referLabel = $matches.1
			write-output($randomData[$referLabel])
			writeToFile $outputFile $randomData[$referLabel]
		}
		
	}
}



		







