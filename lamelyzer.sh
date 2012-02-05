#!/bin/bash
# A working proof of concept, lacking many features

# Gather all hashes for unsigned code from autoruns csv output file named aruns.csv
grep -i "(Not Verified)" aruns.csv | awk -F, '{print $(NF-2)}' | sort | uniq > aruns_hashes

# Reduce the data set to hashes that aren't in our good list
if [ -e hashes_cleared ]; then
    grep -vif hashes_cleared aruns_hashes > hashes2check
else
    mv aruns_hashes hashes2check
fi

# Should create a list of bad hashes and check against it too
if [ -e hashes_evil ]; then
    grep -if hashes_evil hashes2check > aruns_malware_hashes
fi

# Remove malware hashes from hashes2check
if [ -e aruns_malware_hashes ]; then
    grep -vif aruns_malware_hashes hashes2check > vtsubmissions
else
    mv hashes2check vtsubmissions
fi

# Search VirusTotal for reports on remaining hashes
echo "[+] $(wc -l vtsubmissions) hashes to check with Virus Total"
sleep 2
for i in $(cat vtsubmissions); do wget -O $i.html --no-check-certificate https://www.virustotal.com/latest-scan/$i; sleep 15; done

# Check results for malware
grep -l "[1-9][0-9]* / " *.html | awk -F. '{print $1}' | tee -a aruns_malware_hashes >> hashes_evil

# Pull out malware entries from aruns.csv
grep -if aruns_malware_hashes aruns.csv > aruns_malware

# Check results for non-malicious files
grep -l "0 / " *.html | awk -F. '{print $1}' >> hashes_cleared

# Check for results tnat are unknown to VT
grep -li "not found" *.html | awk -F. '{print $1}' >> unknowns

# Pull unkown entries from aruns.csv
grep -if unknowns aruns.csv > aruns_unknown

# Report results
let j=$(wc -l aruns_malware)
echo "[+] VirusTotal shows $j Autoruns entries may be malicious."
echo "[+] Check the aruns_malware file for details."
let j=$(wc -l aruns_unknown)
echo "[+] VirusTotal has never seen $j Autoruns entries."
echo "[+] Check the aruns_unknown file for details."
echo
