# Tanuki 🦝
### Ransomware Simulation Script (Placeholder)
Simulates TTPs of a fictitious ransomware group named Tanuki.
Intended for use on an AD server (virtual machine) that can be restored to snapshot.

![screenshot](Tanuki_BG.jpg)

The PWSH script performes the following actions when launched:
1. Checks if script was executed as Administrator
2. Creates a log file in the path of the executed script
3. Creates the directories "C:\AtomicRedTeam\ExternalPayloads"
4. Excludes "C:\AtomicRedTeam" in Microsoft Defender
5. Installs and enables Atomic Red Team
6. Simulates ransomware attack by executing a set of Atomic Red Team tests
7. Creates 100 files with extension .tanuki, ransom note and replaces the desktop wallpaper
 
### Tactics, Techniques, and Procedures (TTPs)
| **Tactic**        | **Technique** | **Sub-techniques or Tools** |
| ----------------- | ------------- | --------------------------- |
| Initial Access    | -             | -                           |
| Discovery         | -             | -                           |
| Lateral Movement  | -             | -                           |
| Credential Access | -             | -                           |
| Persistence       | -             | -                           |
| Execution         | -             | -                           |
| Defense Evasion   | -             | -                           |
| Impact            | -             | -                           |

> In [Japanese folklore](https://en.wikipedia.org/wiki/Japanese_folklore), Japanese raccoon dogs (*tanuki*) have had a significant role since ancient times. They are reputed to be mischievous and jolly, masters of disguise and [shapeshifting](https://en.wikipedia.org/wiki/Shapeshifting) but somewhat gullible and absent-minded.

Source: https://en.wikipedia.org/wiki/Japanese_raccoon_dog
