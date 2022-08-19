function Get-WKKanji {
	Write-Host "Abort with CTRL + C..." -f yellow
	while ($true) {
		$kanji = Read-Host "Enter a kanji"
		
		if (!([string]::IsNullOrEmpty($kanji))) {
			$url = "https://www.wanikani.com/kanji/$kanji"

			$t = Invoke-WebRequest $url -MaximumRedirection 0 -ErrorAction SilentlyContinue
			if ($t.StatusCode -ne 302) {
				# Second h1 tag, august 2022
				$kanjiContent = $t.ParsedHtml.getElementsByTagName('h1')[1].IHTMLElement_innerText
				$kanjiTitle = $kanjiContent.split(" ")[-2]

                # on reading
				$onYomiUnparsed = $t.ParsedHtml.body.GetElementsByClassName("span4 reading--onyomi")[0].innerText
				$onYomiParsed = $onYomiUnparsed.Split([Environment]::NewLine)[-1]
				
                # Mnemonics
				$mnemonicListElement = $t.ParsedHtml.body.GetElementsByClassName("mnemonic-content mnemonic-content--new")
                $mnemonicMeaningT = $mnemonicListElement[0].IHTMLDOMNode_nextSibling.innerText
                $mnemonicReadingT = $mnemonicListElement[1].IHTMLDOMNode_nextSibling.innerText
                
                # Reconstruct flat strings into multi-line
                $mnemonicMeaning = ""
                $i = 0; $mnemonicMeaningT.split(".") | % {
                    # This wacky code adds a "." back at every new line.
                    # Additionally, it will make sure that no "." gets put at each entry - because the last is empty.
                    $i++; if ($i -ne ($mnemonicMeaningT.split(".")).count) {
                        $mnemonicMeaning += $_ + ".$(([System.Environment]::Newline))"
                    }
                }
                
                $mnemonicReading = ""
                $i = 0; $mnemonicReadingT.split(".") | % {
                    $i++; if ($i -ne ($mnemonicReadingT.split(".")).count) {
                        $mnemonicReading += $_ + ".$(([System.Environment]::Newline))"
                    }
                }
                # Level
				$KanjiLevel = $t.ParsedHtml.body.GetElementsByClassName("level-icon")[0].innerText

                # Radicals composition
                $radicalList = ($t.ParsedHtml.body.GetElementsByClassName("alt-character-list")[0].innerText).split(" ")
                
                $radicals = ""
                for ($i = 0; $i -lt ($radicalList.count - 1); $i++) {
                    if ( [bool]($i % 2) ) {
                        # Only append a , if this is not the final entry
                        # 2 gets substracted to account for the < in the for{} condition
                        if ($i -eq ($radicalList.count - 2)) {
                            $radicals += "($($radicalList[$i]))"
                        } else {
                            $radicals += "($($radicalList[$i])), "
                        }
                    } else {
                        $radicals += $radicalList[$i] + " "
                    }
                }

                # Output
                Write-Host "> Composition: " -f cyan -NoNewline
                    Write-Host $radicals -f yellow

				Write-Host "> Meaning: " -f cyan -NoNewline
					Write-Host $kanjiTitle -f yellow
                    Write-Host "  > Mnemonic: " -f magenta -NoNewLine
                        # Because the mnemonic is a flat string, it will be converted to multi-line.
                        $mnemonicMeaning

				Write-Host "> Reading: " -f cyan -NoNewline
					Write-Host $onYomiParsed -f yellow
                    Write-Host "  > Mnemonic: " -f magenta -NoNewLine
                        $mnemonicReading

				Write-Host "> Level:   " -f cyan -NoNewline
					Write-Host $kanjiLevel -f yellow
			} else {
				Write-Host "> Not found on WK." -f red
			}
		} else {
			Write-Host "> Empty input." -f red
		}

		Write-Host ""
	}
}
