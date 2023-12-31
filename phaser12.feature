## Version 2.0
## language: en

Feature:
  TOE:
    Vulnhub
  Category:
    Reflected XSS
  Location:
    http://192.168.1.15/enter_network/admin.php
  CWE:
    CWE-79: Improper Neutralization of Input During Web Page Generation
  Rule:
    REQ.029: https://docs.fluidattacks.com/criteria/requirements/029/
    REQ.173: https://docs.fluidattacks.com/criteria/requirements/173/
  Goal:
    Perform a reflected XSS attack on the vulnerable machine to access admin sensitive information
  Recommendation:
    Implement security attributes for session cookies such as HttpOnly, Secure and SameSite as well as discarding potententially harmful information recieved through data inputs 

  Background:
      Hacker's software:
      | <Software name>    | <Version>          |
      | Burp Suite CE      | 2023.10.3.4-24713  |
      | Kali Linux         | 5.15.0-kali3-amd64 |
      | Firefox ESR        | 91.5.0             |
      | Fping              | 5.1                |
      | Gobuster           | 3.6                |
      | Nmap               | 7.92               |
      | FoxyProxy Standard | 7.5.1              |
      | VirtualBox         | 6.1.48             |

  TOE information:
    Given I access the Vulnhub website
    Then I download the .ova file associated with "web-machine-n7"
    Then I check the MD5 hash code
    And I check the SHA1 hash code to verify the machine's integrity
    And [evidence](evidences/img0.png)
    And I confirm that both of the hash codes match [evidence](evidences/img1.png)
    And I read the vulnerable machine's information which says
    """
    When starting out to attack the machine, the user might help by making sure the machine is up & running correctly as some machines are easier to discover on the network than others.
    DHCP service: Enabled
    IP address: Automatically assigned
    """
    Then I import the .ova file using VirtualBox
    And I start the vulnerable machine
    And I start my Kali Linux VM
    Then I use Nmap on my Kali Linux VM 
    And I discover open ports on the vulnerable machine [evidence](evidences/img2.png)
    And I see that port 80 is opened
    And I see that SSH port 22 is closed
    And I see that FTP ports 20,21 are also closed
    Then I conclude that I can not SSH or FTP remotely to the vulnerable machine
    And I conclude that the data hosted on the vulnerable machine is unencrypted

  Scenario: Normal use case
    Given I set my Kali Linux VM
    And I set the vulnerable VM to bridged mode in VirtualBox
    Then both machines are on the same local network
    Then I get the default gateway IP address of the vulnerable VM
    And I get its subnet mask by running the following command on my Kali Linux VM
    """
    ip route
    """
    Then I send ICMP echo probes to the gateway's IP address 
    And I find network hosts associated with it [evidence](evidences/00.png)
    And I get the IP address of the vulnerable machine which in this case is
    """
    192.168.1.6
    """
    Then I access the vulnerable machine using Firefox ESR
    And I see that the vulnerable machine is using an "/index.html" file 
    And [evidence](evidences/01.png)
    And I see that the vulnerable machine has a "/profile.php" file
    And the vulnerable VM has a fragment identifier on the "/profile.php#" file

  Scenario: Dynamic Detection
    Given I found the three main visibile directories hosted on the vulnerable VM
    Then I use Gobuster to brute force vulnerable directories on the vulnerable VM
    And I find that there is a vulnerable file with a 200 status code called 
    """
    exploit.html
    """
    And [evidence](evidences/02.png) 

  Scenario: Exploitation
    Given I found a vulnerable file called "/exploit.html"
    Then I access the "exploit.html" vulnerable file via Firefox ESR
    And I open my Firefox ESR web developer tools
    And I find that there is a URL with a localhost portion in it
    And [evidence](evidences/03.png)
    And I input the vulnerable VM's IP address into the localhost portion 
    And [evidence](evidences/04.png)
    Then I click on the "Submit Query" button
    And I find the first flag [evidence](evidences/05.png)
    Then I reboot the vulnerable machine
    And I press on my computer's keyboard the letter "e"
    Then I access the vulnerable machine GUI's firmware
    And I look for the keyword "ro"
    And I replace the keyword "ro" with "rw"
    Then I look for the keywords
    """
    quiet splash
    """
    And I replace the keywords "quiet splash" with
    """
    init=/bin/bash
    """
    Then I boot the vulnerable machine by pressing the key "f10"
    And I gain root access to the vulnerable VM's command line interface
    And I mount the file system by typing the following command on the root CLI
    """
    mount
    """
    Then I change the root user's password by typing the following command
    """
    passwd
    """
    Then I input my new desired root user's password twice
    Then I execute the bootloader by running the following command on the root CLI
    """
    exec /sbin/init
    """
    Then I login to the vulnerable machine using the following credentials
    """
    Username: root
    Password: <password that I set when changing the root password on the root's CLI>
    """
    Then I use Firefox ESR to navigate to the vulnerable VM's root directory
    """
    file:///var/www/html
    """
    And I notice that there is an "/enter_network" directory [evidence](evidences/06.png)
    Then I navigate to the /enter_network directory using Firefox ESR
    And I see a login page [evidence](evidences/07.png)
    Then I input a random username and password 
    And I click on the "Send" button to send an HTTP request to the vulnerable VM
    And I use Burp Suite with FoxyProxy Standard to capture the HTTP request 
    And [evidence](evidences/08.png)
    Then I send the HTTP request to the repeater
    And I find the Base64 encoding value for Set-Cookie=Role [evidence](evidences/09.png)
    Then I turn off FoxyProxy Standard on Firefox ESR
    And I look up the reversed MD5 hash for the Base64 encoded value
    And I find the reversed MD5 hash value for the Set-Cookie=Role
    And [evidence](evidences/10.png)
    Then I brute force vulnerable directories within the /enter_network directory
    And I notice that there is an "/admin.php" file with a 200 status code 
    And [evidence](evidences/11.png)
    Then I access the /admin.php file through Firefox ESR [evidence](evidences/12.png)
    Then I turn on FoxyProxy Standard on Firefox ESR
    And I make an HTTP request to the endpoint "/enter_network/admin.php"
    Then I capture the HTTP request by using Burp Suite with FoxyProxy Standard
    And I send the HTTP request headers to the repeater
    And I replace the hash value of "Cookie: Role"
    And I use its reversed MD5 hash value I found earlier [evidence](evidences/13.png)
    Then I send the request through the repeater to capture the response headers
    And I get the second flag [evidence](evidences/14.png)

  Scenario: Remediation
    Given the machine is vulnerable to reflected XSS attacks
    And the vulnerable machine is using port 80 which is unencrypted
    Then input should be validated by using well-defined regular expressions
    And SSL/TLS encryption should be used on port 443
    Then use asymmetric encryption to securely exchange the private key
    Then use symmetric encryption to encrypt the vulenrable machine's data
    Then the integrity of data hosted on the vulneable machine will be ensured

  Scenario: Scoring
    Severity according to CVSSv3 standard
    Base: Attributes that are constants over time and organizations
      4.7/10 (Medium) - AV:N/AC:H/PR:N/UI:R/S:C/C:H/I:H/A:H
    Temporal: Attributes that measure the exploit's popularity and fixability
      4.7/10 (Medium) - E:H/RL:O/RC:C/
    Environmental: Unique and relevant attributes to a specific user
      4.5/10 (Medium) - CR:L/IR:L/AR:L

  Scenario: Correlations
    No correlations have been found
