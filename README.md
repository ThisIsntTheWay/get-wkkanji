# Get-WKKanji
PS command to get kanji Info from WaniKani.  

Once executed, `Get-WKKanji` enters an endless loop to continually prompt for user input.  
(This behaviour is due to how I intend to use this thing, to quickly look up kanji without having to enter a command all the time)  

Pulls the following info:
 - Meaning
   - Mnemonic for meaning
 - Reading (On'yomi)
   - Mnemonic for reading
 - Radical composition
 - WK level availabilty

![image](https://user-images.githubusercontent.com/13659371/185706472-01b39a41-c261-460d-8a99-9669494e3b65.png)

Information is gathered by scraping the HTML acquired using `Invoke-WebRequest`.  
Their API is never accessed.
